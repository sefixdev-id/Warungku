import 'package:flutter/material.dart';

import '../../core/helpers/currency_helper.dart';
import '../../models/debt_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/debt_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/debt_status_chip.dart';

class MyDebtDetailScreen extends StatelessWidget {
  const MyDebtDetailScreen({
    super.key,
    required this.user,
    required this.debtId,
  });

  final UserModel user;
  final String debtId;

  @override
  Widget build(BuildContext context) {
    final service = DebtService(ApiService());
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Hutang')),
      body: FutureBuilder<DebtModel?>(
        future: service.getDebtDetail(debtId, userId: user.id),
        builder: (context, snapshot) {
          final debt = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (debt == null) {
            return const Center(child: Text('Detail hutang tidak ditemukan'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DebtStatusChip(status: debt.status),
                    const SizedBox(height: 12),
                    _row('Total', formatRupiah(debt.totalDebt)),
                    _row('Sudah dibayar', formatRupiah(debt.paidAmount)),
                    _row('Sisa', formatRupiah(debt.remainingDebt)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Barang',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ...debt.items.map(
                (item) => AppCard(
                  child: _row(
                    '${item.productName} x ${item.qty} ${item.unit}',
                    formatRupiah(item.subtotal),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Riwayat Pembayaran',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ...debt.payments.map(
                (item) => AppCard(
                  child: _row(
                    item.note.isEmpty ? 'Pembayaran' : item.note,
                    formatRupiah(item.amount),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String left, String right) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(left)),
        Text(right, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}
