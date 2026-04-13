class ServiceItem {
  final String id;
  final String title;
  final String desc;
  final String price; // Storing as string because it contains formatting like "₹2,499"
  final double rating;
  final String image;
  final String duration;
  final String category;

  ServiceItem({
    required this.id,
    required this.title,
    required this.desc,
    required this.price,
    required this.rating,
    required this.image,
    required this.duration,
    required this.category,
  });

  factory ServiceItem.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceItem(
      id: documentId,
      title: map['title'] ?? '',
      desc: map['desc'] ?? '',
      price: map['price']?.toString() ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
      image: map['image_url'] ?? map['image'] ?? '',
      duration: map['duration'] ?? '',
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'desc': desc,
      'price': price,
      'rating': rating,
      'image_url': image,
      'duration': duration,
      'category': category,
    };
  }
}
