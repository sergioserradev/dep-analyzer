import 'dart:io';

import 'package:dep_analyzer/dependency_config.dart';

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

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('pubspec.yaml')) {
        print('Found package at: ${entity.parent.path}');
      }
    }
  }
}
