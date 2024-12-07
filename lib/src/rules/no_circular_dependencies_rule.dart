import 'package:collection/collection.dart';
import 'package:dep_analyzer/src/config.dart';
import 'package:dep_analyzer/src/rules/dependency_rule.dart';
import 'package:dep_analyzer/src/evaluation_error.dart';
import 'package:dep_analyzer/src/package.dart';
import 'package:dep_analyzer/src/util/print_violations.dart';

class NoCircularDependenciesRule extends DependencyRule {
  NoCircularDependenciesRule({required super.description})
      : super(name: 'no_circular_dependencies');

  @override
  void evaluate(Map<Package, Set<String>> graph, Config config) {
    final circularDependencies = _findCircularDependencies(graph);
    if (circularDependencies.isNotEmpty) {
      throw EvaluationError('Found circular dependencies: $circularDependencies');
    }
  }

  // Find circular dependencies using DFS
  Set<String> _findCircularDependencies(Map<Package, Set<String>> graph) {
    final visited = <String>{};
    final recursionStack = <String>{};
    final circularDependencies = <String>{};

    bool hasCycle(String nodeName, Set<String> path) {
      visited.add(nodeName);
      recursionStack.add(nodeName);
      path.add(nodeName);

      final node = graph.keys.firstWhereOrNull((e) => e.name == nodeName);
      if (node == null) {
        recursionStack.remove(nodeName);
        return false;
      }

      for (final neighbor in graph[node]!) {
        if (!visited.contains(neighbor)) {
          if (hasCycle(neighbor, path)) {
            return true;
          }
        } else if (recursionStack.contains(neighbor)) {
          circularDependencies.add('${path.join(' -> ')} -> $neighbor');
          return true;
        }
      }

      recursionStack.remove(nodeName);
      return false;
    }

    // Check each unvisited node for cycles
    for (final node in graph.keys) {
      if (!visited.contains(node.name)) {
        hasCycle(node.name, <String>{});
      }
    }

    printViolations(circularDependencies, 'circular dependencies');

    return circularDependencies;
  }
}
