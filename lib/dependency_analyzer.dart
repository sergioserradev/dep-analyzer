import 'dart:io';

import 'package:dep_analyzer/dependency_config.dart';
import 'package:dep_analyzer/dependency_rule.dart';
import 'package:dep_analyzer/evaluation_error.dart';
import 'package:dep_analyzer/package.dart';
import 'package:yaml/yaml.dart';

class DependencyAnalyzer {
  final DependencyConfig config;
  final List<DependencyRule> rules;

  DependencyAnalyzer(this.config, {this.rules = const []});

  void analyze(String projectPath) async {
    print('\x1B[32mAnalyzing project at $projectPath 📦\x1B[0m');
    final dir = Directory(projectPath);
    if (!dir.existsSync()) {
      print('\x1B[31mError: Project directory not found at $projectPath ❌\x1B[0m');
      return;
    }

    final packages = <Package>{};
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('pubspec.yaml')) {
        print('\x1B[32mFound package at: ${entity.parent.path} 📦\x1B[0m');
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

    print('\nDependency Graph:');
    for (final entry in graph.entries) {
      print('${entry.key}:');
      for (final dep in entry.value) {
        print('  └─ $dep');
      }
      print('');
    }

    final errors = <String>{};
    final allRules = [...config.rules, ...rules];
    for (final rule in allRules) {
      try {
        rule.evaluate(graph);
      } on EvaluationError catch (e) {
        errors.add(e.message);
      } catch (e) {
        print('\x1B[31mError evaluating rule ${rule.name}: $e ❌\x1B[0m');
        exit(1);
      }
    }

    print('\n');
    if (errors.isNotEmpty) {
      print('\x1B[31mFound ${errors.length} errors: ❌\x1B[0m');
      for (final error in errors) {
        print('\x1B[33m  - $error\x1B[0m');
      }
    } else {
      print('\x1B[32mNo errors found: ✅\x1B[0m');
    }

    exit(errors.isNotEmpty ? 1 : 0);
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

    return dependencies;
  }
}
