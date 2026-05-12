import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../models/debt_model.dart';
import '../../models/debt_payment_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/debt_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/debt_status_chip.dart';
import 'add_debt_payment_screen.dart';
import 'add_debt_screen.dart';
import 'debt_payment_history_screen.dart';

class AdminDebtDetailScreen extends StatefulWidget {
  const AdminDebtDetailScreen({
    super.key,
    required this.admin,
    this.debtId,
    this.userId,
  }) : assert(debtId != null || userId != null);

  final UserModel admin;
  final String? debtId;
  final String? userId;

  @override
  State<AdminDebtDetailScreen> createState() => _AdminDebtDetailScreenState();
}

class _AdminDebtDetailScreenState extends State<AdminDebtDetailScreen> {
  late final DebtService _service;
  _DebtDetailBundle? _bundle;
  bool _loading = true;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _service = DebtService(ApiService());
    _loadInitial();
  }

  Future<_DebtDetailBundle?> _loadBundle() async {
    if (widget.userId != null) {
      final debts = await _service.getDebtDetailsByUser(widget.userId!);
      if (debts.isEmpty) return null;
      return _DebtDetailBundle.fromDebts(debts);
    }

    final debt = await _service.getDebtDetail(widget.debtId!);
    if (debt == null) return null;
    return _DebtDetailBundle.fromDebts([debt]);
  }

  Future<void> _loadInitial() async {
    final bundle = await _loadBundle();
    if (!mounted) return;
    setState(() {
      _bundle = bundle;
      _loading = false;
    });
  }

  Future<void> _refresh({bool waitForSheet = false}) async {
    if (waitForSheet) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
    }
    if (!mounted) return;
    setState(() => _refreshing = true);
    final bundle = await _loadBundle();
    if (!mounted) return;
    setState(() {
      _bundle = bundle;
      _loading = false;
      _refreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                builder: (_) => DebtPaymentHistoryScreen(
                  debtId: widget.userId == null ? widget.debtId : null,
                  userId: widget.userId,
                ),
              ),
            ),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final bundle = _bundle;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (bundle == null) {
      return const Center(child: Text('Data tidak ditemukan'));
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_refreshing) ...[
            const LinearProgressIndicator(minHeight: 2),
            const SizedBox(height: 12),
          ],
          _profileCard(context, bundle),
          const SizedBox(height: 12),
          _summaryCard(bundle),
          const SizedBox(height: 18),
          const Text(
            'Rincian Hutang',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ...bundle.debts.map(
            (debt) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _debtCard(debt),
            ),
          ),
          const SizedBox(height: 4),
          _actionButtons(bundle),
          const SizedBox(height: 18),
          _paymentHeader(bundle),
          ...bundle.payments
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _profileCard(BuildContext context, _DebtDetailBundle bundle) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.lightBlue,
            child: Text(
              bundle.userName.isEmpty
                  ? '?'
                  : bundle.userName.characters.first.toUpperCase(),
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
                  bundle.userName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bundle.userPhone,
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bergabung: ${formatDate(bundle.createdAt)}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          DebtStatusChip(status: bundle.status),
        ],
      ),
    );
  }

  Widget _summaryCard(_DebtDetailBundle bundle) {
    return AppCard(
      child: Row(
        children: [
          _metric('Total Hutang', bundle.totalDebt),
          _metric('Sudah Dibayar', bundle.paidAmount, success: true),
          _metric(
            'Sisa Hutang',
            bundle.remainingDebt,
            danger: bundle.remainingDebt > 0,
          ),
        ],
      ),
    );
  }

  Widget _debtCard(DebtModel debt) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatDate(debt.createdAt),
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
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
    );
  }

  Widget _actionButtons(_DebtDetailBundle bundle) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final addDebtButton = AppButton(
          label: 'Tambah Hutang',
          icon: Icons.add,
          onPressed: () async {
            final updated = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => AddDebtScreen(admin: widget.admin),
              ),
            );
            if (updated == true) await _refresh(waitForSheet: true);
          },
        );
        final paymentTarget = bundle.paymentTarget;
        final paymentButton = AppButton(
          label: 'Input Pembayaran',
          icon: Icons.add,
          backgroundColor: AppColors.success,
          onPressed: paymentTarget == null
              ? null
              : () async {
                  final result = await Navigator.of(context).push<Object?>(
                    MaterialPageRoute(
                      builder: (_) => AddDebtPaymentScreen(
                        admin: widget.admin,
                        debt: paymentTarget,
                      ),
                    ),
                  );
                  if (_isUpdatedResult(result)) {
                    await _refresh(waitForSheet: true);
                  }
                },
        );

        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              addDebtButton,
              const SizedBox(height: 10),
              paymentButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: addDebtButton),
            const SizedBox(width: 10),
            Expanded(child: paymentButton),
          ],
        );
      },
    );
  }

  bool _isUpdatedResult(Object? result) {
    if (result == true) return true;
    if (result is Map) return result['updated'] == true;
    return false;
  }

  Widget _paymentHeader(_DebtDetailBundle bundle) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Riwayat Pembayaran',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DebtPaymentHistoryScreen(
                debtId: widget.userId == null ? widget.debtId : null,
                userId: widget.userId,
              ),
            ),
          ),
          child: const Text('Lihat Semua'),
        ),
      ],
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
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            right,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _DebtDetailBundle {
  const _DebtDetailBundle({
    required this.debts,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.totalDebt,
    required this.paidAmount,
    required this.remainingDebt,
    required this.status,
    required this.createdAt,
    required this.payments,
  });

  final List<DebtModel> debts;
  final String userId;
  final String userName;
  final String userPhone;
  final num totalDebt;
  final num paidAmount;
  final num remainingDebt;
  final String status;
  final DateTime createdAt;
  final List<DebtPaymentModel> payments;

  DebtModel? get paymentTarget {
    for (final debt in debts) {
      if (debt.remainingDebt > 0) return debt;
    }
    return null;
  }

  factory _DebtDetailBundle.fromDebts(List<DebtModel> debts) {
    final sorted = [...debts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final first = sorted.first;
    final payments = sorted.expand((debt) => debt.payments).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final status = sorted.any((debt) => debt.status == 'belum_lunas')
        ? 'belum_lunas'
        : sorted.any((debt) => debt.status == 'cicil')
        ? 'cicil'
        : 'lunas';

    return _DebtDetailBundle(
      debts: sorted,
      userId: first.userId,
      userName: first.userName,
      userPhone: first.userPhone,
      totalDebt: sorted.fold<num>(0, (sum, debt) => sum + debt.totalDebt),
      paidAmount: sorted.fold<num>(0, (sum, debt) => sum + debt.paidAmount),
      remainingDebt: sorted.fold<num>(
        0,
        (sum, debt) => sum + debt.remainingDebt,
      ),
      status: status,
      createdAt: sorted.last.createdAt,
      payments: payments,
    );
  }
}
