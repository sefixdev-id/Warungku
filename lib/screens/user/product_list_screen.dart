import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/product_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _search = TextEditingController();
  late final ProductService _productService;

  @override
  void initState() {
    super.initState();
    _productService = ProductService(ApiService());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produk')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              controller: _search,
              label: 'Cari produk',
              icon: Icons.search,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: _productService.getProducts(search: _search.text),
              builder: (context, snapshot) {
                final products = snapshot.data ?? [];
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (products.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'Produk belum tersedia',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(
                            user: widget.user,
                            product: product,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
