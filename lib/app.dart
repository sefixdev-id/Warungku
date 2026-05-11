import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'models/user_model.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/user/user_main_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/local_session_service.dart';

class WarungkuApp extends StatelessWidget {
  const WarungkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SessionGate(),
    );
  }
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late final AuthService _authService;
  late final Future<UserModel?> _session;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(ApiService(), LocalSessionService());
    _session = _authService.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _session,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) return const LoginScreen();
        return user.isAdmin
            ? AdminMainScreen(user: user)
            : UserMainScreen(user: user);
      },
    );
  }
}
