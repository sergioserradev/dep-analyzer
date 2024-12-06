import 'package:collection/collection.dart';
import 'package:dep_analyzer/src/dependency_config.dart';
import 'package:dep_analyzer/src/rules/dependency_rule.dart';
import 'package:dep_analyzer/src/package.dart';
import 'package:dep_analyzer/src/util/print_violations.dart';

class PacakgeRule extends DependencyRule {
  final bool inverse;

  PacakgeRule({
    required super.allowed,
    required super.description,
    this.inverse = false,
    super.from,
    super.to,
  }) : super(name: 'no_feature_to_feature');

  void checkNoPackageToPackageInFolder(Map<Package, Set<String>> graph, Config config) {
    final noPackageToPackage = <String>{};

    final fromFolder = from!.split(':')[1];
    final toFolder = to!.split(':')[1];

    final packagesToEvaluate = graph.keys.where(
      (package) =>
          package.parent != null &&
          (package.parent!.endsWith(fromFolder) || package.parent!.endsWith(toFolder)),
    );

    for (final package in packagesToEvaluate) {
      for (final toPackage in packagesToEvaluate) {
        final toPackageDeps = graph[toPackage]!;
        if (toPackageDeps.contains(package.name)) {
          noPackageToPackage.add('${package.name} -> ${toPackage.name}');
        }
      }

      printViolations(noPackageToPackage, 'in folder $fromFolder');
    }
  }

  void checkNoPackageToPackageInPattern(Map<Package, Set<String>> graph, Config config) {
    final noPackageToPackage = <String>{};

    final fromPattern = RegExp(from!.split(':')[1]);
    final toPattern = RegExp(to!.split(':')[1]);

    final packagesToEvaluate = graph.keys.where(
      (package) => fromPattern.hasMatch(package.name) || toPattern.hasMatch(package.name),
    );

    for (final package in packagesToEvaluate) {
      for (final toPackage in packagesToEvaluate) {
        final toPackageDeps = graph[toPackage]!;
        if (toPackageDeps.contains(package.name)) {
          noPackageToPackage.add('${package.name} -> ${toPackage.name}');
        }
      }

      printViolations(noPackageToPackage, 'with pattern $fromPattern');
    }
  }

  void checkNoFeatureToFeature(Map<Package, Set<String>> graph, Config config) {
    final noPackageToPackage = <String>{};

    final fromFeature = from!.split(':')[1];
    final toFeature = to!.split(':')[1];

    final fromPackage = graph.keys.firstWhereOrNull((package) => fromFeature == package.name);
    final toPackage = graph.keys.firstWhereOrNull((package) => toFeature == package.name);

    if (fromPackage == null || toPackage == null) {
      return;
    }

    final fromPackageDeps = graph[fromPackage]!;
    final toPackageDeps = graph[toPackage]!;

    if (fromPackageDeps.contains(toFeature)) {
      noPackageToPackage.add('${toPackage.name} -> ${fromPackage.name}');
    }

    if (inverse) {
      if (toPackageDeps.contains(fromFeature)) {
        noPackageToPackage.add('${fromPackage.name} -> ${toPackage.name}');
      }
    }

    printViolations(noPackageToPackage, 'from $fromFeature to $toFeature');
  }

  @override
  void evaluate(Map<Package, Set<String>> graph, Config config) {
    final fromParts = from!.split(':');
    final fromType = fromParts[0];

    final checkFolder = fromType == 'folder';
    final checkPattern = fromType == 'pattern';
    final checkFeature = fromType == 'feature';

    if (checkFolder) {
      checkNoPackageToPackageInFolder(graph, config);
      return;
    }

    if (checkPattern) {
      checkNoPackageToPackageInPattern(graph, config);
      return;
    }

    if (checkFeature) {
      checkNoFeatureToFeature(graph, config);
      return;
    }
  }
}
