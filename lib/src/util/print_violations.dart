import '../evaluation_error.dart';

void printViolations(Set<String> violations, String context) {
  print(
      '\x1B[${violations.isEmpty ? '32' : '31'}mFound ${violations.length} violations $context: ${violations.isEmpty ? '✅' : '❌'}\x1B[0m');
  for (final dep in violations) {
    print(
      '  \x1B[${violations.isEmpty ? '32' : '31'}m- $dep ${violations.isEmpty ? '✅' : '❌'}\x1B[0m',
    );
  }

  if (violations.isNotEmpty) {
    throw EvaluationError('Violation: $violations $context');
  }
}
