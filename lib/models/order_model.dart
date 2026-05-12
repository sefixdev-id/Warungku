import '../core/helpers/date_helper.dart';
import 'order_item_model.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.orderType,
    required this.addressId,
    required this.addressSnapshot,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.totalAmount,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.confirmedByAdminId,
    this.items = const [],
  });

  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String orderType;
  final String addressId;
  final String addressSnapshot;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final num totalAmount;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String confirmedByAdminId;
  final List<OrderItemModel> items;

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id']?.toString() ?? '',
    userId: json['userId']?.toString() ?? '',
    userName: json['userName']?.toString() ?? '',
    userPhone: json['userPhone']?.toString() ?? '',
    orderType: json['orderType']?.toString() ?? 'pickup',
    addressId: json['addressId']?.toString() ?? '',
    addressSnapshot: json['addressSnapshot']?.toString() ?? '',
    paymentMethod: json['paymentMethod']?.toString() ?? 'cash_store',
    paymentStatus: json['paymentStatus']?.toString() ?? 'belum_dibayar',
    orderStatus: json['orderStatus']?.toString() ?? 'diterima',
    totalAmount: num.tryParse(json['totalAmount']?.toString() ?? '') ?? 0,
    note: json['note']?.toString() ?? '',
    createdAt: parseDate(json['createdAt']),
    updatedAt: parseDate(json['updatedAt']),
    confirmedByAdminId: json['confirmedByAdminId']?.toString() ?? '',
    items: (json['items'] as List? ?? [])
        .whereType<Map>()
        .map((item) => OrderItemModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
  );
}
