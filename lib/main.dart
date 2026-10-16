import 'package:flutter/material.dart';
import 'package:money_manager_app/app.dart';
import 'package:money_manager_app/data/services/app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStore.instance.load();
  runApp(const App());
}
