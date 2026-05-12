import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

enum _ProductSort { bestSeller, newest, priceLow, priceHigh }

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _search = TextEditingController();
  late final ProductService _productService;
  late final CategoryService _categoryService;
  String _categoryName = 'Semua';
  _ProductSort _sort = _ProductSort.newest;
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _productService = ProductService(api);
    _categoryService = CategoryService(api);
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
            child: Column(
              children: [
                AppSearchField(
                  hint: 'Cari produk...',
                  controller: _search,
                  trailingIcon: Icons.tune_rounded,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showCategorySheet,
                        icon: const Icon(Icons.filter_list_rounded),
                        label: Text(_categoryName),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showSortSheet,
                        icon: const Icon(Icons.sort_rounded),
                        label: Text(_sortLabel(_sort)),
                      ),
                    ),
                    IconButton.outlined(
                      tooltip: 'Ubah arah sorting',
                      onPressed: () => setState(() => _ascending = !_ascending),
                      icon: Icon(
                        _ascending
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: _productService.getProducts(),
              builder: (context, snapshot) {
                final products = _applyFilters(snapshot.data ?? []);
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

  List<ProductModel> _applyFilters(List<ProductModel> products) {
    final query = _search.text.trim().toLowerCase();
    final filtered = products.where((product) {
      final matchSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.categoryName.toLowerCase().contains(query);
      final matchCategory =
          _categoryName == 'Semua' ||
          product.categoryName.toLowerCase() == _categoryName.toLowerCase();
      return matchSearch && matchCategory;
    }).toList();

    int compare(ProductModel a, ProductModel b) {
      return switch (_sort) {
        _ProductSort.priceLow => a.sellPrice.compareTo(b.sellPrice),
        _ProductSort.priceHigh => b.sellPrice.compareTo(a.sellPrice),
        _ => a.name.compareTo(b.name),
      };
    }

    filtered.sort(compare);
    if (_ascending && _sort == _ProductSort.priceHigh) {
      return filtered.reversed.toList();
    }
    if (!_ascending && _sort == _ProductSort.priceLow) {
      return filtered.reversed.toList();
    }
    if (_ascending &&
        (_sort == _ProductSort.newest || _sort == _ProductSort.bestSeller)) {
      return filtered.reversed.toList();
    }
    return filtered;
  }

  Future<void> _showCategorySheet() async {
    final categories = await _categoryService.getCategories();
    if (!mounted) return;
    final names = ['Semua', ...categories.map((item) => item.name)];
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final name in names)
              ListTile(
                leading: Icon(
                  name == _categoryName
                      ? Icons.radio_button_checked
                      : Icons.circle_outlined,
                  color: AppColors.primary,
                ),
                title: Text(name),
                onTap: () => Navigator.pop(context, name),
              ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _categoryName = selected);
  }

  Future<void> _showSortSheet() async {
    final selected = await showModalBottomSheet<_ProductSort>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final sort in _ProductSort.values)
              ListTile(
                leading: Icon(
                  sort == _sort
                      ? Icons.radio_button_checked
                      : Icons.circle_outlined,
                  color: AppColors.primary,
                ),
                title: Text(_sortLabel(sort)),
                subtitle: sort == _ProductSort.bestSeller
                    ? const Text('Menunggu data order terakumulasi')
                    : null,
                onTap: () => Navigator.pop(context, sort),
              ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _sort = selected);
  }

  String _sortLabel(_ProductSort sort) => switch (sort) {
    _ProductSort.bestSeller => 'Terlaris',
    _ProductSort.newest => 'Terbaru',
    _ProductSort.priceLow => 'Harga Terendah',
    _ProductSort.priceHigh => 'Harga Tertinggi',
  };
}
