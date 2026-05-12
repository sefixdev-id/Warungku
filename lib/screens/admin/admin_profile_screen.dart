import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/user/change_password_screen.dart';
import '../../screens/user/warung_address_screen.dart';
import '../../services/local_session_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/profile_menu_tile.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/warungku_logo.dart';
import 'user_management_screen.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({
    super.key,
    required this.admin,
    required this.onOpenTab,
  });

  final UserModel admin;
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Akun Admin',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                AppCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: AppColors.lightBlue,
                        child: Text(
                          admin.name.isEmpty
                              ? 'A'
                              : admin.name.characters.first.toUpperCase(),
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
                              admin.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              admin.email,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                            Text(
                              admin.phone,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                            const SizedBox(height: 8),
                            const StatusChip(
                              label: 'Admin Warungku',
                              color: AppColors.primary,
                              icon: Icons.admin_panel_settings_outlined,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          WarungkuLogo(size: 42),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pengaturan Warung',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 26),
                      _infoRow('Nama Warung', AppConstants.appName),
                      _infoRow('Alamat', AppConstants.warungAddress),
                      _infoRow('Jam Buka', AppConstants.warungOpenHours),
                      _infoRow('Kontak', AppConstants.warungPhone),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ProfileMenuTile(
                  icon: Icons.people_outline,
                  title: 'Data Pelanggan',
                  subtitle: 'Kelola user dan pelanggan Warungku',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UserManagementScreen(admin: admin),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ProfileMenuTile(
                  icon: Icons.inventory_2_outlined,
                  title: 'Data Produk',
                  subtitle: 'Lihat dan kelola produk warung',
                  onTap: () => onOpenTab(1),
                ),
                const SizedBox(height: 10),
                ProfileMenuTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Data Hutang',
                  subtitle: 'Pantau hutang dan pembayaran pelanggan',
                  onTap: () => onOpenTab(2),
                ),
                const SizedBox(height: 10),
                ProfileMenuTile(
                  icon: Icons.dashboard_outlined,
                  title: 'Laporan Warung',
                  subtitle: 'Buka dashboard ringkasan aktivitas',
                  onTap: () => onOpenTab(0),
                ),
                const SizedBox(height: 10),
                ProfileMenuTile(
                  icon: Icons.lock_reset_outlined,
                  title: 'Ganti Password',
                  subtitle: 'Ubah password akun admin',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChangePasswordScreen(userId: admin.id),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ProfileMenuTile(
                  icon: Icons.info_outline,
                  title: 'Tentang Aplikasi',
                  subtitle: 'Warungku v1.0.0 - aplikasi warung tetangga',
                  onTap: () => _showAbout(context),
                ),
                const SizedBox(height: 10),
                ProfileMenuTile(
                  icon: Icons.place_outlined,
                  title: 'Alamat Warungku',
                  subtitle: 'Detail alamat dan jam buka',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const WarungAddressScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
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
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: AppColors.muted)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '1.0.0',
      applicationIcon: const WarungkuLogo(size: 48),
      children: const [
        Text(
          'Warungku adalah aplikasi warung tetangga untuk produk, stok, hutang, chat, dan laporan dasar warung.',
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yakin ingin logout?'),
        content: const Text('Sesi admin akan dihapus dari perangkat ini.'),
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
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}
