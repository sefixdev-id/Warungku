import '../core/helpers/date_helper.dart';
import 'debt_item_model.dart';
import 'debt_payment_model.dart';

class DebtModel {
  const DebtModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.totalDebt,
    required this.paidAmount,
    required this.remainingDebt,
    required this.status,
    required this.note,
    required this.createdAt,
    this.items = const [],
    this.payments = const [],
  });

  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final num totalDebt;
  final num paidAmount;
  final num remainingDebt;
  final String status;
  final String note;
  final DateTime createdAt;
  final List<DebtItemModel> items;
  final List<DebtPaymentModel> payments;

  factory DebtModel.fromJson(Map<String, dynamic> json) => DebtModel(
    id: json['id']?.toString() ?? '',
    userId: json['userId']?.toString() ?? '',
    userName: json['userName']?.toString() ?? '',
    userPhone: json['userPhone']?.toString() ?? '',
    totalDebt: num.tryParse(json['totalDebt']?.toString() ?? '') ?? 0,
    paidAmount: num.tryParse(json['paidAmount']?.toString() ?? '') ?? 0,
    remainingDebt: num.tryParse(json['remainingDebt']?.toString() ?? '') ?? 0,
    status: json['status']?.toString() ?? 'belum_lunas',
    note: json['note']?.toString() ?? '',
    createdAt: parseDate(json['createdAt']),
    items: (json['items'] as List? ?? [])
        .whereType<Map>()
        .map((item) => DebtItemModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    payments: (json['payments'] as List? ?? [])
        .whereType<Map>()
        .map(
          (payment) =>
              DebtPaymentModel.fromJson(Map<String, dynamic>.from(payment)),
        )
        .toList(),
  );
}
