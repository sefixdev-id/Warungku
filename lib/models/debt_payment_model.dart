import '../core/helpers/date_helper.dart';

class DebtPaymentModel {
  const DebtPaymentModel({
    required this.id,
    required this.debtId,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String debtId;
  final String userId;
  final String userName;
  final num amount;
  final String note;
  final DateTime createdAt;

  factory DebtPaymentModel.fromJson(Map<String, dynamic> json) =>
      DebtPaymentModel(
        id: json['id']?.toString() ?? '',
        debtId: json['debtId']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        userName: json['userName']?.toString() ?? '',
        amount: num.tryParse(json['amount']?.toString() ?? '') ?? 0,
        note: json['note']?.toString() ?? '',
        createdAt: parseDate(json['createdAt']),
      );
}
