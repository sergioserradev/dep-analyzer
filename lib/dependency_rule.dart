import 'package:dep_analyzer/dependency_config.dart';
import 'package:dep_analyzer/no_circular_dependencies_rule.dart';
import 'package:dep_analyzer/no_core_to_feature_rule.dart';
import 'package:dep_analyzer/no_feature_to_feature_rule.dart';
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
        allowed: yaml['allowed'],
        description: yaml['description'],
      );
    } else if (yaml['name'] == 'no_core_to_feature') {
      return NoCoreToFeatureRule(
        allowed: yaml['allowed'],
        description: yaml['description'],
      );
    } else if (yaml['name'] == 'no_feature_to_feature') {
      return NoFeatureToFeatureRule(
        allowed: yaml['allowed'],
        description: yaml['description'],
        from: yaml['from'],
        to: yaml['to'],
      );
    }
    return null;
  }

  void evaluate(Map<Package, Set<String>> graph, Config config);
}
