import 'package:dep_analyzer/dependency_analyzer.dart';
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
      rules.add(DependencyRule.fromYaml(rule as YamlMap));
    }

    return DependencyConfig(groups: groups, rules: rules);
  }

  @override
  String toString() {
    return 'DependencyConfig(groups: $groups)';
  }
}

class FeatureGroup {
  final String name;
  final List<String> features;

  FeatureGroup({required this.name, required this.features});

  @override
  String toString() {
    return 'FeatureGroup(name: $name, features: $features)';
  }
}
