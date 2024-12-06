import 'evaluation_error.dart';

void printViolations(Set<String> violations, String context) {
  print(
      '\x1B[${violations.isEmpty ? '32' : '31'}mFound ${violations.length} no_package_to_package dependencies $context: ${violations.isEmpty ? '✅' : '❌'}\x1B[0m');
  for (final dep in violations) {
    print(
      '  \x1B[${violations.isEmpty ? '32' : '31'}m- $dep ${violations.isEmpty ? '✅' : '❌'}\x1B[0m',
    );
  }

  if (violations.isNotEmpty) {
    throw EvaluationError(
      'Found no_package_to_package dependencies: $violations $context',
    );
  }
}
