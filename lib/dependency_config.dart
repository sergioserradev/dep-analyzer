import 'package:dep_analyzer/dependency_rule.dart';
import 'package:yaml/yaml.dart';

class Config {
  final List<DependencyRule> rules;

  Config({required this.rules});

  static Config fromYaml(String yaml) {
    final yamlMap = loadYaml(yaml) as Map;

    final rules = <DependencyRule>[];
    for (final rule in yamlMap['rules']) {
      final ruleInstance = DependencyRule.fromYaml(rule as YamlMap);
      if (ruleInstance != null) {
        rules.add(ruleInstance);
      }
    }

    return Config(rules: rules);
  }

  @override
  String toString() {
    return 'DependencyConfig(rules: $rules)';
  }
}
