import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../models/debt_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/debt_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/debt_status_chip.dart';
import 'add_debt_screen.dart';
import 'add_debt_payment_screen.dart';
import 'debt_payment_history_screen.dart';

class AdminDebtDetailScreen extends StatelessWidget {
  const AdminDebtDetailScreen({
    super.key,
    required this.admin,
    required this.debtId,
  });

  final UserModel admin;
  final String debtId;

  @override
  Widget build(BuildContext context) {
    final service = DebtService(ApiService());
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Hutang',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Riwayat pembayaran',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DebtPaymentHistoryScreen(debtId: debtId),
              ),
            ),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: FutureBuilder<DebtModel?>(
        future: service.getDebtDetail(debtId),
        builder: (context, snapshot) {
          final debt = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (debt == null) {
            return const Center(child: Text('Data tidak ditemukan'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.lightBlue,
                      child: Text(
                        debt.userName.isEmpty
                            ? '?'
                            : debt.userName.characters.first.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            debt.userName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            debt.userPhone,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bergabung: ${formatDate(debt.createdAt)}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DebtStatusChip(status: debt.status),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Row(
                  children: [
                    _metric('Total Hutang', debt.totalDebt),
                    _metric('Sudah Dibayar', debt.paidAmount, success: true),
                    _metric(
                      'Sisa Hutang',
                      debt.remainingDebt,
                      danger: debt.remainingDebt > 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Rincian Hutang',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatDate(debt.createdAt),
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DebtStatusChip(status: debt.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Invoice #${debt.id}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const Divider(height: 24),
                    ...debt.items.map(
                      (item) => _row(
                        '${item.productName}\n${item.qty} ${item.unit}',
                        formatRupiah(item.subtotal),
                      ),
                    ),
                    const Divider(height: 24),
                    _row('Total', formatRupiah(debt.totalDebt), bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Tambah Hutang',
                      icon: Icons.add,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddDebtScreen(admin: admin),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: 'Input Pembayaran',
                      icon: Icons.add,
                      backgroundColor: AppColors.success,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AddDebtPaymentScreen(admin: admin, debt: debt),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Riwayat Pembayaran',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DebtPaymentHistoryScreen(debtId: debtId),
                      ),
                    ),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              ...debt.payments
                  .take(3)
                  .map(
                    (payment) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        child: _row(
                          formatDate(payment.createdAt),
                          formatRupiah(payment.amount),
                          bold: true,
                        ),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _metric(
    String label,
    num value, {
    bool success = false,
    bool danger = false,
  }) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
        const SizedBox(height: 6),
        Text(
          formatRupiah(value),
          style: TextStyle(
            color: success
                ? AppColors.success
                : danger
                ? AppColors.danger
                : AppColors.text,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );

  Widget _row(String left, String right, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(left)),
        Text(
          right,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
