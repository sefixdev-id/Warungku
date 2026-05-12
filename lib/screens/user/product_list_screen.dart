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
  const ProductListScreen({
    super.key,
    required this.user,
    this.initialCategoryName,
  });

  final UserModel user;
  final String? initialCategoryName;

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
  bool _isLoadingProducts = false;
  bool _isLoadingCategories = false;
  String? _productError;
  String? _categoryError;
  List<ProductModel> _products = [];
  List<String> _categoryNames = _defaultCategoryNames;

  static const List<String> _defaultCategoryNames = [
    'Semua',
    'Snack',
    'Roti',
    'BBM',
    'Sembako',
    'Rokok',
    'Obat',
    'Voucher',
    'Peralatan',
  ];

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _productService = ProductService(api);
    _categoryService = CategoryService(api);
    _categoryName = _normalizeInitialCategory(widget.initialCategoryName);
    _loadInitialData();
  }

  @override
  void didUpdateWidget(covariant ProductListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategoryName != oldWidget.initialCategoryName &&
        widget.initialCategoryName != null) {
      setState(() {
        _categoryName = _normalizeInitialCategory(widget.initialCategoryName);
      });
    }
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
          Expanded(child: _buildProductList()),
        ],
      ),
    );
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingProducts = true;
      _isLoadingCategories = true;
      _productError = null;
      _categoryError = null;
    });

    await Future.wait([_loadProducts(), _loadCategories()]);
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.getProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _productError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _productError = error.toString());
    } finally {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      final names = [
        'Semua',
        ...categories
            .map((item) => item.name.trim())
            .where((name) => name.isNotEmpty),
      ];
      if (!mounted) return;
      setState(() {
        _categoryNames = names.toSet().toList();
        _categoryError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _categoryNames = _defaultCategoryNames;
        _categoryError = error.toString();
      });
    } finally {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Widget _buildProductList() {
    if (_isLoadingProducts && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_productError != null && _products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const EmptyStateWidget(message: 'Produk gagal dimuat'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final products = _applyFilters(_products);
    if (products.isEmpty) {
      return const EmptyStateWidget(message: 'Produk belum tersedia');
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: ListView.separated(
        key: ValueKey(
          '${_categoryName}_${_sort}_${_ascending}_${_search.text}',
        ),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    ProductDetailScreen(user: widget.user, product: product),
              ),
            ),
          );
        },
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
      final result = switch (_sort) {
        _ProductSort.priceLow => a.sellPrice.compareTo(b.sellPrice),
        _ProductSort.priceHigh => b.sellPrice.compareTo(a.sellPrice),
        _ProductSort.bestSeller => a.name.compareTo(b.name),
        _ProductSort.newest =>
          products.indexOf(a).compareTo(products.indexOf(b)),
      };
      return _ascending ? result : -result;
    }

    filtered.sort(compare);
    return filtered;
  }

  Future<void> _showCategorySheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            if (_isLoadingCategories)
              const ListTile(
                leading: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                title: Text('Memuat kategori...'),
              ),
            if (_categoryError != null)
              ListTile(
                leading: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.warning,
                ),
                title: const Text('Memakai kategori default'),
                subtitle: const Text('Ketuk untuk coba muat ulang kategori'),
                onTap: () {
                  Navigator.pop(context);
                  _loadCategories();
                },
              ),
            for (final name in _categoryNames)
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

  String _normalizeInitialCategory(String? value) {
    final category = value?.trim();
    if (category == null || category.isEmpty) return 'Semua';
    return category;
  }
}
