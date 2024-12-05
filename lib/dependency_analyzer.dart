import 'dart:io';

import 'package:dep_analyzer/dependency_config.dart';
import 'package:yaml/yaml.dart';

class Package {
  final String name;
  final String path;

  Package({required this.name, required this.path});

  @override
  String toString() => 'Package(name: $name, path: $path)';
}

class DependencyAnalyzer {
  final DependencyConfig config;

  DependencyAnalyzer(this.config);

  void analyze(String projectPath) async {
    print('Analyzing project at $projectPath');
    final dir = Directory(projectPath);
    if (!dir.existsSync()) {
      print('Error: Project directory not found at $projectPath');
      return;
    }

    final packages = <Package>{};
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('pubspec.yaml')) {
        print('Found package at: ${entity.parent.path}');
        packages.add(
          Package(
            name: entity.parent.path.split('/').last,
            path: entity.parent.path,
          ),
        );
      }
    }

    final packageDeps = <String, Set<String>>{};
    for (final package in packages) {
      final deps = getDependenciesFromPackage(package);
      packageDeps[package.name] = deps;
    }

    // Create a graph representation of package dependencies
    final graph = <String, Set<String>>{};
    for (final entry in packageDeps.entries) {
      // Initialize empty set if not exists
      graph.putIfAbsent(entry.key, () => <String>{});

      // Add all dependencies for this package
      for (final dep in entry.value) {
        graph[entry.key]!.add(dep);
      }
    }

    print(graph);
    findCircularDependencies(graph);
    findInvalidDependencies(graph, config);
  }

  Set<String> findInvalidDependencies(
    Map<String, Set<String>> graph,
    DependencyConfig config,
  ) {
    final invalidDependencies = <String>{};
    for (final entry in graph.entries) {
      final isCore = entry.key.startsWith('core_');
      final isFeature = entry.key.startsWith('feature_');
      for (final dep in entry.value) {
        if (isCore && dep.startsWith('feature_')) {
          invalidDependencies.add('${entry.key} -> $dep');
        }

        if (isFeature && dep.startsWith('feature_')) {
          invalidDependencies.add('${entry.key} -> $dep');
        }
      }
    }

    print('Found ${invalidDependencies.length} invalid dependencies:');
    for (final dep in invalidDependencies) {
      print(dep);
    }
    return invalidDependencies;
  }

  // Find circular dependencies using DFS
  Set<String> findCircularDependencies(Map<String, Set<String>> graph) {
    final visited = <String>{};
    final recursionStack = <String>{};
    final circularDependencies = <String>{};

    bool hasCycle(String node, Set<String> path) {
      visited.add(node);
      recursionStack.add(node);
      path.add(node);

      for (final neighbor in graph[node] ?? {}) {
        if (!visited.contains(neighbor)) {
          if (hasCycle(neighbor, path)) {
            return true;
          }
        } else if (recursionStack.contains(neighbor)) {
          print('Found circular dependency: ${path.join(' -> ')} -> $neighbor');
          circularDependencies.add('${path.join(' -> ')} -> $neighbor');
          return true;
        }
      }

      recursionStack.remove(node);
      return false;
    }

    // Check each unvisited node for cycles
    for (final node in graph.keys) {
      if (!visited.contains(node)) {
        hasCycle(node, <String>{});
      }
    }

    print('Found ${circularDependencies.length} circular dependencies:');
    for (final dep in circularDependencies) {
      print(dep);
    }
    return circularDependencies;
  }

  Set<String> getDependenciesFromPackage(Package package) {
    final pubspecFile = File('${package.path}/pubspec.yaml');
    if (!pubspecFile.existsSync()) return {};

    final pubspecContent = pubspecFile.readAsStringSync();
    final pubspec = loadYaml(pubspecContent) as Map;

    final dependencies = <String>{};

    if (pubspec['dependencies'] != null) {
      final deps = pubspec['dependencies'] as Map;
      dependencies.addAll(deps.keys.cast<String>());
    }

    if (pubspec['dev_dependencies'] != null) {
      final devDeps = pubspec['dev_dependencies'] as Map;
      dependencies.addAll(devDeps.keys.cast<String>());
    }
    print('Package ${package.name} has dependencies: $dependencies');

    return dependencies;
  }
}
