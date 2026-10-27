import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TimeOfDay, Theme;
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';

Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final lower = DateTime(firstDate.year, firstDate.month, firstDate.day);
  final upper = DateTime(lastDate.year, lastDate.month, lastDate.day);
  final requested = DateTime(initialDate.year, initialDate.month, initialDate.day);
  var selected = requested.isBefore(lower)
      ? lower
      : requested.isAfter(upper)
      ? upper
      : requested;
  final l = context.l10n;
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (sheetContext) => CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Theme.of(context).brightness,
        primaryColor: AppTheme.primary,
      ),
      child: Container(
        color: CupertinoColors.systemBackground.resolveFrom(sheetContext),
        padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(sheetContext).bottom),
        child: SizedBox(
          height: 268,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(l.cancel),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(sheetContext).pop(selected),
                    child: Text(l.done),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selected,
                  minimumDate: lower,
                  maximumDate: upper,
                  onDateTimeChanged: (value) => selected = DateTime(value.year, value.month, value.day),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<TimeOfDay?> showAppTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  var selected = DateTime(2020, 1, 1, initialTime.hour, initialTime.minute);
  final l = context.l10n;
  return showCupertinoModalPopup<TimeOfDay>(
    context: context,
    builder: (sheetContext) => CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Theme.of(context).brightness,
        primaryColor: AppTheme.primary,
      ),
      child: Container(
        color: CupertinoColors.systemBackground.resolveFrom(sheetContext),
        padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(sheetContext).bottom),
        child: SizedBox(
          height: 268,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(l.cancel),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(sheetContext).pop(TimeOfDay.fromDateTime(selected)),
                    child: Text(l.done),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: selected,
                  use24hFormat: MediaQuery.of(sheetContext).alwaysUse24HourFormat,
                  onDateTimeChanged: (value) => selected = value,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}