import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/local_session_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, required this.userId});

  final String userId;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  late final AuthService _authService;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(ApiService(), LocalSessionService());
  }

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_oldPassword.text.isEmpty) {
      _show('Password lama wajib diisi');
      return;
    }
    if (_newPassword.text.length < 6) {
      _show('Password baru minimal 6 karakter');
      return;
    }
    if (_newPassword.text != _confirmPassword.text) {
      _show('Konfirmasi password tidak sama');
      return;
    }

    setState(() => _loading = true);
    final response = await _authService.changePassword(
      userId: widget.userId,
      oldPassword: _oldPassword.text,
      newPassword: _newPassword.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    _show(response.message);
    if (response.success) Navigator.of(context).pop();
  }

  void _show(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ganti Password',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      controller: _oldPassword,
                      label: 'Password lama',
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _newPassword,
                      label: 'Password baru',
                      icon: Icons.lock_reset_outlined,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _confirmPassword,
                      label: 'Konfirmasi password baru',
                      icon: Icons.verified_user_outlined,
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Simpan Password',
                icon: Icons.save_outlined,
                isLoading: _loading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
