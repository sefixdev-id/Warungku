import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../models/user_model.dart';
import '../../screens/auth/login_screen.dart';
import '../../services/api_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/debt_service.dart';
import '../../services/local_session_service.dart';
import '../../services/product_service.dart';
import '../../services/turnover_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/dashboard_metric_card.dart';
import '../../widgets/warungku_logo.dart';
import 'admin_debt_list_screen.dart';
import 'admin_turnover_detail_screen.dart';
import 'low_stock_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, required this.admin});

  final UserModel admin;

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    final service = DashboardService(api);
    final turnoverService = TurnoverService(
      debtService: DebtService(api),
      productService: ProductService(api),
    );
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: const [
            WarungkuLogo(size: 38),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Dashboard Admin',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => LowStockScreen(admin: admin)),
            ),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: FutureBuilder<_DashboardBundle>(
        future: _loadDashboard(service, turnoverService),
        builder: (context, snapshot) {
          final bundle = snapshot.data ?? _DashboardBundle.empty();
          final data = bundle.dashboard;
          final todayStats = bundle.todayStats;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.18,
                children: [
                  DashboardMetricCard(
                    label: 'Total Hutang',
                    value: formatRupiah(data['totalDebt'] ?? 0),
                    icon: Icons.account_balance_wallet_outlined,
                    caption: '+12% vs kemarin',
                    highlight: true,
                  ),
                  DashboardMetricCard(
                    label: 'Pelanggan Berhutang',
                    value: '${data['debtUserCount'] ?? 0}',
                    icon: Icons.people_outline,
                    caption: 'Lihat aktif',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdminDebtListScreen(
                          admin: admin,
                          initialFilter: 'aktif',
                        ),
                      ),
                    ),
                  ),
                  DashboardMetricCard(
                    label: 'Stok Menipis',
                    value: '${data['lowStockCount'] ?? 0} Produk',
                    icon: Icons.warning_amber_outlined,
                    accentColor: AppColors.warning,
                    caption: 'Lihat detail',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LowStockScreen(admin: admin),
                      ),
                    ),
                  ),
                  DashboardMetricCard(
                    label: 'Perputaran Hari Ini',
                    value: formatRupiah(todayStats.totalTurnover),
                    icon: Icons.trending_up_rounded,
                    accentColor: AppColors.success,
                    caption: 'Dari hutang hari ini',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdminTurnoverDetailScreen(admin: admin),
                      ),
                    ),
                  ),
                  DashboardMetricCard(
                    label: 'Keuntungan Hari Ini',
                    value: formatRupiah(todayStats.totalProfit),
                    icon: Icons.savings_outlined,
                    accentColor: AppColors.success,
                    caption: 'Estimasi modal',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Expanded(
                          child: Text(
                            'Grafik Penjualan 7 Hari Terakhir',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _MiniBarChart(),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Aktivitas Terbaru',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 10),
              const _ActivityRow(
                icon: Icons.payments_outlined,
                color: AppColors.success,
                title: 'Pembayaran oleh Ahmad',
                value: 'Rp 130.000',
                time: '5 menit lalu',
              ),
              const _ActivityRow(
                icon: Icons.receipt_long_outlined,
                color: AppColors.primary,
                title: 'Hutang Joko dicicil',
                value: 'Rp 250.000',
                time: '15 menit lalu',
              ),
              const _ActivityRow(
                icon: Icons.warning_amber_outlined,
                color: AppColors.warning,
                title: 'Stok menipis: Minyak Goreng 1L',
                value: '',
                time: '10.30 WIB',
              ),
            ],
          );
        },
      ),
    );
  }

  Future<_DashboardBundle> _loadDashboard(
    DashboardService dashboardService,
    TurnoverService turnoverService,
  ) async {
    final results = await Future.wait([
      dashboardService.getAdminDashboard(admin.id),
      turnoverService.getStats(adminId: admin.id, period: TurnoverPeriod.today),
    ]);
    return _DashboardBundle(
      dashboard: results[0] as Map<String, dynamic>,
      todayStats: results[1] as TurnoverStats,
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

class _DashboardBundle {
  const _DashboardBundle({required this.dashboard, required this.todayStats});

  final Map<String, dynamic> dashboard;
  final TurnoverStats todayStats;

  factory _DashboardBundle.empty() => const _DashboardBundle(
    dashboard: {},
    todayStats: TurnoverStats(
      period: TurnoverPeriod.today,
      totalTurnover: 0,
      totalProfit: 0,
      totalQty: 0,
      items: [],
    ),
  );
}

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart();

  static const values = [0.72, 0.60, 0.82, 0.52, 0.84, 0.70, 0.82];
  static const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (index) {
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: values[index],
                      child: Container(
                        width: 18,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[index],
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.time,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String time;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
