class RentalVehicle {
  final String id;
  final String name;
  final String type;
  final String price; // "₹159/hr"
  final String rating;
  final String? seats;
  final String image;
  final String category;
  final String? spec; // "90 km range"
  final bool isBike;
  final bool isComingSoon;

  RentalVehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.rating,
    this.seats,
    required this.image,
    required this.category,
    this.spec,
    this.isBike = false,
    this.isComingSoon = false,
  });

  factory RentalVehicle.fromMap(Map<String, dynamic> map, String documentId) {
    return RentalVehicle(
      id: documentId,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      price: map['price'] ?? '',
      rating: map['rating'] ?? '5.0',
      seats: map['seats'],
      image: map['image'] ?? '',
      category: map['category'] ?? '',
      spec: map['spec'],
      isBike: map['isBike'] ?? false,
      isComingSoon: map['isComingSoon'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'price': price,
      'rating': rating,
      'seats': seats,
      'image': image,
      'category': category,
      'spec': spec,
      'isBike': isBike,
      'isComingSoon': isComingSoon,
    };
  }
}
