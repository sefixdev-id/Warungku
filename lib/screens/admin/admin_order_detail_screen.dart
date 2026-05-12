import 'package:flutter/material.dart';

import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/order_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/order_status_chip.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  const AdminOrderDetailScreen({
    super.key,
    required this.admin,
    required this.orderId,
  });

  final UserModel admin;
  final String orderId;

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  late final OrderService _service;
  late Future<OrderModel?> _future;

  @override
  void initState() {
    super.initState();
    _service = OrderService(ApiService());
    _future = _load();
  }

  Future<OrderModel?> _load() => _service.getOrderDetail(
    orderId: widget.orderId,
    adminId: widget.admin.id,
  );

  void _refresh() => setState(() => _future = _load());

  Future<void> _updateStatus(String status) async {
    final message = await _service.updateOrderStatus(
      adminId: widget.admin.id,
      orderId: widget.orderId,
      orderStatus: status,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    _refresh();
  }

  Future<void> _markPaid() async {
    final message = await _service.updateOrderPaymentStatus(
      adminId: widget.admin.id,
      orderId: widget.orderId,
      paymentStatus: 'dibayar',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Order')),
      body: FutureBuilder<OrderModel?>(
        future: _future,
        builder: (context, snapshot) {
          final order = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (order == null) {
            return const Center(child: Text('Order tidak ditemukan'));
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
                            order.userName,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        OrderStatusChip(status: order.orderStatus),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(order.userPhone),
                    Text(formatDate(order.createdAt)),
                    const Divider(height: 24),
                    _row(
                      'Tipe',
                      order.orderType == 'delivery'
                          ? 'Diantar'
                          : 'Ambil di Warung',
                    ),
                    _row('Pembayaran', order.paymentMethod),
                    _row('Status bayar', order.paymentStatus),
                    if (order.addressSnapshot.isNotEmpty) ...[
                      const SizedBox(height: 8),
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
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _statusButton('Diproses', 'diproses'),
                  _statusButton('Dikirim', 'dikirim'),
                  _statusButton('Selesai', 'selesai'),
                  _statusButton('Batalkan', 'dibatalkan'),
                ],
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Konfirmasi Pembayaran',
                icon: Icons.payments_outlined,
                onPressed: order.paymentStatus == 'dibayar' ? null : _markPaid,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statusButton(String label, String status) => FilledButton.tonal(
    onPressed: () => _updateStatus(status),
    child: Text(label),
  );

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
