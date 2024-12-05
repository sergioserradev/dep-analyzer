import 'package:dep_analyzer/dependency_config.dart';
import 'package:dep_analyzer/dependency_rule.dart';
import 'package:dep_analyzer/evaluation_error.dart';

class NoCircularDependenciesRule extends DependencyRule {
  NoCircularDependenciesRule({required super.allowed, required super.description})
      : super(name: 'no_circular_dependencies');

  @override
  void evaluate(Map<String, Set<String>> graph, Config config) {
    final circularDependencies = _findCircularDependencies(graph);
    if (circularDependencies.isNotEmpty) {
      throw EvaluationError('Found circular dependencies: $circularDependencies');
    }
  }

  // Find circular dependencies using DFS
  Set<String> _findCircularDependencies(Map<String, Set<String>> graph) {
    final visited = <String>{};
    final recursionStack = <String>{};
    final circularDependencies = <String>{};

    bool hasCycle(String node, Set<String> path) {
      visited.add(node);
      recursionStack.add(node);
      path.add(node);

      for (final neighbor in graph[node] ?? {}) {
        if (!visited.contains(neighbor)) {
          if (hasCycle(neighbor, path)) {
            return true;
          }
        } else if (recursionStack.contains(neighbor)) {
          circularDependencies.add('${path.join(' -> ')} -> $neighbor');
          return true;
        }
      }

      recursionStack.remove(node);
      return false;
    }

    // Check each unvisited node for cycles
    for (final node in graph.keys) {
      if (!visited.contains(node)) {
        hasCycle(node, <String>{});
      }
    }

    print(
        '\x1B[${circularDependencies.isEmpty ? '32' : '31'}mFound ${circularDependencies.length} circular dependencies: ${circularDependencies.isEmpty ? '✅' : '❌'}\x1B[0m');
    for (final dep in circularDependencies) {
      print(
          '  \x1B[${circularDependencies.isEmpty ? '32' : '31'}m- $dep ${circularDependencies.isEmpty ? '✅' : '❌'}\x1B[0m');
    }
    return circularDependencies;
  }
}
