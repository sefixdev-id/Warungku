import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../screens/user/user_main_screen.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/local_session_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final AuthService _authService;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(ApiService(), LocalSessionService());
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    final response = await _authService.register(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (!response.success || response.data == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
      return;
    }
    _openUser(response.data!);
  }

  void _openUser(UserModel user) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => UserMainScreen(user: user)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pelanggan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppTextField(
            controller: _name,
            label: 'Nama',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _phone,
            label: 'Nomor HP',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _email,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _password,
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Daftar',
            icon: Icons.person_add_alt,
            isLoading: _loading,
            onPressed: _register,
          ),
        ],
      ),
    );
  }
}
