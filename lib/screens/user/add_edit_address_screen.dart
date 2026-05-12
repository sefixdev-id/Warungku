import 'package:flutter/material.dart';

import '../../models/user_address_model.dart';
import '../../models/user_model.dart';
import '../../services/address_service.dart';
import '../../services/api_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

class AddEditAddressScreen extends StatefulWidget {
  const AddEditAddressScreen({super.key, required this.user, this.address});

  final UserModel user;
  final UserAddressModel? address;

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _label = TextEditingController();
  final _recipient = TextEditingController();
  final _phone = TextEditingController();
  final _fullAddress = TextEditingController();
  final _note = TextEditingController();
  late final AddressService _service;
  bool _isPrimary = false;
  bool _saving = false;

  bool get _valid =>
      _label.text.trim().isNotEmpty &&
      _recipient.text.trim().isNotEmpty &&
      _phone.text.trim().isNotEmpty &&
      _fullAddress.text.trim().isNotEmpty &&
      !_saving;

  @override
  void initState() {
    super.initState();
    _service = AddressService(ApiService());
    final address = widget.address;
    if (address != null) {
      _label.text = address.labelAddress;
      _recipient.text = address.recipientName;
      _phone.text = address.phone;
      _fullAddress.text = address.fullAddress;
      _note.text = address.note;
      _isPrimary = address.isPrimary;
    }
    for (final c in [_label, _recipient, _phone, _fullAddress]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _label.dispose();
    _recipient.dispose();
    _phone.dispose();
    _fullAddress.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_valid) return;
    setState(() => _saving = true);
    final message = await _service.saveAddress(
      isEdit: widget.address != null,
      address: {
        if (widget.address != null) 'addressId': widget.address!.id,
        'userId': widget.user.id,
        'labelAddress': _label.text.trim(),
        'recipientName': _recipient.text.trim(),
        'phone': _phone.text.trim(),
        'fullAddress': _fullAddress.text.trim(),
        'note': _note.text.trim(),
        'isPrimary': _isPrimary,
      },
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.address == null ? 'Tambah Alamat' : 'Edit Alamat';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              children: [
                AppTextField(controller: _label, label: 'Label alamat'),
                const SizedBox(height: 12),
                AppTextField(controller: _recipient, label: 'Nama penerima'),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _phone,
                  label: 'Nomor HP',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _fullAddress,
                  label: 'Alamat lengkap',
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _note,
                  label: 'Catatan opsional',
                  maxLines: 2,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isPrimary,
                  onChanged: (value) => setState(() => _isPrimary = value),
                  title: const Text('Jadikan alamat utama'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Simpan Alamat',
            icon: Icons.save_outlined,
            isLoading: _saving,
            onPressed: _valid ? _save : null,
          ),
        ],
      ),
    );
  }
}
