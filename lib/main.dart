import 'package:flutter/material.dart';
import 'package:money_manager_app/app.dart';
import 'package:money_manager_app/core/utils/app_info.dart';
import 'package:money_manager_app/data/services/app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInfo.load();
  await AppStore.instance.load();
  runApp(const App());
}
