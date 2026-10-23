import 'package:flutter/material.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class SensitiveBalance extends StatefulWidget {
  const SensitiveBalance({
    super.key,
    required this.amount,
    this.currency,
    this.style,
    this.maxLines = 1,
    this.textAlign,
  });

  final double amount;
  final AppCurrency? currency;
  final TextStyle? style;
  final int maxLines;
  final TextAlign? textAlign;

  @override
  State<SensitiveBalance> createState() => _SensitiveBalanceState();
}

class _SensitiveBalanceState extends State<SensitiveBalance> {
  final _store = AppStore.instance;
  late bool _hidePreference = _store.hideBalancesByDefault;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    final hidePreference = _store.hideBalancesByDefault;
    if (hidePreference != _hidePreference) {
      _hidePreference = hidePreference;
      if (hidePreference) _revealed = false;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hidden = _store.hideBalancesByDefault && !_revealed;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _store.hideBalancesByDefault
              ? () => setState(() => _revealed = !_revealed)
              : null,
          child: Text(
            hidden ? '***' : formatMoney(widget.amount, widget.currency),
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: widget.textAlign,
            style: widget.style,
          ),
        ),
        if (_store.hideBalancesByDefault)
          IconButton(
            tooltip: hidden ? context.l10n.showBalance : context.l10n.hideBalance,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            padding: EdgeInsets.zero,
            onPressed: () => setState(() => _revealed = !_revealed),
            icon: Icon(
              hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 17,
              color: widget.style?.color,
            ),
          ),
      ],
    );
  }
}
