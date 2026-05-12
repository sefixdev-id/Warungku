import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../models/debt_model.dart';
import '../../models/debt_item_model.dart';
import '../../models/debt_payment_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/debt_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/debt_status_chip.dart';
import '../../widgets/empty_state_widget.dart';

class MyDebtDetailScreen extends StatefulWidget {
  const MyDebtDetailScreen({
    super.key,
    required this.user,
    required this.debtId,
  });

  final UserModel user;
  final String debtId;

  @override
  State<MyDebtDetailScreen> createState() => _MyDebtDetailScreenState();
}

class _MyDebtDetailScreenState extends State<MyDebtDetailScreen> {
  late final DebtService _service;
  bool _isLoading = true;
  DebtModel? _debt;

  @override
  void initState() {
    super.initState();
    _service = DebtService(ApiService());
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    final debt = await _service.getDebtDetail(
      widget.debtId,
      userId: widget.user.id,
    );
    if (!mounted) return;
    setState(() {
      _debt = debt;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final debt = _debt;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Hutang')),
      body: RefreshIndicator(
        onRefresh: _loadDetail,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _isLoading && debt == null
                  ? ListView(
                      key: const ValueKey('loading'),
                      children: [
                        const SizedBox(height: 220),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    )
                  : debt == null
                  ? ListView(
                      key: const ValueKey('empty'),
                      padding: const EdgeInsets.all(16),
                      children: [
                        const SizedBox(height: 120),
                        const EmptyStateWidget(
                          icon: Icons.receipt_long_outlined,
                          message: 'Detail hutang tidak ditemukan',
                        ),
                      ],
                    )
                  : _DebtDetailContent(debt: debt),
            ),
          ),
        ),
      ),
    );
  }
}

class _DebtDetailContent extends StatelessWidget {
  const _DebtDetailContent({required this.debt});

  final DebtModel debt;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: ValueKey(debt.id),
      padding: const EdgeInsets.all(16),
      children: [
        _HeaderCard(debt: debt),
        const SizedBox(height: 18),
        const Text(
          'Rincian Barang',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (debt.items.isEmpty)
          const AppCard(
            child: Text(
              'Rincian barang belum tersedia',
              style: TextStyle(color: AppColors.muted),
            ),
          )
        else
          ...debt.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DebtItemCard(item: item),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Expanded(
              child: Text(
                'Riwayat Pembayaran',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (debt.payments.isEmpty)
          const AppCard(
            child: Text(
              'Belum ada pembayaran untuk hutang ini',
              style: TextStyle(color: AppColors.muted),
            ),
          )
        else
          ...debt.payments.map(
            (payment) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PaymentCard(payment: payment),
            ),
          ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.debt});

  final DebtModel debt;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Invoice #${debt.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    DebtStatusChip(status: debt.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        formatDate(debt.createdAt),
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _moneyRow('Total Hutang', debt.totalDebt),
                _moneyRow('Sudah Dibayar', debt.paidAmount, success: true),
                const Divider(height: 22),
                _moneyRow('Sisa Hutang', debt.remainingDebt, danger: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _moneyRow(
    String label,
    num value, {
    bool success = false,
    bool danger = false,
  }) {
    final color = success
        ? AppColors.success
        : danger && value > 0
        ? AppColors.danger
        : AppColors.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Text(
            formatRupiah(value),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtItemCard extends StatelessWidget {
  const _DebtItemCard({required this.item});

  final DebtItemModel item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_formatQty(item.qty)} ${item.unit} x ${formatRupiah(item.price)}',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatRupiah(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment});

  final DebtPaymentModel payment;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8EF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: AppColors.success,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(payment.createdAt),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                if (payment.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    payment.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatRupiah(payment.amount),
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatQty(num value) {
  if (value % 1 == 0) return value.toInt().toString();
  return value.toString();
}
