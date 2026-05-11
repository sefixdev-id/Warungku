import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/product_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/universal_network_image.dart';

class AddEditProductScreen extends StatefulWidget {
  const AddEditProductScreen({super.key, required this.admin, this.product});

  final UserModel admin;
  final ProductModel? product;

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _name = TextEditingController();
  final _categoryId = TextEditingController();
  final _categoryName = TextEditingController();
  final _buyPrice = TextEditingController();
  final _sellPrice = TextEditingController();
  final _stock = TextEditingController();
  final _imageUrl = TextEditingController();
  final _barcode = TextEditingController();
  final _lowStock = TextEditingController();
  late String _unit;
  late final ProductService _service;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _service = ProductService(ApiService());
    final p = widget.product;
    _unit = p?.unit ?? 'pcs';
    if (p != null) {
      _name.text = p.name;
      _categoryId.text = p.categoryId;
      _categoryName.text = p.categoryName;
      _buyPrice.text = p.buyPrice.toString();
      _sellPrice.text = p.sellPrice.toString();
      _stock.text = p.stock.toString();
      _imageUrl.text = p.imageUrl;
      _barcode.text = p.barcode;
      _lowStock.text = p.lowStockLimit.toString();
    }
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      _show('Nama produk wajib diisi');
      return;
    }
    if ((num.tryParse(_sellPrice.text) ?? 0) <= 0) {
      _show('Harga jual wajib lebih dari 0');
      return;
    }
    if ((num.tryParse(_stock.text) ?? 0) < 0) {
      _show('Stok tidak boleh minus');
      return;
    }
    setState(() => _saving = true);
    final message = await _service.saveProduct(
      adminId: widget.admin.id,
      isEdit: widget.product != null,
      product: {
        if (widget.product != null) 'id': widget.product!.id,
        'name': _name.text.trim(),
        'categoryId': _categoryId.text.trim(),
        'categoryName': _categoryName.text.trim(),
        'buyPrice': num.tryParse(_buyPrice.text) ?? 0,
        'sellPrice': num.tryParse(_sellPrice.text) ?? 0,
        'stock': num.tryParse(_stock.text) ?? 0,
        'unit': _unit,
        'imageUrl': _imageUrl.text.trim(),
        'barcode': _barcode.text.trim(),
        'lowStockLimit': num.tryParse(_lowStock.text) ?? 0,
      },
    );
    if (!mounted) return;
    setState(() => _saving = false);
    _show(message);
    Navigator.of(context).pop();
  }

  void _show(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Tambah Produk' : 'Edit Produk',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UniversalNetworkImage(
                      imageUrl: _imageUrl.text,
                      height: 180,
                      width: double.infinity,
                      fallbackIcon: Icons.add_photo_alternate_outlined,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Tambah Foto Produk',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Gunakan URL gambar atau upload nanti.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                child: Column(
                  children: [
                    AppTextField(controller: _name, label: 'Nama Produk'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _categoryId,
                            label: 'ID Kategori',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppTextField(
                            controller: _categoryName,
                            label: 'Kategori',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _buyPrice,
                            label: 'Harga Beli',
                            hint: 'Rp',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppTextField(
                            controller: _sellPrice,
                            label: 'Harga Jual',
                            hint: 'Rp',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _stock,
                            label: 'Stok',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _unit,
                            decoration: const InputDecoration(
                              labelText: 'Satuan',
                            ),
                            items: AppConstants.units
                                .map(
                                  (unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _unit = value ?? 'pcs'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppTextField(controller: _barcode, label: 'Barcode'),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _lowStock,
                      label: 'Batas Stok Menipis',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _imageUrl,
                      label: 'Image URL',
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: AppButton(
              label: widget.product == null
                  ? 'Simpan Produk'
                  : 'Simpan Perubahan',
              icon: Icons.save_outlined,
              isLoading: _saving,
              onPressed: _save,
            ),
          ),
        ),
      ),
    );
  }
}
