import 'dart:io';

import 'package:dep_analyzer/dependency_rule.dart';
import 'package:dep_analyzer/feature_group.dart';
import 'package:yaml/yaml.dart';

class Config {
  final List<FeatureGroup> groups;
  final List<DependencyRule> rules;

  Config({required this.groups, required this.rules});

  static Config fromYaml(String yaml) {
    final yamlMap = loadYaml(yaml) as Map;

    final groups = <FeatureGroup>[];
    for (final group in yamlMap['groups']) {
      final groupName = group['name'];
      final pattern = group['pattern'];
      final features = group['features'];

      if (pattern != null && features != null) {
        print(
          'Group $groupName in YAML config must have either a "pattern" or "features" key, not both',
        );
        exit(1);
      }

      groups.add(FeatureGroup(name: groupName, features: [], pattern: pattern));
      if (features != null) {
        for (final feature in features) {
          groups.last.features.add(feature);
        }
      }
    }

    final rules = <DependencyRule>[];
    for (final rule in yamlMap['rules']) {
      final ruleInstance = DependencyRule.fromYaml(rule as YamlMap);
      if (ruleInstance != null) {
        rules.add(ruleInstance);
      }
    }

    return Config(groups: groups, rules: rules);
  }

  @override
  String toString() {
    return 'DependencyConfig(groups: $groups)';
  }
}
