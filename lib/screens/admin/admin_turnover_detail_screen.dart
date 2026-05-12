import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/debt_service.dart';
import '../../services/product_service.dart';
import '../../services/turnover_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_widget.dart';

class AdminTurnoverDetailScreen extends StatefulWidget {
  const AdminTurnoverDetailScreen({super.key, required this.admin});

  final UserModel admin;

  @override
  State<AdminTurnoverDetailScreen> createState() =>
      _AdminTurnoverDetailScreenState();
}

class _AdminTurnoverDetailScreenState extends State<AdminTurnoverDetailScreen> {
  late final TurnoverService _service;
  TurnoverPeriod _period = TurnoverPeriod.today;

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _service = TurnoverService(
      debtService: DebtService(api),
      productService: ProductService(api),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Rincian Perputaran',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: FutureBuilder<TurnoverStats>(
        future: _service.getStats(adminId: widget.admin.id, period: _period),
        builder: (context, snapshot) {
          final stats = snapshot.data;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _periodPicker(),
              const SizedBox(height: 14),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SizedBox(
                  height: 240,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (stats == null)
                const EmptyStateWidget(
                  message: 'Data perputaran gagal dimuat',
                  icon: Icons.receipt_long_outlined,
                )
              else ...[
                _summary(stats),
                const SizedBox(height: 16),
                const Text(
                  'Barang Terjual',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (stats.items.isEmpty)
                  const SizedBox(
                    height: 260,
                    child: EmptyStateWidget(
                      message: 'Belum ada transaksi pada periode ini',
                      icon: Icons.shopping_bag_outlined,
                    ),
                  )
                else
                  ...stats.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${item.qty} ${item.unit} x ${formatRupiah(item.sellPrice)}',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                            const Divider(height: 22),
                            _row('Subtotal', formatRupiah(item.subtotal)),
                            _row(
                              'Estimasi keuntungan',
                              formatRupiah(item.profit),
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _periodPicker() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _periodChip(TurnoverPeriod.today, 'Hari Ini'),
          _periodChip(TurnoverPeriod.week, 'Minggu Ini'),
          _periodChip(TurnoverPeriod.month, 'Bulan Ini'),
          _periodChip(TurnoverPeriod.year, 'Tahun Ini'),
        ],
      ),
    );
  }

  Widget _periodChip(TurnoverPeriod period, String label) {
    final selected = _period == period;
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
        onSelected: (_) => setState(() => _period = period),
      ),
    );
  }

  Widget _summary(TurnoverStats stats) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Periode',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metric(
                  'Perputaran',
                  formatRupiah(stats.totalTurnover),
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _metric(
                  'Keuntungan',
                  formatRupiah(stats.totalProfit),
                  AppColors.success,
                ),
              ),
              Expanded(
                child: _metric('Qty', '${stats.totalQty}', AppColors.warning),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _row(String left, String right, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(left, style: const TextStyle(color: AppColors.muted)),
          ),
          Text(
            right,
            style: TextStyle(
              color: color ?? AppColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
