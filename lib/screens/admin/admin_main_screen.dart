import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import 'admin_chat_list_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_debt_list_screen.dart';
import 'admin_product_screen.dart';
import 'user_management_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      AdminDashboardScreen(admin: widget.user),
      AdminProductScreen(admin: widget.user),
      AdminDebtListScreen(admin: widget.user),
      AdminChatListScreen(admin: widget.user),
      UserManagementScreen(admin: widget.user),
    ];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Hutang',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'User',
          ),
        ],
      ),
    );
  }
}
