class Package {
  final String name;
  final String path;
  final String? parent;

  Package({required this.name, required this.path, this.parent});

  @override
  String toString() => 'Package(name: $name, path: $path, parent: $parent)';
}
