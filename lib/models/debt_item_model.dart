class DebtItemModel {
  const DebtItemModel({
    required this.id,
    required this.debtId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.qty,
    required this.unit,
    required this.subtotal,
  });

  final String id;
  final String debtId;
  final String productId;
  final String productName;
  final num price;
  final num qty;
  final String unit;
  final num subtotal;

  factory DebtItemModel.fromJson(Map<String, dynamic> json) => DebtItemModel(
    id: json['id']?.toString() ?? '',
    debtId: json['debtId']?.toString() ?? '',
    productId: json['productId']?.toString() ?? '',
    productName: json['productName']?.toString() ?? '',
    price: num.tryParse(json['price']?.toString() ?? '') ?? 0,
    qty: num.tryParse(json['qty']?.toString() ?? '') ?? 0,
    unit: json['unit']?.toString() ?? '',
    subtotal: num.tryParse(json['subtotal']?.toString() ?? '') ?? 0,
  );
}
