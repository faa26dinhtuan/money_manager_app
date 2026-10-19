import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/formatters.dart';

const List<int> moneyQuickAmounts = [
  500000,
  1000000,
  2000000,
  5000000,
  10000000,
];

class MoneyController extends TextEditingController {
  MoneyController([double amount = 0]) {
    this.amount = amount;
  }

  double get amount => double.tryParse(text.replaceAll('.', '')) ?? 0;

  set amount(double value) {
    text = value <= 0 ? '' : groupDigits(value.round().toString());
  }
}

class MoneyField extends StatelessWidget {
  const MoneyField({
    super.key,
    required this.controller,
    this.title = 'Nhập số tiền',
    this.decoration = const InputDecoration(hintText: '0'),
    this.style,
    this.onChanged,
  });

  final MoneyController controller;
  final String title;
  final InputDecoration decoration;
  final TextStyle? style;
  final ValueChanged<double>? onChanged;

  Future<void> _open(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final result = await showMoneyKeypad(
      context,
      initial: controller.amount,
      title: title,
    );
    if (result == null) return;
    controller.amount = result;
    onChanged?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      showCursor: false,
      enableInteractiveSelection: false,
      style: style,
      decoration: decoration,
      onTap: () => _open(context),
    );
  }
}

Future<double?> showMoneyKeypad(
  BuildContext context, {
  double initial = 0,
  String title = 'Nhập số tiền',
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _MoneyKeypad(initial: initial, title: title),
  );
}

class _MoneyKeypad extends StatefulWidget {
  const _MoneyKeypad({required this.initial, required this.title});

  final double initial;
  final String title;

  @override
  State<_MoneyKeypad> createState() => _MoneyKeypadState();
}

class _MoneyKeypadState extends State<_MoneyKeypad> {
  static const int _maxDigits = 12;

  late String _digits =
      widget.initial > 0 ? widget.initial.round().toString() : '';

  double get _amount => _digits.isEmpty ? 0 : double.parse(_digits);

  void _append(String add) {
    if (_digits.isEmpty && add.startsWith('0')) return;
    if (_digits.length + add.length > _maxDigits) return;
    setState(() => _digits += add);
  }

  void _backspace() {
    if (_digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  void _clear() => setState(() => _digits = '');

  Widget _key(String label, {VoidCallback? onTap, VoidCallback? onLongPress}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap ?? () => _append(label),
            onLongPress: onLongPress,
            child: SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _backspaceKey() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _backspace,
            onLongPress: _clear,
            child: const SizedBox(
              height: 56,
              child: Center(child: Icon(Icons.backspace_outlined)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
                TextButton(
                  onPressed: _digits.isEmpty ? null : _clear,
                  child: const Text('Xóa hết'),
                ),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${_digits.isEmpty ? '0' : groupDigits(_digits)} ₫',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _digits.isEmpty ? Colors.black26 : AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                for (final a in moneyQuickAmounts)
                  ActionChip(
                    label: Text(groupDigits(a.toString())),
                    onPressed: () => _append(a.toString()),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [_key('1'), _key('2'), _key('3')]),
            Row(children: [_key('4'), _key('5'), _key('6')]),
            Row(children: [_key('7'), _key('8'), _key('9')]),
            Row(children: [_key('000'), _key('0'), _backspaceKey()]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(_amount),
                child: const Text('Xong', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
