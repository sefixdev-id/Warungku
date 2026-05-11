import '../core/helpers/date_helper.dart';

class StockLogModel {
  const StockLogModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.qty,
    required this.beforeStock,
    required this.afterStock,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final String productName;
  final String type;
  final num qty;
  final num beforeStock;
  final num afterStock;
  final String note;
  final DateTime createdAt;

  factory StockLogModel.fromJson(Map<String, dynamic> json) => StockLogModel(
    id: json['id']?.toString() ?? '',
    productId: json['productId']?.toString() ?? '',
    productName: json['productName']?.toString() ?? '',
    type: json['type']?.toString() ?? '',
    qty: num.tryParse(json['qty']?.toString() ?? '') ?? 0,
    beforeStock: num.tryParse(json['beforeStock']?.toString() ?? '') ?? 0,
    afterStock: num.tryParse(json['afterStock']?.toString() ?? '') ?? 0,
    note: json['note']?.toString() ?? '',
    createdAt: parseDate(json['createdAt']),
  );
}
