import 'package:money_manager_app/core/utils/date_range.dart';
import 'package:money_manager_app/core/utils/debt_status.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/utils/goal_status.dart';
import 'package:money_manager_app/data/services/app_store.dart';

enum ExportSection {
  transactions('Giao dịch'),
  wallets('Ví tiền'),
  budgets('Ngân sách tháng này'),
  goals('Mục tiêu tiết kiệm'),
  debts('Sổ nợ'),
  recurrings('Giao dịch định kỳ');

  const ExportSection(this.label);
  final String label;
}

String _cell(String value) {
  if (value.contains(RegExp(r'[",\r\n]'))) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

String _amount(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

String _date(DateTime? d) => d == null ? '' : formatDate(d);

String _line(List<String> row) => row.map(_cell).join(',');

String _section(String title, List<String> header, List<List<String>> rows) {
  if (rows.isEmpty) return '';
  return [_line([title]), _line(header), ...rows.map(_line)].join('\r\n');
}

String exportToCsv(AppStore store, Set<ExportSection> selected) {
  final now = DateTime.now();
  final month = DateRange.of(Period.month, now);

  String walletName(String? id) =>
      id == null ? '' : (store.walletById(id)?.name ?? '');
  String categoryName(String id) => store.categoryById(id)?.name ?? 'Khác';

  final transactions = [...store.transactions]
    ..sort((a, b) => b.date.compareTo(a.date));

  final parts = <ExportSection, List<String>>{
    ExportSection.transactions: [
    _section(
      'GIAO DỊCH',
      ['Ngày', 'Loại', 'Danh mục', 'Ví', 'Số tiền', 'Ghi chú'],
      [
        for (final t in transactions)
          [
            _date(t.date),
            t.type.label,
            categoryName(t.categoryId),
            walletName(t.walletId),
            _amount(t.amount),
            t.note,
          ],
      ],
    ),
    ],
    ExportSection.wallets: [
    _section(
      'VÍ TIỀN',
      ['Tên ví', 'Số dư ban đầu', 'Số dư hiện tại'],
      [
        for (final w in store.wallets)
          [
            w.name,
            _amount(w.initialBalance),
            _amount(store.walletBalance(w.id)),
          ],
      ],
    ),
    ],
    ExportSection.budgets: [
    _section(
      'NGÂN SÁCH THÁNG ${now.month}/${now.year}',
      ['Danh mục', 'Hạn mức', 'Đã chi', 'Còn lại'],
      [
        for (final b in store.budgets)
          () {
            final spent = store.spentOfCategory(b.categoryId, month);
            return [
              categoryName(b.categoryId),
              _amount(b.limit),
              _amount(spent),
              _amount(b.limit - spent),
            ];
          }(),
      ],
    ),
    ],
    ExportSection.goals: [
    _section(
      'MỤC TIÊU TIẾT KIỆM',
      [
        'Tên mục tiêu',
        'Số tiền mục tiêu',
        'Đã tiết kiệm',
        'Còn thiếu',
        'Tiến độ',
        'Hạn',
        'Trạng thái',
      ],
      [
        for (final g in store.goals)
          [
            g.name,
            _amount(g.target),
            _amount(g.saved),
            _amount(g.remaining),
            formatPercent(g.progress * 100),
            _date(g.deadline),
            goalDeadlineText(g, now),
          ],
      ],
    ),
    _section(
      'LỊCH SỬ MỤC TIÊU',
      ['Mục tiêu', 'Ngày', 'Loại', 'Số tiền', 'Ví', 'Ghi chú'],
      [
        for (final g in store.goals)
          for (final e in [...g.entries]..sort((a, b) => b.date.compareTo(a.date)))
            [
              g.name,
              _date(e.date),
              e.isDeposit ? 'Nạp' : 'Rút',
              _amount(e.amount.abs()),
              walletName(e.walletId),
              e.note,
            ],
      ],
    ),
    ],
    ExportSection.debts: [
    _section(
      'SỔ NỢ',
      [
        'Loại',
        'Người',
        'Số tiền',
        'Đã thanh toán',
        'Còn lại',
        'Ngày phát sinh',
        'Hạn',
        'Ví',
        'Trạng thái',
        'Ghi chú',
      ],
      [
        for (final d in store.debts)
          [
            d.type.label,
            d.person,
            _amount(d.amount),
            _amount(d.paid),
            _amount(d.remaining),
            _date(d.date),
            _date(d.dueDate),
            walletName(d.walletId),
            debtDueText(d, now),
            d.note,
          ],
      ],
    ),
    _section(
      'LỊCH SỬ THANH TOÁN NỢ',
      ['Người', 'Loại', 'Ngày', 'Số tiền', 'Ví', 'Ghi chú'],
      [
        for (final d in store.debts)
          for (final p in [...d.payments]..sort((a, b) => b.date.compareTo(a.date)))
            [
              d.person,
              d.type.paymentLabel,
              _date(p.date),
              _amount(p.amount),
              walletName(p.walletId),
              p.note,
            ],
      ],
    ),
    ],
    ExportSection.recurrings: [
    _section(
      'GIAO DỊCH ĐỊNH KỲ',
      [
        'Loại',
        'Danh mục',
        'Ví',
        'Số tiền',
        'Tần suất',
        'Ngày bắt đầu',
        'Lần tiếp theo',
        'Ngày kết thúc',
        'Trạng thái',
        'Ghi chú',
      ],
      [
        for (final r in store.recurrings)
          [
            r.type.label,
            categoryName(r.categoryId),
            walletName(r.walletId),
            _amount(r.amount),
            r.frequency.label,
            _date(r.startDate),
            _date(r.nextDate),
            _date(r.endDate),
            r.isFinished
                ? 'Đã kết thúc'
                : (r.active ? 'Đang chạy' : 'Tạm dừng'),
            r.note,
          ],
      ],
    ),
    ],
  };

  return [
    for (final section in ExportSection.values)
      if (selected.contains(section)) ...parts[section]!,
  ].where((s) => s.isNotEmpty).join('\r\n\r\n');
}
