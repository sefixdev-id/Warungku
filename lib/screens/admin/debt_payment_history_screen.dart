import 'package:flutter/material.dart';

import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../models/debt_payment_model.dart';
import '../../services/api_service.dart';
import '../../services/debt_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_widget.dart';

class DebtPaymentHistoryScreen extends StatelessWidget {
  const DebtPaymentHistoryScreen({super.key, this.debtId, this.userId})
    : assert(debtId != null || userId != null);

  final String? debtId;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    final service = DebtService(ApiService());
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pembayaran')),
      body: FutureBuilder<List<DebtPaymentModel>>(
        future: userId == null
            ? service.getPaymentsByDebt(debtId!)
            : service.getPaymentsByUser(userId!),
        builder: (context, snapshot) {
          final payments = snapshot.data ?? [];
          if (payments.isEmpty) {
            return const EmptyStateWidget(message: 'Belum ada pembayaran');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  formatRupiah(payments[index].amount),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${payments[index].note}\n${formatDate(payments[index].createdAt)}',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
