import '../core/helpers/date_helper.dart';

class OrderItemModel {
  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.qty,
    required this.unit,
    required this.subtotal,
    required this.createdAt,
  });

  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final num price;
  final num qty;
  final String unit;
  final num subtotal;
  final DateTime createdAt;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    id: json['id']?.toString() ?? '',
    orderId: json['orderId']?.toString() ?? '',
    productId: json['productId']?.toString() ?? '',
    productName: json['productName']?.toString() ?? '',
    price: num.tryParse(json['price']?.toString() ?? '') ?? 0,
    qty: num.tryParse(json['qty']?.toString() ?? '') ?? 0,
    unit: json['unit']?.toString() ?? '',
    subtotal: num.tryParse(json['subtotal']?.toString() ?? '') ?? 0,
    createdAt: parseDate(json['createdAt']),
  );
}
