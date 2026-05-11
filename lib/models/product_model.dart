class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    required this.unit,
    this.imageUrl = '',
    this.barcode = '',
    this.lowStockLimit = 0,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final num buyPrice;
  final num sellPrice;
  final num stock;
  final String unit;
  final String imageUrl;
  final String barcode;
  final num lowStockLimit;
  final bool isActive;

  bool get isLowStock => stock <= lowStockLimit;
  bool get isOutOfStock => stock <= 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    categoryId: json['categoryId']?.toString() ?? '',
    categoryName: json['categoryName']?.toString() ?? '',
    buyPrice: num.tryParse(json['buyPrice']?.toString() ?? '') ?? 0,
    sellPrice: num.tryParse(json['sellPrice']?.toString() ?? '') ?? 0,
    stock: num.tryParse(json['stock']?.toString() ?? '') ?? 0,
    unit: json['unit']?.toString() ?? 'pcs',
    imageUrl: json['imageUrl']?.toString() ?? '',
    barcode: json['barcode']?.toString() ?? '',
    lowStockLimit: num.tryParse(json['lowStockLimit']?.toString() ?? '') ?? 0,
    isActive: json['isActive'] == true || json['isActive'].toString() == 'true',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'buyPrice': buyPrice,
    'sellPrice': sellPrice,
    'stock': stock,
    'unit': unit,
    'imageUrl': imageUrl,
    'barcode': barcode,
    'lowStockLimit': lowStockLimit,
    'isActive': isActive,
  };
}
