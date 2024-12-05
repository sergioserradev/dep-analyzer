import 'package:dep_analyzer/dependency_rule.dart';
import 'package:dep_analyzer/evaluation_error.dart';

class NoFeatureToFeatureRule extends DependencyRule {
  NoFeatureToFeatureRule({required super.allowed, required super.description})
      : super(name: 'no_feature_to_feature');

  @override
  void evaluate(Map<String, Set<String>> graph) {
    final noFeatureToFeature = <String>{};
    for (final entry in graph.entries) {
      final isFeature = entry.key.startsWith('feature_');
      for (final dep in entry.value) {
        if (isFeature && dep.startsWith('feature_')) {
          noFeatureToFeature.add('${entry.key} -> $dep');
        }
      }
    }

    print(
        '\x1B[${noFeatureToFeature.isEmpty ? '32' : '31'}mFound ${noFeatureToFeature.length} no_feature_to_feature dependencies: ${noFeatureToFeature.isEmpty ? '✅' : '❌'}\x1B[0m');
    for (final dep in noFeatureToFeature) {
      print(
          '  \x1B[${noFeatureToFeature.isEmpty ? '32' : '31'}m- $dep ${noFeatureToFeature.isEmpty ? '✅' : '❌'}\x1B[0m');
    }
    if (noFeatureToFeature.isNotEmpty) {
      throw EvaluationError('Found no_feature_to_feature dependencies: $noFeatureToFeature');
    }
  }
}