import 'package:dep_analyzer/dependency_config.dart';
import 'package:dep_analyzer/dependency_rule.dart';
import 'package:dep_analyzer/evaluation_error.dart';
import 'package:dep_analyzer/package.dart';

class NoFeatureToFeatureRule extends DependencyRule {
  NoFeatureToFeatureRule({
    required super.allowed,
    required super.description,
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

      print(
          '\x1B[${noPackageToPackage.isEmpty ? '32' : '31'}mFound ${noPackageToPackage.length} no_package_to_package dependencies in folder $fromFolder: ${noPackageToPackage.isEmpty ? '✅' : '❌'}\x1B[0m');
      for (final dep in noPackageToPackage) {
        print(
          '  \x1B[${noPackageToPackage.isEmpty ? '32' : '31'}m- $dep ${noPackageToPackage.isEmpty ? '✅' : '❌'}\x1B[0m',
        );
      }

      if (noPackageToPackage.isNotEmpty) {
        throw EvaluationError(
          'Found no_package_to_package dependencies: $noPackageToPackage in folder $fromFolder',
        );
      }
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

      print(
          '\x1B[${noPackageToPackage.isEmpty ? '32' : '31'}mFound ${noPackageToPackage.length} no_package_to_package dependencies with pattern $fromPattern: ${noPackageToPackage.isEmpty ? '✅' : '❌'}\x1B[0m');
      for (final dep in noPackageToPackage) {
        print(
          '  \x1B[${noPackageToPackage.isEmpty ? '32' : '31'}m- $dep ${noPackageToPackage.isEmpty ? '✅' : '❌'}\x1B[0m',
        );
      }

      if (noPackageToPackage.isNotEmpty) {
        throw EvaluationError(
          'Found no_package_to_package dependencies: $noPackageToPackage with pattern $fromPattern',
        );
      }
    }
  }

  @override
  void evaluate(Map<Package, Set<String>> graph, Config config) {
    final noFeatureToFeature = <String>{};

    final fromParts = from!.split(':');
    final fromType = fromParts[0];

    final checkFolder = fromType == 'folder';
    final checkPattern = fromType == 'pattern';

    if (checkFolder) {
      checkNoPackageToPackageInFolder(graph, config);
      return;
    }

    if (checkPattern) {
      checkNoPackageToPackageInPattern(graph, config);
      return;
    }
  }
}
