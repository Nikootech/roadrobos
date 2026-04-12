class ServiceCategory {
  final String id;
  final String icon;
  final String label;
  final String count;

  ServiceCategory({
    required this.id,
    required this.icon,
    required this.label,
    required this.count,
  });

  factory ServiceCategory.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceCategory(
      id: documentId,
      icon: map['icon'] ?? '',
      label: map['label'] ?? '',
      count: map['count'] ?? '0',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'icon': icon,
      'label': label,
      'count': count,
    };
  }
}
