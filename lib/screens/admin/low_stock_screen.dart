import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/product_service.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/product_card.dart';

class LowStockScreen extends StatelessWidget {
  const LowStockScreen({super.key, required this.admin});

  final UserModel admin;

  @override
  Widget build(BuildContext context) {
    final service = ProductService(ApiService());
    return Scaffold(
      appBar: AppBar(title: const Text('Stok Menipis')),
      body: FutureBuilder<List<ProductModel>>(
        future: service.getLowStockProducts(admin.id),
        builder: (context, snapshot) {
          final products = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (products.isEmpty) {
            return const EmptyStateWidget(message: 'Tidak ada stok menipis');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                ProductCard(product: products[index]),
          );
        },
      ),
    );
  }
}
