import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import 'chat_admin_screen.dart';
import 'my_debt_screen.dart';
import 'product_list_screen.dart';
import 'user_home_screen.dart';
import 'user_profile_screen.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      UserHomeScreen(
        user: widget.user,
        onOpenTab: (index) => setState(() => _index = index),
      ),
      ProductListScreen(user: widget.user),
      MyDebtScreen(user: widget.user),
      ChatAdminScreen(user: widget.user),
      UserProfileScreen(user: widget.user),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Hutang Saya',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
