import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/formatters.dart';

Future<DateTimeRange?> showAppDateRangePicker(
  BuildContext context, {
  DateTimeRange? initial,
}) {
  return showDialog<DateTimeRange>(
    context: context,
    builder: (_) => _DateRangeDialog(initial: initial),
  );
}

enum _Field { start, end }

class _DateRangeDialog extends StatefulWidget {
  const _DateRangeDialog({this.initial});

  final DateTimeRange? initial;

  @override
  State<_DateRangeDialog> createState() => _DateRangeDialogState();
}

class _DateRangeDialogState extends State<_DateRangeDialog> {
  static const _minYear = 2000;
  static const _maxYear = 2100;
  static const _weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  DateTime? _start;
  DateTime? _end;
  late DateTime _month;
  _Field _active = _Field.start;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _start = _dateOnly(initial.start);
      _end = _dateOnly(initial.end);
      _syncFields();
    }
    final base = _start ?? DateTime.now();
    _month = DateTime(base.year, base.month);
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime? _parse(String text) {
    final parts = text.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    if (year < _minYear || year > _maxYear) return null;
    final date = DateTime(year, month, day);
    if (date.day != day || date.month != month) return null;
    return date;
  }

  void _syncFields() {
    _startCtrl.text = _start == null ? '' : formatDate(_start!);
    _endCtrl.text = _end == null ? '' : formatDate(_end!);
  }

  void _selectDay(DateTime day) {
    setState(() {
      final start = _start;
      if (_active == _Field.start) {
        _start = day;
        final end = _end;
        if (end != null && end.isBefore(day)) _end = null;
        _active = _Field.end;
      } else if (start == null || day.isBefore(start)) {
        _start = day;
        _end = null;
      } else {
        _end = day;
      }
      _syncFields();
    });
  }

  void _onTextChanged(_Field field, String text) {
    final date = text.length == 10 ? _parse(text) : null;
    setState(() {
      if (field == _Field.start) {
        _start = date;
      } else {
        _end = date;
      }
      if (date != null) _month = DateTime(date.year, date.month);
    });
  }

  String? _errorFor(_Field field) {
    final isStart = field == _Field.start;
    final text = (isStart ? _startCtrl : _endCtrl).text;
    final date = isStart ? _start : _end;
    if (text.length == 10 && date == null) return 'Ngày không hợp lệ';
    final start = _start;
    final end = _end;
    if (!isStart && start != null && end != null && end.isBefore(start)) {
      return 'Phải sau ngày bắt đầu';
    }
    return null;
  }

  bool get _canConfirm {
    final start = _start;
    final end = _end;
    return start != null && end != null && !end.isBefore(start);
  }

  void _shiftMonth(int months) {
    final next = DateTime(_month.year, _month.month + months);
    if (next.year < _minYear || next.year > _maxYear) return;
    setState(() => _month = next);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.surfaceColor,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Chọn khoảng thời gian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const AppIcon(AppIcons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _dateField(_Field.start)),
                  const SizedBox(width: 12),
                  Expanded(child: _dateField(_Field.end)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _navButton(AppIcons.doubleLeft, () => _shiftMonth(-12)),
                  _navButton(AppIcons.chevronLeft, () => _shiftMonth(-1)),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Tháng ${_month.month}, ${_month.year}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  _navButton(AppIcons.chevronRight, () => _shiftMonth(1)),
                  _navButton(AppIcons.doubleRight, () => _shiftMonth(12)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  for (final w in _weekdays)
                    Expanded(
                      child: Center(
                        child: Text(
                          w,
                          style: TextStyle(
                            color: context.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              ..._buildWeeks(),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _canConfirm
                      ? () => Navigator.of(context).pop(
                            DateTimeRange(start: _start!, end: _end!),
                          )
                      : null,
                  child: const Text('Xác nhận'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(AppIconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: AppIcon(icon),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }

  Widget _dateField(_Field field) {
    final isStart = field == _Field.start;
    final active = _active == field;
    return TextField(
      controller: isStart ? _startCtrl : _endCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: [_DateInputFormatter()],
      onTap: () => setState(() => _active = field),
      onChanged: (text) => _onTextChanged(field, text),
      decoration: InputDecoration(
        labelText: isStart ? 'Từ ngày' : 'Đến ngày',
        hintText: 'dd/mm/yyyy',
        errorText: _errorFor(field),
        isDense: true,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: active ? AppTheme.primary : context.textDisabled,
            width: active ? 2 : 1,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
    );
  }

  List<Widget> _buildWeeks() {
    final first = DateTime(_month.year, _month.month, 1);
    final leading = first.weekday - 1;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final weekCount = ((leading + daysInMonth) / 7).ceil();
    return [
      for (var w = 0; w < weekCount; w++)
        Row(
          children: [
            for (var d = 0; d < 7; d++)
              Expanded(child: _cell(w * 7 + d - leading + 1, daysInMonth)),
          ],
        ),
    ];
  }

  Widget _cell(int dayNumber, int daysInMonth) {
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const SizedBox(height: 44);
    }
    final day = DateTime(_month.year, _month.month, dayNumber);
    final start = _start;
    final end = _end;
    final isStart = start != null && day == start;
    final isEnd = end != null && day == end;
    final selected = isStart || isEnd;
    final inRange =
        start != null && end != null && day.isAfter(start) && day.isBefore(end);
    final isToday = day == _dateOnly(DateTime.now());
    return GestureDetector(
      onTap: () => _selectDay(day),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(vertical: 2),
        color: inRange ? AppTheme.primary.withValues(alpha: 0.15) : null,
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppTheme.primary : null,
              border: isToday && !selected
                  ? Border.all(color: AppTheme.primary)
                  : null,
            ),
            child: Text(
              '$dayNumber',
              style: TextStyle(
                color: selected ? Colors.white : context.textPrimary,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 8 ? digits.substring(0, 8) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < trimmed.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(trimmed[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
