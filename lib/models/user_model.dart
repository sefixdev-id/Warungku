class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool isActive;

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    role: json['role']?.toString() ?? 'user',
    isActive: json['isActive'] == true || json['isActive'].toString() == 'true',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'role': role,
    'isActive': isActive,
  };
}
