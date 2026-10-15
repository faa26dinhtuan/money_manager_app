import 'package:flutter/material.dart';
import 'package:money_manager_app/data/models/category.dart';

class TypeTabs extends StatelessWidget {
  const TypeTabs({super.key, required this.type, required this.onChanged});

  final TxType type;
  final ValueChanged<TxType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final t in TxType.values)
          Expanded(
            child: InkWell(
              onTap: () => onChanged(t),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: t == type ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    t.label,
                    style: TextStyle(
                      color: t == type ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
