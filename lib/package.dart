class Package {
  final String name;
  final String path;

  Package({required this.name, required this.path});

  @override
  String toString() => 'Package(name: $name, path: $path)';
}
