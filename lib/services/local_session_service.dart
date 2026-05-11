import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class LocalSessionService {
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', user.id);
    await prefs.setString('name', user.name);
    await prefs.setString('email', user.email);
    await prefs.setString('phone', user.phone);
    await prefs.setString('role', user.role);
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isLoggedIn') != true) return null;
    return UserModel(
      id: prefs.getString('userId') ?? '',
      name: prefs.getString('name') ?? '',
      email: prefs.getString('email') ?? '',
      phone: prefs.getString('phone') ?? '',
      role: prefs.getString('role') ?? 'user',
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
