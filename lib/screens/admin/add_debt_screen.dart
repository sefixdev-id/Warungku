import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/debt_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({super.key, required this.admin});

  final UserModel admin;

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _userId = TextEditingController();
  final _productId = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _note = TextEditingController();
  late final DebtService _service;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _service = DebtService(ApiService());
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final message = await _service.addDebt(
      adminId: widget.admin.id,
      userId: _userId.text.trim(),
      note: _note.text.trim(),
      items: [
        {
          'productId': _productId.text.trim(),
          'qty': num.tryParse(_qty.text) ?? 1,
        },
      ],
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Hutang')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppTextField(controller: _userId, label: 'User ID pelanggan'),
          const SizedBox(height: 12),
          AppTextField(controller: _productId, label: 'Product ID'),
          const SizedBox(height: 12),
          AppTextField(
            controller: _qty,
            label: 'Qty',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(controller: _note, label: 'Catatan', maxLines: 3),
          const SizedBox(height: 20),
          AppButton(
            label: 'Simpan Hutang',
            icon: Icons.save_outlined,
            isLoading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
