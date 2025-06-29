// FILE: lapangan_model.dart
class Gor {
  final int? id; // Pastikan id nullable untuk fleksibilitas
  final String name;
  final String location;
  final String price;
  final double rating;
  final String image;
  final String facility;

  Gor({
    this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.image,
    this.facility = '',
  });

  factory Gor.fromJson(Map<String, dynamic> json) {
    return Gor(
      id: json['id'],
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      image: json['image'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      price: json['price'] ?? '',
      facility: json['facility'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'price': price,
      'rating': rating,
      'image': image,
      'facility': facility,
    };
  }
}
