import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/category_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/product_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/category_card.dart';
import '../../widgets/profile_menu_tile.dart';
import '../../widgets/product_card.dart';
import '../../widgets/warungku_logo.dart';
import '../auth/login_screen.dart';
import '../../services/local_session_service.dart';
import 'change_password_screen.dart';
import 'my_orders_screen.dart';
import 'user_address_screen.dart';
import 'warung_address_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({
    super.key,
    required this.user,
    required this.onOpenTab,
  });

  final UserModel user;
  final ValueChanged<int> onOpenTab;

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  late final DashboardService _dashboardService;
  late final CategoryService _categoryService;
  late final ProductService _productService;

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _dashboardService = DashboardService(api);
    _categoryService = CategoryService(api);
    _productService = ProductService(api);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Menu',
          onPressed: _showQuickMenu,
          icon: const Icon(Icons.menu),
        ),
        titleSpacing: 0,
        title: Row(
          children: const [
            WarungkuLogo(size: 34),
            SizedBox(width: 10),
            Text('Beranda', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const AppSearchField(
                  hint: 'Cari produk di warung...',
                  trailingIcon: Icons.tune_rounded,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x332563EB),
                        blurRadius: 22,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Datang',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Belanja mudah, bayar nanti bisa di Warungku.',
                              style: TextStyle(
                                color: Colors.white,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.storefront,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FutureBuilder<Map<String, dynamic>>(
                  future: _dashboardService.getUserDashboard(widget.user.id),
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? {};
                    return AppCard(
                      child: Row(
                        children: [
                          _DebtSummary(
                            label: 'Total',
                            value: formatRupiah(data['totalDebt'] ?? 0),
                          ),
                          _DebtSummary(
                            label: 'Dibayar',
                            value: formatRupiah(data['paidAmount'] ?? 0),
                          ),
                          _DebtSummary(
                            label: 'Sisa',
                            value: formatRupiah(data['remainingDebt'] ?? 0),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Shortcut(
                        icon: Icons.chat_bubble_outline,
                        label: 'Chat Admin',
                        onTap: () => widget.onOpenTab(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Shortcut(
                        icon: Icons.receipt_long_outlined,
                        label: 'Hutang Saya',
                        onTap: () => widget.onOpenTab(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Kategori',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<CategoryModel>>(
                  future: _categoryService.getCategories(),
                  builder: (context, snapshot) {
                    final categories = snapshot.data?.isNotEmpty == true
                        ? snapshot.data!
                        : _defaultCategories;
                    return GridView.builder(
                      itemCount: categories.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.95,
                          ),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return CategoryCard(
                          label: category.name,
                          icon: _categoryIcon(category.name),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Produk Terbaru',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<ProductModel>>(
                  future: _productService.getProducts(),
                  builder: (context, snapshot) {
                    final products = (snapshot.data ?? []).take(5).toList();
                    return Column(
                      children: products
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ProductCard(product: item),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<CategoryModel> get _defaultCategories => const [
    CategoryModel(id: 'CAT001', name: 'Snack'),
    CategoryModel(id: 'CAT002', name: 'Roti'),
    CategoryModel(id: 'CAT003', name: 'BBM'),
    CategoryModel(id: 'CAT004', name: 'Sembako'),
    CategoryModel(id: 'CAT005', name: 'Rokok'),
    CategoryModel(id: 'CAT006', name: 'Obat'),
    CategoryModel(id: 'CAT007', name: 'Voucher'),
    CategoryModel(id: 'CAT008', name: 'Peralatan'),
  ];

  IconData _categoryIcon(String name) {
    return switch (name.toLowerCase()) {
      'snack' => Icons.fastfood_rounded,
      'roti' => Icons.bakery_dining_rounded,
      'bbm' => Icons.local_gas_station_rounded,
      'sembako' => Icons.rice_bowl_rounded,
      'rokok' => Icons.inventory_rounded,
      'obat' => Icons.medication_rounded,
      'voucher' => Icons.confirmation_number_rounded,
      _ => Icons.build_rounded,
    };
  }

  void _showQuickMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.viewInsetsOf(context).bottom + 18,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.82,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ProfileMenuTile(
                      icon: Icons.person_outline,
                      title: 'Profil Saya',
                      subtitle: widget.user.name,
                      onTap: () {
                        Navigator.pop(context);
                        widget.onOpenTab(4);
                      },
                    ),
                    const SizedBox(height: 10),
                    ProfileMenuTile(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Pesanan Saya',
                      subtitle: 'Lihat status pesanan',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MyOrdersScreen(user: widget.user),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ProfileMenuTile(
                      icon: Icons.location_on_outlined,
                      title: 'Alamat Saya',
                      subtitle: 'Maksimal 3 alamat tersimpan',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                UserAddressScreen(user: widget.user),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ProfileMenuTile(
                      icon: Icons.place_outlined,
                      title: 'Alamat Warungku',
                      subtitle: 'Jam buka dan kontak warung',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const WarungAddressScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ProfileMenuTile(
                      icon: Icons.receipt_long_outlined,
                      title: 'Hutang Saya',
                      subtitle: 'Lihat ringkasan dan detail hutang',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onOpenTab(2);
                      },
                    ),
                    const SizedBox(height: 10),
                    ProfileMenuTile(
                      icon: Icons.chat_bubble_outline,
                      title: 'Chat Admin',
                      subtitle: 'Tanya stok dan informasi warung',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onOpenTab(3);
                      },
                    ),
                    const SizedBox(height: 10),
                    ProfileMenuTile(
                      icon: Icons.lock_reset_outlined,
                      title: 'Ganti Password',
                      subtitle: 'Ubah password akun',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ChangePasswordScreen(userId: widget.user.id),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ProfileMenuTile(
                      icon: Icons.logout,
                      title: 'Logout',
                      subtitle: 'Keluar dari akun',
                      danger: true,
                      onTap: () async {
                        Navigator.pop(context);
                        await LocalSessionService().clear();
                        if (!mounted) return;
                        Navigator.of(this.context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (_) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DebtSummary extends StatelessWidget {
  const _DebtSummary({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
