import 'dart:io';

import 'package:dep_analyzer/dependency_analyzer.dart';
import 'package:dep_analyzer/dependency_config.dart';

import 'package:args/args.dart';
import 'package:dep_analyzer/dependency_rule.dart';
import 'package:dep_analyzer/evaluation_error.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run dependency_analyzer <path_to_config> <project_path>');
    return;
  }

  final parser = ArgParser()
    ..addOption('config', abbr: 'c', defaultsTo: './config.yaml')
    ..addOption('project', abbr: 'p', mandatory: true);

  final parsedArgs = parser.parse(args);

  final configPath = parsedArgs['config'] as String;
  final projectPath = parsedArgs['project'] as String;

  final configFile = File(configPath);
  if (!configFile.existsSync()) {
    print('Error: Configuration file not found at $configPath');
    return;
  }

  final configContent = configFile.readAsStringSync();
  final config = Config.fromYaml(configContent);

  final analyzer = DependencyAnalyzer(config, rules: [CoreToCoreRule()]);
  analyzer.analyze(projectPath);

  print('Dependency analysis completed.');
}

class CoreToCoreRule extends DependencyRule {
  CoreToCoreRule()
      : super(
          name: 'core_to_core',
          allowed: false,
          description: 'Core modules can depend on other core modules',
        );

  @override
  void evaluate(Map<String, Set<String>> graph, Config config) {
    for (final entry in graph.entries) {
      if (entry.key.startsWith('core_') && entry.value.any((dep) => dep.startsWith('core_'))) {
        throw EvaluationError(
          'Core module ${entry.key} depends on another core module ${entry.value}',
        );
      }
    }
    print('\x1B[32mFound 0 core_to_core dependencies found ✅\x1B[0m');
  }
}
