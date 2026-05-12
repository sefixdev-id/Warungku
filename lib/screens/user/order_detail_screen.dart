import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/order_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/order_status_chip.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({
    super.key,
    required this.user,
    required this.orderId,
  });

  final UserModel user;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final service = OrderService(ApiService());
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: FutureBuilder<OrderModel?>(
        future: service.getOrderDetail(orderId: orderId, userId: user.id),
        builder: (context, snapshot) {
          final order = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (order == null) {
            return const Center(child: Text('Pesanan tidak ditemukan'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Order #${order.id}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        OrderStatusChip(status: order.orderStatus),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatDate(order.createdAt),
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const Divider(height: 24),
                    _row(
                      'Tipe',
                      order.orderType == 'delivery'
                          ? 'Diantar'
                          : 'Ambil di Warung',
                    ),
                    _row('Pembayaran', _paymentLabel(order.paymentMethod)),
                    _row(
                      'Status pembayaran',
                      _paymentStatus(order.paymentStatus),
                    ),
                    if (order.addressSnapshot.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Alamat',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(order.addressSnapshot),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: _row(
                      '${item.productName}\n${item.qty} ${item.unit}',
                      formatRupiah(item.subtotal),
                      bold: true,
                    ),
                  ),
                ),
              ),
              AppCard(
                child: _row(
                  'Total',
                  formatRupiah(order.totalAmount),
                  bold: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _paymentLabel(String value) => switch (value) {
    'cod' => 'COD',
    'cash_store' => 'Cash di Warung',
    'qris' => 'QRIS',
    'ewallet' => 'E-Wallet',
    _ => value,
  };

  String _paymentStatus(String value) => switch (value) {
    'dibayar' => 'Dibayar',
    'menunggu_konfirmasi' => 'Menunggu konfirmasi',
    'dibatalkan' => 'Dibatalkan',
    _ => 'Belum dibayar',
  };

  Widget _row(String left, String right, {bool bold = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(child: Text(left)),
        Text(
          right,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
