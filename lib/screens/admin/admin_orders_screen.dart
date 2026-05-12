import 'package:flutter/material.dart';

import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/order_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/order_status_chip.dart';
import 'admin_order_detail_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key, required this.admin});

  final UserModel admin;

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  late final OrderService _service;
  String _filter = 'semua';

  @override
  void initState() {
    super.initState();
    _service = OrderService(ApiService());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Masuk')),
      body: FutureBuilder<List<OrderModel>>(
        future: _service.getAllOrdersForAdmin(widget.admin.id),
        builder: (context, snapshot) {
          final orders = (snapshot.data ?? [])
              .where(
                (order) => _filter == 'semua' || order.orderStatus == _filter,
              )
              .toList();
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('semua', 'Semua'),
                    _chip('diterima', 'Diterima'),
                    _chip('diproses', 'Diproses'),
                    _chip('dikirim', 'Dikirim'),
                    _chip('selesai', 'Selesai'),
                    _chip('dibatalkan', 'Dibatalkan'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (orders.isEmpty)
                const SizedBox(
                  height: 260,
                  child: EmptyStateWidget(message: 'Belum ada order'),
                )
              else
                ...orders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AdminOrderDetailScreen(
                            admin: widget.admin,
                            orderId: order.id,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text('Order #${order.id}'),
                                Text(formatDate(order.createdAt)),
                                Text(formatRupiah(order.totalAmount)),
                              ],
                            ),
                          ),
                          OrderStatusChip(status: order.orderStatus),
                        ],
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

  Widget _chip(String value, String label) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }
}
