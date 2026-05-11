import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_widget.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key, required this.admin});

  final UserModel admin;

  Future<List<UserModel>> _users() async {
    final response = await ApiService().post(
      action: 'getAllUsers',
      body: {'adminId': admin.id},
    );
    if (!response.success) return [];
    return (response.data as List? ?? [])
        .whereType<Map>()
        .map((item) => UserModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: FutureBuilder<List<UserModel>>(
        future: _users(),
        builder: (context, snapshot) {
          final users = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (users.isEmpty) {
            return const EmptyStateWidget(message: 'User belum tersedia');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final user = users[index];
              return AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text('${user.email}\n${user.phone}'),
                  trailing: Chip(label: Text(user.role)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
