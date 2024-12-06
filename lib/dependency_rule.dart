import 'package:dep_analyzer/dependency_config.dart';
import 'package:dep_analyzer/no_circular_dependencies_rule.dart';
import 'package:dep_analyzer/package_rule.dart';
import 'package:dep_analyzer/package.dart';
import 'package:yaml/yaml.dart';

abstract class DependencyRule {
  final String name;
  final String description;
  final bool allowed;
  final String? from;
  final String? to;

  DependencyRule({
    required this.name,
    required this.description,
    required this.allowed,
    this.from,
    this.to,
  });

  static DependencyRule? fromYaml(YamlMap yaml) {
    if (yaml['name'] == 'no_circular_dependencies') {
      return NoCircularDependenciesRule(
        allowed: yaml['allowed'] ?? false,
        description: yaml['description'],
      );
    }
    if (yaml['name'] == 'no_feature_to_feature') {
      return PacakgeRule(
        description: yaml['description'],
        from: yaml['from'],
        to: yaml['to'],
        allowed: yaml['allowed'] ?? false,
        inverse: yaml['inverse'] ?? false,
      );
    }
    return null;
  }

  void evaluate(Map<Package, Set<String>> graph, Config config);
}
