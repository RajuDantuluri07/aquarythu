class Pond {
  final String id;
  final String name;

  Pond({
    required this.id,
    required this.name,
  });

  Pond copyWith({
    String? id,
    String? name,
  }) {
    return Pond(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}