import 'package:dep_analyzer/dependency_config.dart';

class DependencyAnalyzer {
  final DependencyConfig config;

  DependencyAnalyzer(this.config);

  void analyze(String projectPath) {
    print('Analyzing project at $projectPath');
  }
}
