import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../models/product_model.dart';
import '../../models/user_address_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/address_service.dart';
import '../../services/order_service.dart';
import '../../widgets/address_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/payment_method_card.dart';
import 'my_orders_screen.dart';
import 'user_address_screen.dart';

class OrderCheckoutScreen extends StatefulWidget {
  const OrderCheckoutScreen({
    super.key,
    required this.user,
    required this.product,
    required this.qty,
  });

  final UserModel user;
  final ProductModel product;
  final int qty;

  @override
  State<OrderCheckoutScreen> createState() => _OrderCheckoutScreenState();
}

class _OrderCheckoutScreenState extends State<OrderCheckoutScreen> {
  late final AddressService _addressService;
  late final OrderService _orderService;
  UserAddressModel? _selectedAddress;
  String _orderType = 'pickup';
  String _paymentMethod = 'cash_store';
  bool _loadingAddress = true;
  bool _saving = false;

  num get _subtotal => widget.product.sellPrice * widget.qty;

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _addressService = AddressService(api);
    _orderService = OrderService(api);
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final addresses = await _addressService.getUserAddresses(widget.user.id);
    if (!mounted) return;
    UserAddressModel? primary;
    for (final address in addresses) {
      if (address.isPrimary) {
        primary = address;
        break;
      }
    }
    setState(() {
      _selectedAddress =
          primary ?? (addresses.isEmpty ? null : addresses.first);
      _loadingAddress = false;
    });
  }

  Future<void> _pickAddress() async {
    final selected = await Navigator.of(context).push<UserAddressModel>(
      MaterialPageRoute(
        builder: (_) => UserAddressScreen(user: widget.user, pickMode: true),
      ),
    );
    if (selected != null) {
      setState(() => _selectedAddress = selected);
    }
    await _loadAddresses();
  }

  Future<void> _submit() async {
    if (_orderType == 'delivery' && _selectedAddress == null) {
      _show('Pilih alamat pengantaran dulu');
      return;
    }
    setState(() => _saving = true);
    final order = await _orderService.createOrder(
      userId: widget.user.id,
      productId: widget.product.id,
      qty: widget.qty,
      orderType: _orderType,
      addressId: _orderType == 'delivery' ? _selectedAddress?.id ?? '' : '',
      paymentMethod: _paymentMethod,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (order == null) {
      _show('Pesanan gagal dibuat');
      return;
    }
    _show('Pesanan berhasil dibuat');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MyOrdersScreen(user: widget.user)),
      (route) => route.isFirst,
    );
  }

  void _show(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proses Pesanan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _row(
                  'Harga',
                  '${formatRupiah(widget.product.sellPrice)} / ${widget.product.unit}',
                ),
                _row('Qty', '${widget.qty} ${widget.product.unit}'),
                const Divider(height: 24),
                _row('Total', formatRupiah(_subtotal), bold: true),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Metode Penerimaan',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _selectable(
            title: 'Diantar ke Alamat',
            subtitle: 'Pesanan dikirim ke alamat tersimpan',
            icon: Icons.delivery_dining_outlined,
            selected: _orderType == 'delivery',
            onTap: () => setState(() => _orderType = 'delivery'),
          ),
          const SizedBox(height: 10),
          _selectable(
            title: 'Ambil Sendiri di Warung',
            subtitle: 'Pesanan akan diambil langsung di Warungku',
            icon: Icons.storefront_outlined,
            selected: _orderType == 'pickup',
            onTap: () => setState(() => _orderType = 'pickup'),
          ),
          if (_orderType == 'delivery') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Alamat Pengantaran',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                TextButton(
                  onPressed: _pickAddress,
                  child: const Text('Kelola'),
                ),
              ],
            ),
            if (_loadingAddress)
              const Center(child: CircularProgressIndicator())
            else if (_selectedAddress == null)
              AppCard(
                onTap: _pickAddress,
                child: const Text('Belum ada alamat. Tambah alamat dulu.'),
              )
            else
              AddressCard(
                address: _selectedAddress!,
                selected: true,
                onTap: _pickAddress,
              ),
          ] else ...[
            const SizedBox(height: 14),
            const AppCard(
              child: Text(
                'Pesanan akan diambil langsung di Warungku. Bayar langsung ke admin saat mengambil pesanan.',
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Text(
            'Metode Pembayaran',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          PaymentMethodCard(
            title: 'COD',
            subtitle: 'Bayar saat pesanan diterima',
            icon: Icons.local_shipping_outlined,
            selected: _paymentMethod == 'cod',
            enabled: true,
            onTap: () => setState(() => _paymentMethod = 'cod'),
          ),
          const SizedBox(height: 10),
          PaymentMethodCard(
            title: 'Cash di Warung',
            subtitle: 'Bayar langsung saat mengambil pesanan',
            icon: Icons.store_mall_directory_outlined,
            selected: _paymentMethod == 'cash_store',
            enabled: true,
            onTap: () => setState(() => _paymentMethod = 'cash_store'),
          ),
          const SizedBox(height: 10),
          const PaymentMethodCard(
            title: 'QRIS',
            subtitle: 'Pembayaran QRIS belum aktif',
            icon: Icons.qr_code_2_outlined,
            selected: false,
            enabled: false,
            badge: 'Coming Soon',
          ),
          const SizedBox(height: 10),
          const PaymentMethodCard(
            title: 'E-Wallet',
            subtitle: 'Integrasi dompet digital menyusul',
            icon: Icons.account_balance_wallet_outlined,
            selected: false,
            enabled: false,
            badge: 'Coming Soon',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: AppButton(
          label: 'Pesan Sekarang',
          icon: Icons.shopping_bag_outlined,
          isLoading: _saving,
          onPressed: _saving ? null : _submit,
        ),
      ),
    );
  }

  Widget _selectable({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      backgroundColor: selected ? AppColors.lightBlue : Colors.white,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            selected ? Icons.radio_button_checked : Icons.circle_outlined,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

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
