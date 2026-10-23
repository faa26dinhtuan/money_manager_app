import 'package:flutter/material.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';

Future<bool> confirmBulkDelete(BuildContext context, int count) async {
  final l = context.l10n;
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.deleteSelectedTitle),
          content: Text(l.deleteSelectedMessage(count)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.delete)),
          ],
        ),
      ) ??
      false;
}

class BulkSelectionControls extends StatelessWidget {
  const BulkSelectionControls({
    super.key,
    required this.count,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onDelete,
  });

  final int count;
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: onSelectAll,
            child: Text(selectedCount == count ? l.clearAll : l.selectAll),
          ),
        ),
        IconButton(
          tooltip: l.delete,
          onPressed: selectedCount == 0 ? null : onDelete,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}

class BulkSelectableItem extends StatelessWidget {
  const BulkSelectableItem({
    super.key,
    required this.selecting,
    required this.selected,
    required this.onChanged,
    required this.child,
  });

  final bool selecting;
  final bool selected;
  final ValueChanged<bool?> onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!selecting) return child;
    return Row(
      children: [
        Checkbox(value: selected, onChanged: onChanged),
        Expanded(child: IgnorePointer(child: child)),
      ],
    );
  }
}
