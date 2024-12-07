import 'package:dep_analyzer/src/rules/no_circular_dependencies_rule.dart';
import 'package:dep_analyzer/src/rules/package_rule.dart';
import 'package:test/test.dart';
import 'package:dep_analyzer/src/dependency_analyzer.dart';
import 'package:dep_analyzer/src/config.dart';
import 'package:dep_analyzer/src/package.dart';
import 'dart:io';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('dep_analyzer_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('getDependenciesFromPackage returns empty set for non-existent pubspec', () {
    final analyzer = DependencyAnalyzer(Config(rules: []));
    final package = Package(
      name: 'test_package',
      path: 'non/existent/path',
      parent: 'non/existent',
    );

    final deps = analyzer.getDependenciesFromPackage(package);
    expect(deps, isEmpty);
  });

  test('getDependenciesFromPackage correctly parses dependencies', () {
    final pubspecContent = '''
name: test_package
dependencies:
  flutter:
    sdk: flutter
  package_a: ^1.0.0
dev_dependencies:
  test: ^1.0.0
''';

    final packageDir = Directory('${tempDir.path}/test_package')..createSync();
    File('${packageDir.path}/pubspec.yaml').writeAsStringSync(pubspecContent);

    final analyzer = DependencyAnalyzer(Config(rules: []));
    final package = Package(
      name: 'test_package',
      path: packageDir.path,
      parent: tempDir.path,
    );

    final deps = analyzer.getDependenciesFromPackage(package);
    expect(deps, containsAll(['flutter', 'package_a', 'test']));
    expect(deps.length, 3);
  });

  test('analyze finds packages in directory structure', () async {
    // Create a mock project structure
    final projectDir = Directory('${tempDir.path}/mock_project')..createSync();
    final package1Dir = Directory('${projectDir.path}/package1')..createSync();
    final package2Dir = Directory('${projectDir.path}/package2')..createSync();

    File('${package1Dir.path}/pubspec.yaml').writeAsStringSync('''
name: package1
dependencies:
  package2:
    path: ../package2
''');

    File('${package2Dir.path}/pubspec.yaml').writeAsStringSync('''
name: package2
dependencies:
  some_package: ^1.0.0
''');

    final analyzer = DependencyAnalyzer(Config(rules: []), printGraph: true);
    final errors = await analyzer.analyze(projectDir.path);

    expect(errors, isEmpty);
  });

  test('analyze finds circular dependencies', () async {
    // Create a mock project structure
    final projectDir = Directory('${tempDir.path}/mock_project')..createSync();
    final package1Dir = Directory('${projectDir.path}/package1')..createSync();
    final package2Dir = Directory('${projectDir.path}/package2')..createSync();

    File('${package1Dir.path}/pubspec.yaml').writeAsStringSync('''
name: package1
dependencies:
  package2:
    path: ../package2
''');

    File('${package2Dir.path}/pubspec.yaml').writeAsStringSync('''
name: package2
dependencies:
  package1:
    path: ../package1
''');

    final analyzer = DependencyAnalyzer(
      Config(rules: [NoCircularDependenciesRule(description: 'no circular dependencies')]),
      printGraph: false,
    );

    final errors = await analyzer.analyze(projectDir.path);
    expect(errors, isNotEmpty);
    expect(errors.first, 'Violation: {package2 -> package1 -> package2} circular dependencies');
  });

  test('analyze finds package to package feature violation', () async {
    // Create a mock project structure
    final projectDir = Directory('${tempDir.path}/mock_project')..createSync();
    final package1Dir = Directory('${projectDir.path}/package1')..createSync();
    final package2Dir = Directory('${projectDir.path}/package2')..createSync();

    File('${package1Dir.path}/pubspec.yaml').writeAsStringSync('''
name: package1
dependencies:
  package2:
    path: ../package2
''');

    File('${package2Dir.path}/pubspec.yaml').writeAsStringSync('''
name: package2
dependencies:
  package1:
    path: ../package1
''');

    final analyzer = DependencyAnalyzer(
      Config(rules: [
        PackageRule(
          description: 'no feature to package violation',
          from: 'feature:package1',
          to: 'feature:package2',
        )
      ]),
      printGraph: false,
    );

    final errors = await analyzer.analyze(projectDir.path);
    expect(errors, isNotEmpty);
    expect(errors.first, 'Violation: {package2 -> package1} from package1 to package2');
  });

  test('analyze finds package to package folder violation', () async {
    // Create a mock project structure
    final projectDir = Directory('${tempDir.path}/mock_project')..createSync();
    final package1Dir = Directory('${projectDir.path}/package1')..createSync();
    final package2Dir = Directory('${projectDir.path}/package2')..createSync();

    File('${package1Dir.path}/pubspec.yaml').writeAsStringSync('''
name: package1
dependencies:
  package2:
    path: ../package2
''');

    File('${package2Dir.path}/pubspec.yaml').writeAsStringSync('''
name: package2
dependencies:
  package1:
    path: ../package1
''');

    final analyzer = DependencyAnalyzer(
      Config(rules: [
        PackageRule(
          description: 'no package to package folder violation',
          from: 'folder:mock_project',
          to: 'folder:mock_project',
        )
      ]),
      printGraph: false,
    );

    final errors = await analyzer.analyze(projectDir.path);
    expect(errors, isNotEmpty);
    expect(errors.first, 'Violation: {package2 -> package1} in folder mock_project');
  });
}
