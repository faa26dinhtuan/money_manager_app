import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class WalletPicker extends StatelessWidget {
  const WalletPicker({
    super.key,
    required this.selectedId,
    required this.onChanged,
    this.allowNone = false,
  });

  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final bool allowNone;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (allowNone)
          ChoiceChip(
            label: const Text('Không gắn ví'),
            selected: selectedId == null,
            selectedColor: Colors.blueGrey.shade400,
            showCheckmark: false,
            labelStyle: TextStyle(
              color: selectedId == null ? Colors.white : context.textPrimary,
            ),
            onSelected: (_) => onChanged(null),
          ),
        for (final w in AppStore.instance.wallets)
          ChoiceChip(
            avatar: AppIcon(
              w.icon,
              size: 18,
              color: selectedId == w.id ? Colors.white : w.color,
            ),
            label: Text(w.name),
            selected: selectedId == w.id,
            selectedColor: w.color,
            showCheckmark: false,
            labelStyle: TextStyle(
              color: selectedId == w.id ? Colors.white : context.textPrimary,
            ),
            onSelected: (_) => onChanged(w.id),
          ),
      ],
    );
  }
}
