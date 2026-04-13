class BannerOffer {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String cta;

  BannerOffer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.cta,
  });

  factory BannerOffer.fromMap(Map<String, dynamic> map, String documentId) {
    return BannerOffer(
      id: documentId,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      image: map['image_url'] ?? map['image'] ?? '',
      cta: map['cta'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'image_url': image,
      'cta': cta,
    };
  }
}
