import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../models/debt_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/debt_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/debt_status_chip.dart';
import '../../widgets/empty_state_widget.dart';
import 'my_debt_detail_screen.dart';

class MyDebtScreen extends StatefulWidget {
  const MyDebtScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<MyDebtScreen> createState() => _MyDebtScreenState();
}

class _MyDebtScreenState extends State<MyDebtScreen> {
  late final DebtService _debtService;

  @override
  void initState() {
    super.initState();
    _debtService = DebtService(ApiService());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hutang Saya')),
      body: FutureBuilder<List<DebtModel>>(
        future: _debtService.getDebtsByUser(widget.user.id),
        builder: (context, snapshot) {
          final debts = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (debts.isEmpty) {
            return const EmptyStateWidget(message: 'Belum ada hutang');
          }
          final total = debts.fold<num>(0, (sum, item) => sum + item.totalDebt);
          final paid = debts.fold<num>(0, (sum, item) => sum + item.paidAmount);
          final remaining = debts.fold<num>(
            0,
            (sum, item) => sum + item.remainingDebt,
          );
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ringkasan Hutang',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _summaryRow('Total Hutang', total),
                          _summaryRow('Sudah Dibayar', paid),
                          const Divider(height: 24, color: Colors.white24),
                          _summaryRow(
                            'Sisa Hutang',
                            remaining,
                            danger: remaining > 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Daftar Hutang',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ...debts.map(
                    (debt) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MyDebtDetailScreen(
                              user: widget.user,
                              debtId: debt.id,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Hutang #${debt.id}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                DebtStatusChip(status: debt.status),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatDate(debt.createdAt),
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _debtLine('Total', debt.totalDebt),
                            _debtLine('Sudah Dibayar', debt.paidAmount),
                            _debtLine(
                              'Sisa',
                              debt.remainingDebt,
                              danger: debt.remainingDebt > 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppCard(
                    backgroundColor: AppColors.lightBlue,
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pembayaran hanya dapat dilakukan melalui Admin Warungku.',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _summaryRow(String label, num value, {bool danger = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
        Text(
          formatRupiah(value),
          style: TextStyle(
            color: danger ? const Color(0xFFFFD6D6) : Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );

  Widget _debtLine(String label, num value, {bool danger = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: AppColors.muted)),
        ),
        Text(
          formatRupiah(value),
          style: TextStyle(
            color: danger ? AppColors.danger : AppColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}
