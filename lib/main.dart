import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:money_manager_app/app.dart';
import 'package:money_manager_app/core/utils/app_info.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/data/services/event_reminder_service.dart';
import 'package:money_manager_app/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInfo.load();
  await EventReminderService.instance.initialize();
  await AppStore.instance.load();
  await EventReminderService.instance.sync(
    AppStore.instance.allPlannedEvents,
    localization: lookupAppLocalizations(
      AppStore.instance.locale ?? PlatformDispatcher.instance.locale,
    ),
  );
  runApp(const App());
}
