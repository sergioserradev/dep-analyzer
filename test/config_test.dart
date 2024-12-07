import 'package:dep_analyzer/src/config.dart';
import 'package:test/test.dart';

void main() {
  group('Config', () {
    test('fromYaml should parse valid configuration', () {
      const yamlString = '''
rules:
  - key: "no_circular_dependencies"
    description: "Circular dependencies are not allowed"
  
  - key: "no_package_to_package"
    description: "Features cannot depend on other features"
    from: "pattern:feature_*"
    to: "pattern:feature_*"
''';

      final config = Config.fromYaml(yamlString);

      expect(config.rules, hasLength(2));
      expect(config.rules[0].name, equals('no_circular_dependencies'));
      expect(config.rules[0].description, equals('Circular dependencies are not allowed'));

      expect(config.rules[1].name, equals('no_package_to_package'));
      expect(config.rules[1].from, equals('pattern:feature_*'));
      expect(config.rules[1].to, equals('pattern:feature_*'));
    });

    test('fromYaml should handle rules with inverse property', () {
      const yamlString = '''
rules:
  - key: "no_package_to_package"
    description: "Feature b cannot depend on feature a and vice versa"
    from: "feature:feature_b"
    to: "feature:feature_a"
    inverse: true
''';

      final config = Config.fromYaml(yamlString);

      expect(config.rules, hasLength(1));
      expect(config.rules[0].name, equals('no_package_to_package'));
      expect(config.rules[0].from, equals('feature:feature_b'));
      expect(config.rules[0].to, equals('feature:feature_a'));
    });

    test('toString should return formatted string representation', () {
      final config = Config(rules: []);
      expect(config.toString(), equals('DependencyConfig(rules: [])'));
    });

    test('fromYaml should handle empty rules list', () {
      const yamlString = '''
rules: []
''';

      final config = Config.fromYaml(yamlString);
      expect(config.rules, isEmpty);
    });
  });
}
