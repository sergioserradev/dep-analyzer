import 'package:dep_analyzer/dependency_rule.dart';
import 'package:dep_analyzer/feature_group.dart';
import 'package:yaml/yaml.dart';

class DependencyConfig {
  final List<FeatureGroup> groups;
  final List<DependencyRule> rules;

  DependencyConfig({required this.groups, required this.rules});

  static DependencyConfig fromYaml(String yaml) {
    final yamlMap = loadYaml(yaml) as Map;

    final groups = <FeatureGroup>[];
    for (final group in yamlMap['groups']) {
      final groupName = group['name'];
      final features = group['features'];
      for (final feature in features) {
        groups.add(FeatureGroup(name: groupName, features: [feature]));
      }
    }

    final rules = <DependencyRule>[];
    for (final rule in yamlMap['rules']) {
      final ruleInstance = DependencyRule.fromYaml(rule as YamlMap);
      if (ruleInstance != null) {
        rules.add(ruleInstance);
      }
    }

    return DependencyConfig(groups: groups, rules: rules);
  }

  @override
  String toString() {
    return 'DependencyConfig(groups: $groups)';
  }
}
