import '../core/helpers/date_helper.dart';

class UserAddressModel {
  const UserAddressModel({
    required this.id,
    required this.userId,
    required this.labelAddress,
    required this.recipientName,
    required this.phone,
    required this.fullAddress,
    required this.note,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  final String id;
  final String userId;
  final String labelAddress;
  final String recipientName;
  final String phone;
  final String fullAddress;
  final String note;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  factory UserAddressModel.fromJson(Map<String, dynamic> json) =>
      UserAddressModel(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        labelAddress: json['labelAddress']?.toString() ?? '',
        recipientName: json['recipientName']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        fullAddress: json['fullAddress']?.toString() ?? '',
        note: json['note']?.toString() ?? '',
        isPrimary:
            json['isPrimary'] == true || json['isPrimary'].toString() == 'true',
        createdAt: parseDate(json['createdAt']),
        updatedAt: parseDate(json['updatedAt']),
        isActive:
            json['isActive'] == true || json['isActive'].toString() == 'true',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'labelAddress': labelAddress,
    'recipientName': recipientName,
    'phone': phone,
    'fullAddress': fullAddress,
    'note': note,
    'isPrimary': isPrimary,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isActive': isActive,
  };
}
