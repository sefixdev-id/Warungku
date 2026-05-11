import 'package:flutter/material.dart';

import '../../models/debt_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/debt_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class AddDebtPaymentScreen extends StatefulWidget {
  const AddDebtPaymentScreen({
    super.key,
    required this.admin,
    required this.debt,
  });

  final UserModel admin;
  final DebtModel debt;

  @override
  State<AddDebtPaymentScreen> createState() => _AddDebtPaymentScreenState();
}

class _AddDebtPaymentScreenState extends State<AddDebtPaymentScreen> {
  final _amount = TextEditingController();
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
    final message = await _service.addPayment(
      adminId: widget.admin.id,
      debtId: widget.debt.id,
      amount: num.tryParse(_amount.text) ?? 0,
      note: _note.text.trim(),
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
      appBar: AppBar(title: const Text('Input Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppTextField(
            controller: _amount,
            label: 'Nominal pembayaran',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(controller: _note, label: 'Catatan', maxLines: 3),
          const SizedBox(height: 20),
          AppButton(
            label: 'Simpan Pembayaran',
            icon: Icons.payments_outlined,
            isLoading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
