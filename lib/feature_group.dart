class FeatureGroup {
  final String name;
  final String? pattern;
  final List<String> features;
  final String? folder;

  FeatureGroup({required this.name, required this.features, this.pattern, this.folder});

  @override
  String toString() {
    return 'FeatureGroup(name: $name, features: $features, pattern: $pattern, folder: $folder)';
  }
}
