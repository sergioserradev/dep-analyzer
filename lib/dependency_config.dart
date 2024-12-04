import 'package:yaml/yaml.dart';

class DependencyConfig {
  final List<FeatureGroup> groups;

  DependencyConfig({required this.groups});

  static DependencyConfig fromYaml(String yaml) {
    final yamlMap = loadYaml(yaml) as Map;

    final groups = <FeatureGroup>[];
    for (final group in yamlMap['groups']) {
      final groupName = group['name'];
      final packages = List<String>.from(group.values.expand((e) => e));
      groups.add(FeatureGroup(name: groupName, features: packages));
    }

    return DependencyConfig(groups: groups);
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
