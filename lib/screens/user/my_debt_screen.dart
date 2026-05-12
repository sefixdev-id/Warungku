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
  bool _isLoading = true;
  String? _error;
  List<DebtModel> _debts = [];

  @override
  void initState() {
    super.initState();
    _debtService = DebtService(ApiService());
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final debts = await _debtService.getDebtDetailsByUser(widget.user.id);
      if (!mounted) return;
      setState(() => _debts = debts);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _debts.fold<num>(0, (sum, item) => sum + item.totalDebt);
    final paid = _debts.fold<num>(0, (sum, item) => sum + item.paidAmount);
    final remaining = _debts.fold<num>(
      0,
      (sum, item) => sum + item.remainingDebt,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Hutang Saya')),
      body: RefreshIndicator(
        onRefresh: _loadDebts,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DebtSummaryCard(
                  total: total,
                  paid: paid,
                  remaining: remaining,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Daftar Hutang',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (_isLoading && _debts.isNotEmpty)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _buildDebtContent(),
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
        ),
      ),
    );
  }

  Widget _buildDebtContent() {
    if (_isLoading && _debts.isEmpty) {
      return const Padding(
        key: ValueKey('loading'),
        padding: EdgeInsets.symmetric(vertical: 56),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _debts.isEmpty) {
      return Padding(
        key: const ValueKey('error'),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: AppCard(
          child: Column(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.warning,
                size: 34,
              ),
              const SizedBox(height: 10),
              const Text(
                'Data hutang gagal dimuat',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _loadDebts,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_debts.isEmpty) {
      return const Padding(
        key: ValueKey('empty'),
        padding: EdgeInsets.symmetric(vertical: 34),
        child: EmptyStateWidget(
          icon: Icons.verified_outlined,
          message: 'Belum ada hutang\nSemua transaksi Anda masih lunas',
        ),
      );
    }

    return Column(
      key: ValueKey('debts-${_debts.length}'),
      children: _debts
          .map(
            (debt) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DebtCard(
                debt: debt,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        MyDebtDetailScreen(user: widget.user, debtId: debt.id),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DebtSummaryCard extends StatelessWidget {
  const _DebtSummaryCard({
    required this.total,
    required this.paid,
    required this.remaining,
  });

  final num total;
  final num paid;
  final num remaining;

  @override
  Widget build(BuildContext context) {
    final isClear = remaining <= 0;
    return AppCard(
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
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Ringkasan Hutang',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isClear ? 'Lunas' : 'Aktif',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Total Hutang',
                    value: total,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryMetric(
                    icon: Icons.check_circle_outline,
                    label: 'Sudah Dibayar',
                    value: paid,
                    color: const Color(0xFFBBF7D0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SummaryMetric(
              icon: remaining > 0
                  ? Icons.warning_amber_rounded
                  : Icons.verified_rounded,
              label: 'Sisa Hutang',
              value: remaining,
              color: remaining > 0
                  ? const Color(0xFFFFD6D6)
                  : const Color(0xFFBBF7D0),
              wide: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.wide = false,
  });

  final IconData icon;
  final String label;
  final num value;
  final Color color;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(value),
                  maxLines: wide ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({required this.debt, required this.onTap});

  final DebtModel debt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
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
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              DebtStatusChip(status: debt.status),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.muted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  formatDate(debt.createdAt),
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ItemPreview(debt: debt),
          const Divider(height: 24),
          _moneyLine('Total Hutang', debt.totalDebt),
          _moneyLine('Sudah Dibayar', debt.paidAmount, success: true),
          _moneyLine('Sisa Hutang', debt.remainingDebt, danger: true),
        ],
      ),
    );
  }

  Widget _moneyLine(
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
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Text(
            formatRupiah(value),
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _ItemPreview extends StatelessWidget {
  const _ItemPreview({required this.debt});

  final DebtModel debt;

  @override
  Widget build(BuildContext context) {
    if (debt.items.isEmpty) {
      return const Text(
        'Rincian barang belum tersedia',
        style: TextStyle(color: AppColors.muted),
      );
    }

    final visibleItems = debt.items.take(3).toList();
    final hiddenCount = debt.items.length - visibleItems.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in visibleItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${item.productName} x${_formatQty(item.qty)} ${item.unit}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        if (hiddenCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '+$hiddenCount item lainnya',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

String _formatQty(num value) {
  if (value % 1 == 0) return value.toInt().toString();
  return value.toString();
}
