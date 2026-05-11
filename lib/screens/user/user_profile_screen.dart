import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../screens/auth/login_screen.dart';
import '../../services/local_session_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/profile_menu_tile.dart';
import '../../widgets/status_chip.dart';
import 'change_password_screen.dart';
import 'chat_admin_screen.dart';
import 'my_debt_screen.dart';
import 'warung_address_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: AppColors.lightBlue,
                      child: Text(
                        user.name.isEmpty
                            ? '?'
                            : user.name.characters.first.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                          Text(
                            user.phone,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                          const SizedBox(height: 8),
                          const StatusChip(
                            label: 'Pelanggan Warungku',
                            color: AppColors.primary,
                            icon: Icons.verified_user_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ProfileMenuTile(
                icon: Icons.badge_outlined,
                title: 'Informasi Akun',
                subtitle: '${user.email} • ${user.phone}',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              ProfileMenuTile(
                icon: Icons.place_outlined,
                title: 'Alamat Warungku',
                subtitle: 'Alamat, jam buka, dan kontak',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WarungAddressScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ProfileMenuTile(
                icon: Icons.receipt_long_outlined,
                title: 'Hutang Saya',
                subtitle: 'Lihat hutang dan riwayat pembayaran',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MyDebtScreen(user: user)),
                ),
              ),
              const SizedBox(height: 10),
              ProfileMenuTile(
                icon: Icons.chat_bubble_outline,
                title: 'Chat Admin',
                subtitle: 'Hubungi admin Warungku',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatAdminScreen(user: user),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ProfileMenuTile(
                icon: Icons.lock_reset_outlined,
                title: 'Ganti Password',
                subtitle: 'Ubah password akun',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangePasswordScreen(userId: user.id),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ProfileMenuTile(
                icon: Icons.help_outline,
                title: 'Bantuan',
                subtitle: 'Hubungi admin untuk informasi stok dan pemesanan',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatAdminScreen(user: user),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Logout',
                icon: Icons.logout,
                backgroundColor: AppColors.danger,
                onPressed: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yakin ingin logout?'),
        content: const Text('Kamu perlu login ulang untuk masuk ke Warungku.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await LocalSessionService().clear();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }
}
