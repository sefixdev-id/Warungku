import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase config bisa ditambahkan nanti dengan flutterfire configure.
  }
  runApp(const WarungkuApp());
}
