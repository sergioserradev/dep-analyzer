import 'package:dep_analyzer/src/config.dart';
import 'package:dep_analyzer/src/rules/no_circular_dependencies_rule.dart';
import 'package:dep_analyzer/src/rules/package_rule.dart';
import 'package:dep_analyzer/src/package.dart';
import 'package:yaml/yaml.dart';

abstract class DependencyRule {
  final String name;
  final String description;
  final String? from;
  final String? to;

  DependencyRule({
    required this.name,
    required this.description,
    this.from,
    this.to,
  });

  static DependencyRule? fromYaml(YamlMap yaml) {
    if (yaml['key'] == 'no_circular_dependencies') {
      return NoCircularDependenciesRule(description: yaml['description']);
    }
    if (yaml['key'] == 'no_package_to_package') {
      return PackageRule(
        description: yaml['description'],
        from: yaml['from'],
        to: yaml['to'],
        inverse: yaml['inverse'] ?? false,
      );
    }
    return null;
  }

  void evaluate(Map<Package, Set<String>> graph, Config config);
}
