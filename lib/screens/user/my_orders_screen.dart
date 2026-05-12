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
import 'order_detail_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final service = OrderService(ApiService());
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya')),
      body: FutureBuilder<List<OrderModel>>(
        future: service.getOrdersByUser(user.id),
        builder: (context, snapshot) {
          final orders = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (orders.isEmpty) {
            return const EmptyStateWidget(message: 'Belum ada pesanan');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final order = orders[index];
              return AppCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        OrderDetailScreen(user: user, orderId: order.id),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.id}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(formatDate(order.createdAt)),
                          const SizedBox(height: 4),
                          Text(formatRupiah(order.totalAmount)),
                        ],
                      ),
                    ),
                    OrderStatusChip(status: order.orderStatus),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
