class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.icon = '',
    this.isActive = true,
  });

  final String id;
  final String name;
  final String icon;
  final bool isActive;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    icon: json['icon']?.toString() ?? '',
    isActive: json['isActive'] == true || json['isActive'].toString() == 'true',
  );
}
