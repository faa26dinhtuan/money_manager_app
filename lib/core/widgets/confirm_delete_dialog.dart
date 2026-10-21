import 'package:flutter/cupertino.dart'
    show CupertinoAlertDialog, CupertinoDialogAction, showCupertinoDialog;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';

Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final l = context.l10n;
  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l.cancel),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l.delete),
        ),
      ],
    ),
  );
  final confirmed = result ?? false;
  if (confirmed) HapticFeedback.mediumImpact();
  return confirmed;
}
