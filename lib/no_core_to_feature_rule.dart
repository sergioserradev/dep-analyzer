import 'package:dep_analyzer/dependency_rule.dart';
import 'package:dep_analyzer/evaluation_error.dart';

class NoCoreToFeatureRule extends DependencyRule {
  NoCoreToFeatureRule({required super.allowed, required super.description})
      : super(name: 'no_core_to_feature');

  @override
  void evaluate(Map<String, Set<String>> graph) {
    final noCoreToFeature = <String>{};
    for (final entry in graph.entries) {
      final isCore = entry.key.startsWith('core_');
      for (final dep in entry.value) {
        final isFeature = dep.startsWith('feature_');
        if (isCore && isFeature) {
          noCoreToFeature.add('${entry.key} -> $dep');
        }
      }
    }
    print(
        '\x1B[${noCoreToFeature.isEmpty ? '32' : '31'}mFound ${noCoreToFeature.length} no_core_to_feature dependencies: ${noCoreToFeature.isEmpty ? '✅' : '❌'}\x1B[0m');
    for (final dep in noCoreToFeature) {
      print(
          '  \x1B[${noCoreToFeature.isEmpty ? '32' : '31'}m- $dep ${noCoreToFeature.isEmpty ? '✅' : '❌'}\x1B[0m');
    }
    if (noCoreToFeature.isNotEmpty) {
      throw EvaluationError('Found no_core_to_feature dependencies: $noCoreToFeature');
    }
  }
}
