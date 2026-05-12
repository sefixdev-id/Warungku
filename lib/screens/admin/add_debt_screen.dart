import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/debt_service.dart';
import '../../services/product_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_state_widget.dart';

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({super.key, required this.admin});

  final UserModel admin;

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _qty = TextEditingController(text: '1');
  final _note = TextEditingController();
  late final DebtService _debtService;
  late final ProductService _productService;

  var _customers = <UserModel>[];
  var _products = <ProductModel>[];
  UserModel? _selectedCustomer;
  ProductModel? _selectedProduct;
  bool _loadingCustomers = false;
  bool _loadingProducts = false;
  bool _saving = false;
  String? _customerError;
  String? _productError;

  num get _qtyValue => num.tryParse(_qty.text) ?? 0;
  num get _subtotal => (_selectedProduct?.sellPrice ?? 0) * _qtyValue;
  bool get _valid =>
      _selectedCustomer != null &&
      _selectedProduct != null &&
      _qtyValue >= 1 &&
      _qtyValue <= (_selectedProduct?.stock ?? 0) &&
      !_saving;

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _debtService = DebtService(api);
    _productService = ProductService(api);
    _qty.addListener(() => setState(() {}));
    _loadCustomers();
    _loadProducts();
  }

  @override
  void dispose() {
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _loadingCustomers = true;
      _customerError = null;
    });

    try {
      final response = await ApiService().post(
        action: 'getAllUsers',
        body: {'adminId': widget.admin.id},
      );
      if (!mounted) return;

      if (!response.success) {
        setState(() {
          _customers = [];
          _customerError = response.message.isEmpty
              ? 'Data pelanggan gagal dimuat'
              : response.message;
          _loadingCustomers = false;
        });
        return;
      }

      final customers = (response.data as List? ?? [])
          .whereType<Map>()
          .map((item) => UserModel.fromJson(Map<String, dynamic>.from(item)))
          .where((user) => user.role == 'user' && user.isActive)
          .toList();

      setState(() {
        _customers = customers;
        _loadingCustomers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _customers = [];
        _customerError = 'Data pelanggan gagal dimuat';
        _loadingCustomers = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loadingProducts = true;
      _productError = null;
    });

    try {
      final products = await _productService.getProducts();
      if (!mounted) return;
      setState(() {
        _products = products.where((product) => product.isActive).toList();
        _loadingProducts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _products = [];
        _productError = 'Data produk gagal dimuat';
        _loadingProducts = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_valid) {
      _show('Pilih pelanggan, produk, dan qty yang valid');
      return;
    }

    setState(() => _saving = true);
    final message = await _debtService.addDebt(
      adminId: widget.admin.id,
      userId: _selectedCustomer!.id,
      note: _note.text.trim(),
      items: [
        {'productId': _selectedProduct!.id, 'qty': _qtyValue},
      ],
    );
    if (!mounted) return;
    setState(() => _saving = false);
    _show(message);
    Navigator.of(context).pop(true);
  }

  void _show(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Tambah Hutang',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _selectionCard(
                          title: 'Pilih Pelanggan',
                          icon: Icons.person_search_outlined,
                          value: _selectedCustomer == null
                              ? 'Belum memilih pelanggan'
                              : _selectedCustomer!.name,
                          subtitle: _selectedCustomer == null
                              ? _customerStatusText
                              : '${_selectedCustomer!.phone} - ID: ${_selectedCustomer!.id}',
                          isLoading: _loadingCustomers,
                          error: _selectedCustomer == null
                              ? _customerError
                              : null,
                          onRetry: _loadCustomers,
                          onTap: _pickCustomer,
                        ),
                        const SizedBox(height: 14),
                        _selectionCard(
                          title: 'Pilih Produk',
                          icon: Icons.inventory_2_outlined,
                          value: _selectedProduct == null
                              ? 'Belum memilih produk'
                              : _selectedProduct!.name,
                          subtitle: _selectedProduct == null
                              ? _productStatusText
                              : '${formatRupiah(_selectedProduct!.sellPrice)} - Stok ${_selectedProduct!.stock} ${_selectedProduct!.unit}',
                          isLoading: _loadingProducts,
                          error: _selectedProduct == null
                              ? _productError
                              : null,
                          onRetry: _loadProducts,
                          onTap: _pickProduct,
                        ),
                        const SizedBox(height: 14),
                        AppCard(
                          child: Column(
                            children: [
                              AppTextField(
                                controller: _qty,
                                label: 'Qty',
                                icon: Icons.exposure_plus_1_outlined,
                                keyboardType: TextInputType.number,
                              ),
                              if (_selectedProduct != null &&
                                  _qtyValue > _selectedProduct!.stock) ...[
                                const SizedBox(height: 8),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Qty melebihi stok produk',
                                    style: TextStyle(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              AppTextField(
                                controller: _note,
                                label: 'Catatan',
                                icon: Icons.notes_outlined,
                                maxLines: 3,
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
                                'Ringkasan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _row(
                                'Harga',
                                formatRupiah(_selectedProduct?.sellPrice ?? 0),
                              ),
                              _row('Qty', '${_qtyValue <= 0 ? 0 : _qtyValue}'),
                              const Divider(height: 24),
                              _row(
                                'Total',
                                formatRupiah(_subtotal),
                                bold: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: AppButton(
              label: 'Simpan Hutang',
              icon: Icons.save_outlined,
              isLoading: _saving,
              onPressed: _valid ? _save : null,
            ),
          ),
        ),
      ),
    );
  }

  String get _customerStatusText {
    if (_loadingCustomers) return 'Data pelanggan sedang dimuat';
    if (_customerError != null) return 'Gagal memuat pelanggan';
    if (_customers.isEmpty) return 'Data pelanggan belum tersedia';
    return 'Tap untuk mencari nama atau nomor HP';
  }

  String get _productStatusText {
    if (_loadingProducts) return 'Data produk sedang dimuat';
    if (_productError != null) return 'Gagal memuat produk';
    if (_products.isEmpty) return 'Data produk belum tersedia';
    return 'Tap untuk mencari produk';
  }

  Widget _selectionCard({
    required String title,
    required IconData icon,
    required String value,
    required String subtitle,
    required VoidCallback onTap,
    bool isLoading = false,
    String? error,
    VoidCallback? onRetry,
  }) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            _inlineError(error, onRetry),
          ],
        ],
      ),
    );
  }

  Widget _inlineError(String message, VoidCallback? onRetry) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: AppColors.muted)),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Future<void> _pickCustomer() async {
    if (_loadingCustomers) {
      _show('Data pelanggan sedang dimuat');
      return;
    }
    if (_customers.isEmpty) {
      _show(_customerError ?? 'Data pelanggan belum tersedia');
      return;
    }

    final selected = await showModalBottomSheet<UserModel>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _CustomerPickerSheet(customers: _customers),
    );
    if (selected != null) setState(() => _selectedCustomer = selected);
  }

  Future<void> _pickProduct() async {
    if (_loadingProducts) {
      _show('Data produk sedang dimuat');
      return;
    }
    if (_products.isEmpty) {
      _show(_productError ?? 'Data produk belum tersedia');
      return;
    }

    final selected = await showModalBottomSheet<ProductModel>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _ProductPickerSheet(products: _products),
    );
    if (selected != null) setState(() => _selectedProduct = selected);
  }
}

class _CustomerPickerSheet extends StatefulWidget {
  const _CustomerPickerSheet({required this.customers});

  final List<UserModel> customers;

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.toLowerCase();
    final customers = widget.customers
        .where(
          (user) =>
              user.name.toLowerCase().contains(query) ||
              user.phone.toLowerCase().contains(query) ||
              user.id.toLowerCase().contains(query),
        )
        .toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: Column(
            children: [
              AppSearchField(
                hint: 'Cari nama atau nomor HP...',
                controller: _search,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: customers.isEmpty
                    ? const EmptyStateWidget(
                        message: 'Pelanggan tidak ditemukan',
                      )
                    : ListView.separated(
                        itemCount: customers.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          return AppCard(
                            onTap: () => Navigator.pop(context, customer),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                customer.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              subtitle: Text(
                                '${customer.phone}\nID: ${customer.id}',
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductPickerSheet extends StatefulWidget {
  const _ProductPickerSheet({required this.products});

  final List<ProductModel> products;

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.toLowerCase();
    final products = widget.products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query) ||
              product.categoryName.toLowerCase().contains(query),
        )
        .toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: Column(
            children: [
              AppSearchField(
                hint: 'Cari produk...',
                controller: _search,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: products.isEmpty
                    ? const EmptyStateWidget(message: 'Produk tidak ditemukan')
                    : ListView.separated(
                        itemCount: products.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return AppCard(
                            onTap: () => Navigator.pop(context, product),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              subtitle: Text(
                                '${formatRupiah(product.sellPrice)} - Stok ${product.stock} ${product.unit}',
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
