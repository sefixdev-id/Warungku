import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../models/debt_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/debt_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/debt_status_chip.dart';
import '../../widgets/empty_state_widget.dart';
import 'add_debt_screen.dart';
import 'admin_debt_detail_screen.dart';

class AdminDebtListScreen extends StatefulWidget {
  const AdminDebtListScreen({
    super.key,
    required this.admin,
    this.initialFilter = 'semua',
  });

  final UserModel admin;
  final String initialFilter;

  @override
  State<AdminDebtListScreen> createState() => _AdminDebtListScreenState();
}

class _AdminDebtListScreenState extends State<AdminDebtListScreen> {
  late final DebtService _service;
  final _search = TextEditingController();
  var _allDebts = <DebtModel>[];
  var _loading = true;
  String? _error;
  String _filter = 'semua';

  @override
  void initState() {
    super.initState();
    _service = DebtService(ApiService());
    _filter = widget.initialFilter;
    _loadDebts();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadDebts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final debts = await _service.getAllDebts(widget.admin.id);
      if (!mounted) return;
      setState(() => _allDebts = debts);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Gagal memuat data hutang');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaries = _filteredSummaries();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Hutang',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Menu',
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddDebtScreen(admin: widget.admin),
            ),
          );
          _loadDebts();
        },
        icon: const Icon(Icons.add),
        label: const Text('Hutang'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
              children: [
                AppSearchField(
                  hint: 'Cari pelanggan...',
                  controller: _search,
                  trailingIcon: Icons.filter_alt_outlined,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('semua', 'Semua'),
                      _filterChip('aktif', 'Aktif'),
                      _filterChip('belum_lunas', 'Belum Lunas'),
                      _filterChip('cicil', 'Cicil'),
                      _filterChip('lunas', 'Lunas'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _buildListArea(summaries),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListArea(List<_CustomerDebtSummary> summaries) {
    if (_loading) {
      return Column(
        key: const ValueKey('loading'),
        children: const [
          _DebtSkeletonCard(),
          SizedBox(height: 10),
          _DebtSkeletonCard(),
        ],
      );
    }
    if (_error != null) {
      return AppCard(
        key: const ValueKey('error'),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            AppButton(label: 'Coba Lagi', onPressed: _loadDebts),
          ],
        ),
      );
    }
    if (summaries.isEmpty) {
      return const SizedBox(
        key: ValueKey('empty'),
        height: 260,
        child: EmptyStateWidget(
          message: 'Belum ada data hutang dengan status ini',
          icon: Icons.receipt_long_outlined,
        ),
      );
    }
    return Column(
      key: ValueKey('list-$_filter-${_search.text}-${summaries.length}'),
      children: [
        ...summaries.map(
          (summary) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AdminDebtDetailScreen(
                      admin: widget.admin,
                      userId: summary.userId,
                    ),
                  ),
                );
                _loadDebts();
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.lightBlue,
                    child: Text(
                      summary.userName.isEmpty
                          ? '?'
                          : summary.userName.characters.first.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.userName,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          summary.userPhone,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total ${formatRupiah(summary.totalDebt)}',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatRupiah(summary.remainingDebt),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      DebtStatusChip(status: summary.status),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<_CustomerDebtSummary> _filteredSummaries() {
    final query = _search.text.trim().toLowerCase();
    final summaries = _groupByCustomer(_allDebts);
    return summaries.where((summary) {
      final matchFilter =
          _filter == 'semua' ||
          (_filter == 'aktif' && summary.remainingDebt > 0) ||
          summary.status == _filter;
      final matchQuery =
          query.isEmpty ||
          summary.userName.toLowerCase().contains(query) ||
          summary.userPhone.toLowerCase().contains(query);
      return matchFilter && matchQuery;
    }).toList();
  }

  List<_CustomerDebtSummary> _groupByCustomer(List<DebtModel> debts) {
    final grouped = <String, List<DebtModel>>{};
    for (final debt in debts) {
      final key = debt.userId.isEmpty ? debt.userPhone : debt.userId;
      grouped.putIfAbsent(key, () => []).add(debt);
    }

    final summaries = grouped.entries.map((entry) {
      final customerDebts = entry.value;
      customerDebts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return _CustomerDebtSummary.fromDebts(customerDebts);
    }).toList()..sort((a, b) => b.latestDate.compareTo(a.latestDate));
    return summaries;
  }

  Widget _filterChip(String value, String label) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text(label),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.border),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.text,
          fontWeight: FontWeight.w900,
        ),
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }
}

class _CustomerDebtSummary {
  const _CustomerDebtSummary({
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.totalDebt,
    required this.paidAmount,
    required this.remainingDebt,
    required this.status,
    required this.latestDate,
  });

  final String userId;
  final String userName;
  final String userPhone;
  final num totalDebt;
  final num paidAmount;
  final num remainingDebt;
  final String status;
  final DateTime latestDate;

  factory _CustomerDebtSummary.fromDebts(List<DebtModel> debts) {
    final first = debts.first;
    final status = debts.any((debt) => debt.status == 'belum_lunas')
        ? 'belum_lunas'
        : debts.any((debt) => debt.status == 'cicil')
        ? 'cicil'
        : 'lunas';
    return _CustomerDebtSummary(
      userId: first.userId,
      userName: first.userName,
      userPhone: first.userPhone,
      totalDebt: debts.fold<num>(0, (sum, debt) => sum + debt.totalDebt),
      paidAmount: debts.fold<num>(0, (sum, debt) => sum + debt.paidAmount),
      remainingDebt: debts.fold<num>(
        0,
        (sum, debt) => sum + debt.remainingDebt,
      ),
      status: status,
      latestDate: first.createdAt,
    );
  }
}

class _DebtSkeletonCard extends StatelessWidget {
  const _DebtSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          _box(48, 48, circle: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(140, 14),
                const SizedBox(height: 10),
                _box(100, 12),
              ],
            ),
          ),
          _box(80, 20),
        ],
      ),
    );
  }

  Widget _box(double width, double height, {bool circle = false}) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.border.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(circle ? 999 : 8),
    ),
  );
}
