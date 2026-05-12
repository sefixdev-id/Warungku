import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/category_service.dart';
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
  final _barcode = TextEditingController();
  final _lowStock = TextEditingController();
  late final ProductService _productService;
  late final CategoryService _categoryService;
  late String _unit;
  String _uploadedImageUrl = '';
  Uint8List? _selectedImageBytes;
  String? _selectedImageFileName;
  String? _selectedImageMimeType;

  var _categories = <CategoryModel>[];
  CategoryModel? _selectedCategory;
  bool _loadingCategories = false;
  bool _saving = false;
  String? _categoryError;

  bool get _isValid =>
      _name.text.trim().isNotEmpty &&
      (num.tryParse(_sellPrice.text) ?? 0) > 0 &&
      (num.tryParse(_stock.text) ?? -1) >= 0 &&
      !_saving;

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _productService = ProductService(api);
    _categoryService = CategoryService(api);
    final p = widget.product;
    _unit = p?.unit ?? 'pcs';
    if (p != null) {
      _name.text = p.name;
      _categoryId.text = p.categoryId;
      _categoryName.text = p.categoryName;
      _buyPrice.text = p.buyPrice.toString();
      _sellPrice.text = p.sellPrice.toString();
      _stock.text = p.stock.toString();
      _uploadedImageUrl = p.imageUrl;
      _barcode.text = p.barcode;
      _lowStock.text = p.lowStockLimit.toString();
    }
    for (final controller in [_name, _sellPrice, _stock]) {
      controller.addListener(() => setState(() {}));
    }
    _loadCategories();
  }

  @override
  void dispose() {
    _name.dispose();
    _categoryId.dispose();
    _categoryName.dispose();
    _buyPrice.dispose();
    _sellPrice.dispose();
    _stock.dispose();
    _barcode.dispose();
    _lowStock.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
      _categoryError = null;
    });

    try {
      final categories = await _categoryService.getCategories();
      if (!mounted) return;

      CategoryModel? selected;
      for (final category in categories) {
        if (category.id == _categoryId.text) {
          selected = category;
          break;
        }
      }

      setState(() {
        _categories = categories;
        _selectedCategory = selected;
        _loadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categoryError = 'Kategori gagal dimuat. Isi manual atau coba lagi.';
        _loadingCategories = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1000,
      maxHeight: 1000,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _selectedImageBytes = Uint8List.fromList(bytes);
      _selectedImageFileName = _shortFileName(image.name);
      _selectedImageMimeType = _detectMimeType(image);
    });
  }

  Future<void> _save() async {
    if (!_isValid) {
      _show('Nama, harga jual, dan stok wajib valid');
      return;
    }

    setState(() => _saving = true);
    var finalImageUrl = _uploadedImageUrl.trim();
    if (_selectedImageBytes != null) {
      try {
        final uploadedUrl = await _productService.uploadProductImage(
          adminId: widget.admin.id,
          fileName: _selectedImageFileName ?? 'produk.jpg',
          mimeType: _selectedImageMimeType ?? 'image/jpeg',
          bytes: _selectedImageBytes!,
        );
        finalImageUrl = uploadedUrl;
        _uploadedImageUrl = uploadedUrl;
      } catch (error) {
        if (!mounted) return;
        setState(() => _saving = false);
        _show(_cleanErrorMessage(error));
        return;
      }
    }

    final message = await _productService.saveProduct(
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
        'imageUrl': finalImageUrl,
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

  String _detectMimeType(XFile file) {
    final mimeType = file.mimeType?.toLowerCase();
    if (mimeType != null && mimeType.startsWith('image/')) return mimeType;
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
    return 'image/jpeg';
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) return 'Upload gambar gagal';
    if (message.contains('base64Data') ||
        message.contains('payload=') ||
        message.length > 240) {
      return 'Upload gambar gagal. Cek izin Apps Script/Google Drive, ukuran gambar, lalu coba lagi.';
    }
    return message;
  }

  String _shortFileName(String value) {
    final name = value.split(RegExp(r'[\\/]')).last.trim();
    if (name.isEmpty) return 'produk.jpg';
    if (name.length <= 42) return name;
    final dot = name.lastIndexOf('.');
    final extension = dot > 0 ? name.substring(dot) : '';
    return '${name.substring(0, 34)}...$extension';
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.product == null ? 'Tambah Produk' : 'Edit Produk';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _photoCard(),
                        const SizedBox(height: 14),
                        _productInfoCard(),
                        const SizedBox(height: 14),
                        _priceStockCard(),
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
            constraints: const BoxConstraints(maxWidth: 760),
            child: AppButton(
              label: widget.product == null
                  ? 'Simpan Produk'
                  : 'Simpan Perubahan',
              icon: Icons.save_outlined,
              isLoading: _saving,
              onPressed: _isValid ? _save : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _photoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Foto Produk',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _ImagePreview(
            imageUrl: _uploadedImageUrl,
            imageBytes: _selectedImageBytes,
          ),
          if (_selectedImageFileName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 17,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _selectedImageFileName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image_outlined),
            label: const Text('Pilih Gambar'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jika gambar dipilih, file akan diupload ke Google Drive saat produk disimpan.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _productInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Produk',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 12),
          AppTextField(controller: _name, label: 'Nama Produk'),
          const SizedBox(height: 12),
          _categoryField(),
          const SizedBox(height: 12),
          AppTextField(controller: _barcode, label: 'Barcode'),
        ],
      ),
    );
  }

  Widget _priceStockCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Harga & Stok',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 520;
              final fields = [
                AppTextField(
                  controller: _buyPrice,
                  label: 'Harga Beli',
                  keyboardType: TextInputType.number,
                ),
                AppTextField(
                  controller: _sellPrice,
                  label: 'Harga Jual',
                  keyboardType: TextInputType.number,
                ),
              ];
              if (narrow) {
                return Column(
                  children: [fields[0], const SizedBox(height: 12), fields[1]],
                );
              }
              return Row(
                children: [
                  Expanded(child: fields[0]),
                  const SizedBox(width: 10),
                  Expanded(child: fields[1]),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 520;
              final stock = AppTextField(
                controller: _stock,
                label: 'Stok',
                keyboardType: TextInputType.number,
              );
              final unit = DropdownButtonFormField<String>(
                initialValue: _unit,
                decoration: const InputDecoration(labelText: 'Satuan'),
                items: AppConstants.units
                    .map(
                      (unit) =>
                          DropdownMenuItem(value: unit, child: Text(unit)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _unit = value ?? 'pcs'),
              );
              if (narrow) {
                return Column(
                  children: [stock, const SizedBox(height: 12), unit],
                );
              }
              return Row(
                children: [
                  Expanded(child: stock),
                  const SizedBox(width: 10),
                  Expanded(child: unit),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _lowStock,
            label: 'Batas Stok Menipis',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _categoryField() {
    if (_loadingCategories) {
      return const _DisabledField(
        label: 'Kategori',
        value: 'Memuat kategori...',
        showSpinner: true,
      );
    }

    if (_categories.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_categoryError != null) ...[
            _inlineError(_categoryError!, _loadCategories),
            const SizedBox(height: 12),
          ] else ...[
            const Text(
              'Kategori belum tersedia. Isi kategori manual dulu.',
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
          ],
          AppTextField(controller: _categoryId, label: 'ID Kategori'),
          const SizedBox(height: 12),
          AppTextField(controller: _categoryName, label: 'Kategori'),
        ],
      );
    }

    return DropdownButtonFormField<CategoryModel>(
      initialValue: _selectedCategory,
      decoration: const InputDecoration(labelText: 'Kategori'),
      items: _categories
          .map(
            (category) =>
                DropdownMenuItem(value: category, child: Text(category.name)),
          )
          .toList(),
      onChanged: (category) {
        if (category == null) return;
        setState(() {
          _selectedCategory = category;
          _categoryId.text = category.id;
          _categoryName.text = category.name;
        });
      },
    );
  }

  Widget _inlineError(String message, VoidCallback onRetry) {
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
          TextButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}

class _DisabledField extends StatelessWidget {
  const _DisabledField({
    required this.label,
    required this.value,
    this.showSpinner = false,
  });

  final String label;
  final String value;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label, enabled: false),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (showSpinner)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageUrl, required this.imageBytes});

  final String imageUrl;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 180,
          width: double.infinity,
          color: AppColors.lightBlue,
          child: Image.memory(imageBytes!, fit: BoxFit.contain),
        ),
      );
    }
    return UniversalNetworkImage(
      imageUrl: imageUrl,
      height: 180,
      width: double.infinity,
      fit: BoxFit.contain,
      fallbackIcon: Icons.add_photo_alternate_outlined,
    );
  }
}
