import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../models/debt_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/debt_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/debt_status_chip.dart';
import '../../widgets/empty_state_widget.dart';
import 'add_debt_screen.dart';
import 'admin_debt_detail_screen.dart';

class AdminDebtListScreen extends StatefulWidget {
  const AdminDebtListScreen({super.key, required this.admin});

  final UserModel admin;

  @override
  State<AdminDebtListScreen> createState() => _AdminDebtListScreenState();
}

class _AdminDebtListScreenState extends State<AdminDebtListScreen> {
  late final DebtService _service;
  final _search = TextEditingController();
  String _filter = 'semua';

  @override
  void initState() {
    super.initState();
    _service = DebtService(ApiService());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          setState(() {});
        },
        icon: const Icon(Icons.add),
        label: const Text('Hutang'),
      ),
      body: FutureBuilder<List<DebtModel>>(
        future: _service.getAllDebts(widget.admin.id),
        builder: (context, snapshot) {
          final debts = _filtered(snapshot.data ?? []);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (debts.isEmpty) {
            return const EmptyStateWidget(
              message: 'Belum ada hutang pelanggan',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
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
                    _filterChip('belum_lunas', 'Belum Lunas'),
                    _filterChip('cicil', 'Cicil'),
                    _filterChip('lunas', 'Lunas'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ...List.generate(debts.length, (index) {
                final debt = debts[index];
                return AppCard(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdminDebtDetailScreen(
                          admin: widget.admin,
                          debtId: debt.id,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.lightBlue,
                        child: Text(
                          debt.userName.isEmpty
                              ? '?'
                              : debt.userName.characters.first.toUpperCase(),
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
                              debt.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              debt.userPhone,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total ${formatRupiah(debt.totalDebt)}',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatRupiah(debt.remainingDebt),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          DebtStatusChip(status: debt.status),
                        ],
                      ),
                    ],
                  ),
                );
              }).expand((card) => [card, const SizedBox(height: 10)]),
            ],
          );
        },
      ),
    );
  }

  List<DebtModel> _filtered(List<DebtModel> debts) {
    final query = _search.text.trim().toLowerCase();
    return debts.where((debt) {
      final matchFilter = _filter == 'semua' || debt.status == _filter;
      final matchQuery =
          query.isEmpty ||
          debt.userName.toLowerCase().contains(query) ||
          debt.userPhone.toLowerCase().contains(query);
      return matchFilter && matchQuery;
    }).toList();
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
          fontWeight: FontWeight.w800,
        ),
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }
}
