import 'dart:io';

import 'package:dep_analyzer/src/dependency_analyzer.dart';
import 'package:dep_analyzer/src/dependency_config.dart';

import 'package:args/args.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run dependency_analyzer <path_to_config> <project_path>');
    return;
  }

  final parser = ArgParser()
    ..addOption('config', abbr: 'c', defaultsTo: './config.yaml')
    ..addOption('project', abbr: 'p', mandatory: true)
    ..addFlag('graph', abbr: 'g', defaultsTo: false);

  final parsedArgs = parser.parse(args);

  final configPath = parsedArgs['config'] as String;
  final projectPath = parsedArgs['project'] as String;
  final graph = parsedArgs['graph'] as bool;
  final configFile = File(configPath);
  if (!configFile.existsSync()) {
    print('Error: Configuration file not found at $configPath');
    return;
  }

  final configContent = configFile.readAsStringSync();
  final config = Config.fromYaml(configContent);

  final analyzer = DependencyAnalyzer(config, printGraph: graph);
  analyzer.analyze(projectPath);

  print('Dependency analysis completed.');
}
