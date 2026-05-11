import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/product_service.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/product_card.dart';
import 'add_edit_product_screen.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key, required this.admin});

  final UserModel admin;

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  late final ProductService _service;

  @override
  void initState() {
    super.initState();
    _service = ProductService(ApiService());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Produk')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEditProductScreen(admin: widget.admin),
            ),
          );
          setState(() {});
        },
        icon: const Icon(Icons.add),
        label: const Text('Produk'),
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _service.getProducts(),
        builder: (context, snapshot) {
          final products = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (products.isEmpty) {
            return const EmptyStateWidget(message: 'Produk belum tersedia');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => ProductCard(
              product: products[index],
              trailing: IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditProductScreen(
                        admin: widget.admin,
                        product: products[index],
                      ),
                    ),
                  );
                  setState(() {});
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
