class Farm {
  final String id;
  final String name;
  final String? location;
  final String? contact;
  final String? phone;
  
  Farm({
    required this.id,
    required this.name,
    this.location,
    this.contact,
    this.phone,
  });
  
  factory Farm.fromJson(Map<String, dynamic> json) => Farm(
    id: json['id'],
    name: json['name'],
    location: json['location'],
    contact: json['contact'],
    phone: json['phone'],
  );
}
