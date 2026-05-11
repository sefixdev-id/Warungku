import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/universal_network_image.dart';
import 'chat_admin_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    super.key,
    required this.user,
    required this.product,
  });

  final UserModel user;
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              UniversalNetworkImage(
                imageUrl: product.imageUrl,
                height: 260,
                width: double.infinity,
                fallbackIcon: _categoryIcon(product.categoryName),
                borderRadius: BorderRadius.circular(22),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusChip(
                          label: product.categoryName.isEmpty
                              ? 'Produk'
                              : product.categoryName,
                          color: AppColors.primary,
                          icon: _categoryIcon(product.categoryName),
                        ),
                        StatusChip(
                          label: product.isOutOfStock ? 'Habis' : 'Tersedia',
                          color: product.isOutOfStock
                              ? AppColors.danger
                              : AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatRupiah(product.sellPrice),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
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
                    const Text(
                      'Informasi Produk',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _infoRow('Kategori', product.categoryName),
                    _infoRow('Satuan', product.unit),
                    if (product.barcode.isNotEmpty)
                      _infoRow('Barcode', product.barcode),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ketersediaan Stok',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _infoRow('Stok', '${product.stock} ${product.unit}'),
                    _infoRow(
                      'Status',
                      product.isOutOfStock ? 'Habis' : 'Tersedia',
                      valueColor: product.isOutOfStock
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Aksi Cepat',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 460;
                  final askButton = OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatAdminScreen(user: user),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Tanya Stok'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                  final buyButton = AppButton(
                    label: 'Beli Sekarang',
                    icon: Icons.shopping_bag_outlined,
                    onPressed: () => _showBuySheet(context),
                  );
                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        askButton,
                        const SizedBox(height: 10),
                        buyButton,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: askButton),
                      const SizedBox(width: 10),
                      Expanded(child: buyButton),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: AppColors.muted)),
        ),
        Text(
          value.isEmpty ? '-' : value,
          style: TextStyle(
            color: valueColor ?? AppColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );

  void _showBuySheet(BuildContext context) {
    var qty = 1;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final total = product.sellPrice * qty;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${formatRupiah(product.sellPrice)} / ${product.unit}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Jumlah',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton.outlined(
                        onPressed: qty <= 1
                            ? null
                            : () => setSheetState(() => qty--),
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$qty',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: qty >= product.stock
                            ? null
                            : () => setSheetState(() => qty++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoRow('Total', formatRupiah(total)),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Konfirmasi Pesanan',
                    icon: Icons.check_circle_outline,
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Saya ingin beli ${product.name} sebanyak $qty ${product.unit}. Apakah stok tersedia?',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _categoryIcon(String name) {
    return switch (name.toLowerCase()) {
      'snack' => Icons.fastfood_outlined,
      'roti' => Icons.bakery_dining_outlined,
      'bbm' => Icons.local_gas_station_outlined,
      'sembako' => Icons.shopping_bag_outlined,
      'rokok' => Icons.smoking_rooms_outlined,
      'obat' => Icons.medication_outlined,
      'voucher' => Icons.confirmation_number_outlined,
      _ => Icons.build_outlined,
    };
  }
}
