import 'package:flutter/material.dart';

import '../../models/user_address_model.dart';
import '../../models/user_model.dart';
import '../../services/address_service.dart';
import '../../services/api_service.dart';
import '../../widgets/address_card.dart';
import '../../widgets/empty_state_widget.dart';
import 'add_edit_address_screen.dart';

class UserAddressScreen extends StatefulWidget {
  const UserAddressScreen({
    super.key,
    required this.user,
    this.pickMode = false,
  });

  final UserModel user;
  final bool pickMode;

  @override
  State<UserAddressScreen> createState() => _UserAddressScreenState();
}

class _UserAddressScreenState extends State<UserAddressScreen> {
  late final AddressService _service;
  late Future<List<UserAddressModel>> _future;

  @override
  void initState() {
    super.initState();
    _service = AddressService(ApiService());
    _future = _load();
  }

  Future<List<UserAddressModel>> _load() =>
      _service.getUserAddresses(widget.user.id);

  void _refresh() => setState(() => _future = _load());

  Future<void> _openForm({UserAddressModel? address}) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            AddEditAddressScreen(user: widget.user, address: address),
      ),
    );
    if (updated == true) {
      _refresh();
    }
  }

  Future<void> _delete(UserAddressModel address) async {
    final message = await _service.deleteAddress(
      userId: widget.user.id,
      addressId: address.id,
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
      appBar: AppBar(
        title: Text(widget.pickMode ? 'Pilih Alamat' : 'Alamat Saya'),
      ),
      body: FutureBuilder<List<UserAddressModel>>(
        future: _future,
        builder: (context, snapshot) {
          final addresses = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              if (addresses.isEmpty)
                const SizedBox(
                  height: 260,
                  child: EmptyStateWidget(
                    message: 'Belum ada alamat tersimpan',
                  ),
                )
              else
                ...addresses.map(
                  (address) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AddressCard(
                      address: address,
                      onTap: widget.pickMode
                          ? () => Navigator.pop(context, address)
                          : null,
                      trailing: widget.pickMode
                          ? null
                          : PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _openForm(address: address);
                                }
                                if (value == 'delete') {
                                  _delete(address);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Hapus'),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FutureBuilder<List<UserAddressModel>>(
        future: _future,
        builder: (context, snapshot) {
          final count = snapshot.data?.length ?? 0;
          return FloatingActionButton.extended(
            onPressed: count >= 3
                ? () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Maksimal 3 alamat tersimpan.'),
                    ),
                  )
                : () => _openForm(),
            icon: const Icon(Icons.add),
            label: const Text('Alamat'),
          );
        },
      ),
    );
  }
}
