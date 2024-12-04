import 'dart:io';

import 'package:dep_analyzer/dependency_analyzer.dart';
import 'package:dep_analyzer/dependency_config.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run dependency_analyzer <path_to_config> <project_path>');
    return;
  }

  final configPath = args[0];
  final projectPath = args[1];

  final configFile = File(configPath);
  if (!configFile.existsSync()) {
    print('Error: Configuration file not found at $configPath');
    return;
  }

  final configContent = configFile.readAsStringSync();
  final config = DependencyConfig.fromYaml(configContent);

  final analyzer = DependencyAnalyzer(config);
  analyzer.analyze(projectPath);

  print('Dependency analysis completed.');
}
