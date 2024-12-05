class FeatureGroup {
  final String name;
  final String? pattern;
  final List<String> features;

  FeatureGroup({required this.name, required this.features, this.pattern});

  @override
  String toString() {
    return 'FeatureGroup(name: $name, features: $features, pattern: $pattern)';
  }
}
