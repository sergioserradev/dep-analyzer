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
    final errors = <String>{};
    for (var rule in config.rules) {
      try {
        rule.evaluate(graph);
      } on EvaluationError catch (e) {
        errors.add(e.message);
      } catch (e) {
        print('Error evaluating rule ${rule.name}: $e');
        exit(1);
      }
    }

    if (errors.isNotEmpty) {
      print('Found ${errors.length} errors:');
      for (final error in errors) {
        print(error);
      }
    }
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

class EvaluationError extends Error {
  final String message;

  EvaluationError(this.message);
}

abstract class DependencyRule {
  final String name;
  final String description;
  final bool allowed;

  DependencyRule({required this.name, required this.description, required this.allowed});

  static DependencyRule fromYaml(YamlMap yaml) {
    print(yaml);
    if (yaml['name'] == 'no_circular_dependencies') {
      return NoCircularDependenciesRule(allowed: yaml['allowed'], description: yaml['description']);
    } else if (yaml['name'] == 'no_core_to_feature') {
      return NoCoreToFeatureRule(allowed: yaml['allowed'], description: yaml['description']);
    } else if (yaml['name'] == 'no_feature_to_feature') {
      return NoFeatureToFeatureRule(allowed: yaml['allowed'], description: yaml['description']);
    }
    throw ArgumentError('Unknown rule: ${yaml['name']}');
  }

  void evaluate(Map<String, Set<String>> graph);
}

class NoCircularDependenciesRule extends DependencyRule {
  NoCircularDependenciesRule({required super.allowed, required super.description})
      : super(name: 'no_circular_dependencies');

  @override
  void evaluate(Map<String, Set<String>> graph) {
    final circularDependencies = _findCircularDependencies(graph);
    if (circularDependencies.isNotEmpty) {
      throw EvaluationError('Found circular dependencies: $circularDependencies');
    }
  }

  // Find circular dependencies using DFS
  Set<String> _findCircularDependencies(Map<String, Set<String>> graph) {
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
}

class NoCoreToFeatureRule extends DependencyRule {
  NoCoreToFeatureRule({required super.allowed, required super.description})
      : super(name: 'no_core_to_feature');

  @override
  void evaluate(Map<String, Set<String>> graph) {
    final noCoreToFeature = <String>{};
    for (final entry in graph.entries) {
      final isCore = entry.key.startsWith('core_');
      for (final dep in entry.value) {
        final isFeature = dep.startsWith('feature_');
        if (isCore && isFeature) {
          noCoreToFeature.add('${entry.key} -> $dep');
        }
      }
    }
    print('Found ${noCoreToFeature.length} no core to feature dependencies:');
    for (final dep in noCoreToFeature) {
      print(dep);
    }
    if (noCoreToFeature.isNotEmpty) {
      throw EvaluationError('Found no_core_to_feature dependencies: $noCoreToFeature');
    }
  }
}

class NoFeatureToFeatureRule extends DependencyRule {
  NoFeatureToFeatureRule({required super.allowed, required super.description})
      : super(name: 'no_feature_to_feature');

  @override
  void evaluate(Map<String, Set<String>> graph) {
    final noFeatureToFeature = <String>{};
    for (final entry in graph.entries) {
      final isFeature = entry.key.startsWith('feature_');
      for (final dep in entry.value) {
        if (isFeature && dep.startsWith('feature_')) {
          noFeatureToFeature.add('${entry.key} -> $dep');
        }
      }
    }

    print('Found ${noFeatureToFeature.length} no feature to feature dependencies:');
    for (final dep in noFeatureToFeature) {
      print(dep);
    }
    if (noFeatureToFeature.isNotEmpty) {
      throw EvaluationError('Found no_feature_to_feature dependencies: $noFeatureToFeature');
    }
  }
}
