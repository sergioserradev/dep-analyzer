class FeatureGroup {
  final String name;
  final List<String> features;

  FeatureGroup({required this.name, required this.features});

  @override
  String toString() {
    return 'FeatureGroup(name: $name, features: $features)';
  }
}
