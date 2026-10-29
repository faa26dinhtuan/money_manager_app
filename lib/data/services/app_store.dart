import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/date_range.dart';
import 'package:money_manager_app/data/models/backup_data.dart';
import 'package:money_manager_app/data/models/budget.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/debt.dart';
import 'package:money_manager_app/data/models/goal.dart';
import 'package:money_manager_app/data/models/planned_event.dart';
import 'package:money_manager_app/data/models/recurring_transaction.dart';
import 'package:money_manager_app/data/models/transaction.dart';
import 'package:money_manager_app/data/models/wallet.dart';
import 'package:money_manager_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStore extends ChangeNotifier {
  AppStore._();
  static final AppStore instance = AppStore._();

  static const _categoriesKey = 'categories';
  static const _transactionsKey = 'transactions';
  static const _walletsKey = 'wallets';
  static const _budgetsKey = 'budgets';
  static const _goalsKey = 'goals';
  static const _debtsKey = 'debts';
  static const _recurringsKey = 'recurrings';
  static const _plannedEventsKey = 'plannedEvents';
  static const _onboardedKey = 'onboarded';
  static const _overviewGuideShownKey = 'overviewGuideShown';
  static const _legacySeedCleanupKey = 'legacySampleDataCleanedV1';
  static const guideCashWalletId = 'guide_cash';
  static const _themeModeKey = 'themeMode';
  static const _currencyKey = 'currency';
  static const _selectedWalletKey = 'selectedWallet';
  static const _localeKey = 'locale';
  static const _hideBalancesKey = 'hideBalancesByDefault';
  static const _dateFormatKey = 'dateFormat';
  static const _currencyConversionUndoKey = 'currencyConversionUndo';

  late final SharedPreferences _prefs;

  final List<Category> _categories = [];
  final List<Transaction> _transactions = [];
  final List<Wallet> _wallets = [];
  final List<Budget> _budgets = [];
  final List<Goal> _goals = [];
  final List<Debt> _debts = [];
  final List<RecurringTransaction> _recurrings = [];
  final List<PlannedEvent> _plannedEvents = [];
  bool _onboarded = false;
  bool _overviewGuideShown = false;
  ThemeMode _themeMode = ThemeMode.system;
  AppCurrency _currency = AppCurrency.vnd;
  Locale? _locale;
  String? _selectedWalletId;
  bool _hideBalancesByDefault = true;
  String _dateFormat = 'dd/MM/yyyy';
  bool _canUndoCurrencyConversion = false;
  _GuideDemoSnapshot? _guideDemoSnapshot;

  bool get onboarded => _onboarded;

  bool get overviewGuideShown => _overviewGuideShown;

  ThemeMode get themeMode => _themeMode;

  bool get hideBalancesByDefault => _hideBalancesByDefault;

  String get dateFormat => _dateFormat;

  bool get canUndoCurrencyConversion => _canUndoCurrencyConversion;

  AppCurrency get currency => _currency;

  Locale? get locale => _locale;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _canUndoCurrencyConversion =
        _prefs.getString(_currencyConversionUndoKey) != null;
    _onboarded = _prefs.getBool(_onboardedKey) ?? false;
    _overviewGuideShown = _prefs.getBool(_overviewGuideShownKey) ?? false;
    _hideBalancesByDefault = _prefs.getBool(_hideBalancesKey) ?? true;
    _dateFormat = _prefs.getString(_dateFormatKey) ?? 'dd/MM/yyyy';
    _themeMode =
        ThemeMode.values.asNameMap()[_prefs.getString(_themeModeKey)] ??
        ThemeMode.system;
    _currency = AppCurrency.byCode(_prefs.getString(_currencyKey));
    AppCurrency.current = _currency;
    _selectedWalletId = _prefs.getString(_selectedWalletKey);
    final rawLocale = _prefs.getString(_localeKey);
    if (rawLocale != null && rawLocale.isNotEmpty) {
      _locale = Locale(rawLocale);
    }
    final rawRecurrings = _prefs.getString(_recurringsKey);
    if (rawRecurrings != null) {
      try {
        final recurrings = (jsonDecode(rawRecurrings) as List)
            .map(
              (e) => RecurringTransaction.fromJson(e as Map<String, dynamic>),
            )
            .toList();
        _recurrings
          ..clear()
          ..addAll(recurrings);
      } catch (_) {
        _recurrings.clear();
      }
    }
    final rawPlannedEvents = _prefs.getString(_plannedEventsKey);
    if (rawPlannedEvents != null) {
      try {
        _plannedEvents
          ..clear()
          ..addAll(
            (jsonDecode(rawPlannedEvents) as List).map(
              (e) => PlannedEvent.fromJson(e as Map<String, dynamic>),
            ),
          );
      } catch (_) {
        _plannedEvents.clear();
      }
    }
    final eventsMigrated = _detachEventsFromRecurringPayments();
    final rawCategories = _prefs.getString(_categoriesKey);
    final rawTransactions = _prefs.getString(_transactionsKey);
    final rawWallets = _prefs.getString(_walletsKey);
    final rawBudgets = _prefs.getString(_budgetsKey);
    final rawGoals = _prefs.getString(_goalsKey);
    final rawDebts = _prefs.getString(_debtsKey);
    if (rawCategories != null && rawTransactions != null) {
      try {
        bool missingCurrencyCode(String? raw) =>
            raw != null &&
            (jsonDecode(raw) as List).any(
              (item) => item is Map && !item.containsKey('currencyCode'),
            );
        final categories = (jsonDecode(rawCategories) as List)
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList();
        final transactions = (jsonDecode(rawTransactions) as List)
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
        final wallets = rawWallets == null
            ? <Wallet>[_cashWallet(_seedStrings())]
            : (jsonDecode(rawWallets) as List)
                  .map((e) => Wallet.fromJson(e as Map<String, dynamic>))
                  .toList();
        final budgets = rawBudgets == null
            ? <Budget>[]
            : (jsonDecode(rawBudgets) as List)
                  .map((e) => Budget.fromJson(e as Map<String, dynamic>))
                  .toList();
        final goals = rawGoals == null
            ? <Goal>[]
            : (jsonDecode(rawGoals) as List)
                  .map((e) => Goal.fromJson(e as Map<String, dynamic>))
                  .toList();
        final debts = rawDebts == null
            ? <Debt>[]
            : (jsonDecode(rawDebts) as List)
                  .map((e) => Debt.fromJson(e as Map<String, dynamic>))
                  .toList();
        _categories
          ..clear()
          ..addAll(categories);
        _transactions
          ..clear()
          ..addAll(transactions);
        _wallets
          ..clear()
          ..addAll(wallets);
        _budgets
          ..clear()
          ..addAll(budgets);
        _goals
          ..clear()
          ..addAll(goals);
        _debts
          ..clear()
          ..addAll(debts);
        final legacySeedsRemoved = await _removeLegacySampleData();
        if (legacySeedsRemoved ||
            rawWallets == null ||
            rawBudgets == null ||
            rawGoals == null ||
            rawDebts == null ||
            missingCurrencyCode(rawWallets) ||
            eventsMigrated ||
            missingCurrencyCode(rawBudgets) ||
            missingCurrencyCode(rawGoals) ||
            missingCurrencyCode(rawDebts)) {
          await _save();
        }
        return;
      } catch (_) {
        _categories.clear();
        _transactions.clear();
        _wallets.clear();
        _budgets.clear();
        _goals.clear();
        _debts.clear();
      }
    }
    _seed();
    await _prefs.setBool(_legacySeedCleanupKey, true);
    await _save();
  }

  Future<void> _save() async {
    if (_guideDemoSnapshot != null) return;
    final categories = jsonEncode(_categories.map((c) => c.toJson()).toList());
    final transactions = jsonEncode(
      _transactions.map((t) => t.toJson()).toList(),
    );
    final wallets = jsonEncode(_wallets.map((w) => w.toJson()).toList());
    final budgets = jsonEncode(_budgets.map((b) => b.toJson()).toList());
    final goals = jsonEncode(_goals.map((g) => g.toJson()).toList());
    final debts = jsonEncode(_debts.map((d) => d.toJson()).toList());
    final recurrings = jsonEncode(_recurrings.map((r) => r.toJson()).toList());
    final plannedEvents = jsonEncode(
      _plannedEvents.map((e) => e.toJson()).toList(),
    );
    _canUndoCurrencyConversion = false;
    await _prefs.remove(_currencyConversionUndoKey);
    await _prefs.setString(_categoriesKey, categories);
    await _prefs.setString(_transactionsKey, transactions);
    await _prefs.setString(_walletsKey, wallets);
    await _prefs.setString(_budgetsKey, budgets);
    await _prefs.setString(_goalsKey, goals);
    await _prefs.setString(_debtsKey, debts);
    await _prefs.setString(_recurringsKey, recurrings);
    await _prefs.setString(_plannedEventsKey, plannedEvents);
  }

  List<Category> categoriesOf(TxType type) =>
      _categories.where((c) => c.type == type).toList();

  Category? categoryById(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<Transaction> query(TxType type, DateRange range, {String? walletId}) {
    final list =
        _transactions
            .where(
              (t) =>
                  t.type == type &&
                  range.contains(t.date) &&
                  (walletId == null
                      ? walletById(t.walletId)?.currencyCode == _currency.code
                      : t.walletId == walletId),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  List<Wallet> get wallets => List.unmodifiable(_wallets);

  Wallet? walletById(String id) {
    for (final w in _wallets) {
      if (w.id == id) return w;
    }
    return null;
  }

  int transactionCountOfWallet(String walletId) =>
      _transactions.where((t) => t.walletId == walletId).length;

  int goalEntryCountOfWallet(String walletId) {
    var count = 0;
    for (final g in _goals) {
      count += g.entries.where((e) => e.walletId == walletId).length;
    }
    return count;
  }

  int debtEntryCountOfWallet(String walletId) {
    var count = 0;
    for (final d in _debts) {
      if (d.walletId == walletId) count++;
      count += d.payments.where((p) => p.walletId == walletId).length;
    }
    return count;
  }

  double walletBalance(String walletId) {
    var sum = walletById(walletId)?.initialBalance ?? 0;
    for (final t in _transactions) {
      if (t.walletId != walletId) continue;
      sum += t.type == TxType.income ? t.amount : -t.amount;
    }
    for (final g in _goals) {
      for (final e in g.entries) {
        if (e.walletId == walletId) sum -= e.amount;
      }
    }
    for (final d in _debts) {
      if (d.walletId == walletId) sum += d.principalFlow;
      for (final p in d.payments) {
        if (p.walletId == walletId) sum += d.paymentFlow(p);
      }
    }
    return sum;
  }

  double get balance => _wallets
      .where((w) => w.currencyCode == _currency.code)
      .fold<double>(0, (sum, w) => sum + walletBalance(w.id));

  String? get selectedWalletId {
    final id = _selectedWalletId;
    return id != null && walletById(id) != null ? id : null;
  }

  Wallet? get selectedWallet {
    final id = selectedWalletId;
    return id == null ? null : walletById(id);
  }

  double get selectedBalance {
    final id = selectedWalletId;
    return id == null ? balance : walletBalance(id);
  }

  void selectWallet(String? id) {
    _selectedWalletId = id;
    if (id != null && _guideDemoSnapshot == null) {
      setCurrency(AppCurrency.byCode(walletById(id)?.currencyCode));
    }
    if (_guideDemoSnapshot == null) {
      if (id == null) {
        _prefs.remove(_selectedWalletKey);
      } else {
        _prefs.setString(_selectedWalletKey, id);
      }
    }
    notifyListeners();
  }

  void addWallet(Wallet w) {
    _wallets.add(w);
    notifyListeners();
    _save();
  }

  void updateWallet(Wallet updated) {
    final index = _wallets.indexWhere((w) => w.id == updated.id);
    if (index == -1) return;
    _wallets[index] = updated;
    notifyListeners();
    _save();
  }

  void removeWallet(String id) {
    if (_wallets.length <= 1) return;
    final wallet = walletById(id);
    if (wallet == null ||
        _wallets.where((w) => w.currencyCode == wallet.currencyCode).length <=
            1) {
      return;
    }
    _wallets.removeWhere((w) => w.id == id);
    _transactions.removeWhere((t) => t.walletId == id);
    _recurrings.removeWhere((r) => r.walletId == id);
    _plannedEvents.removeWhere((event) => event.walletId == id);
    for (var i = 0; i < _goals.length; i++) {
      final g = _goals[i];
      if (g.entries.any((e) => e.walletId == id)) {
        _goals[i] = g.copyWith(
          entries: [
            for (final e in g.entries) e.walletId == id ? e.withoutWallet() : e,
          ],
        );
      }
    }
    for (var i = 0; i < _debts.length; i++) {
      final d = _debts[i];
      if (d.walletId == id || d.payments.any((p) => p.walletId == id)) {
        _debts[i] = d.copyWith(
          clearWallet: d.walletId == id,
          payments: [
            for (final p in d.payments)
              p.walletId == id ? p.withoutWallet() : p,
          ],
        );
      }
    }
    notifyListeners();
    _save();
  }

  void addTransaction(Transaction t) {
    _transactions.add(t);
    notifyListeners();
    _save();
  }

  bool hasPlannedEventTransaction(PlannedEvent event, DateTime date) {
    final key =
        '${event.id}_${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    return _transactions.any((transaction) {
      if (transaction.id == 'event_$key') return true;
      final transactionDate = transaction.date;
      final sameDate =
          transactionDate.year == date.year &&
          transactionDate.month == date.month &&
          transactionDate.day == date.day;
      final sameEvent =
          transaction.id.startsWith('rec_') &&
          transaction.type == event.type &&
          transaction.amount == event.amount &&
          (event.walletId == null || transaction.walletId == event.walletId) &&
          (transaction.note == event.title ||
              transaction.note.startsWith('${event.title}\n'));
      return sameDate && sameEvent;
    });
  }

  bool recordPlannedEventTransaction({
    required PlannedEvent event,
    required DateTime date,
    required String categoryId,
    required String walletId,
    double? amount,
  }) {
    final category = categoryById(categoryId);
    final wallet = walletById(walletId);
    final actualAmount = amount ?? event.amount;
    if (category?.type != event.type ||
        wallet == null ||
        wallet.currencyCode != event.currencyCode ||
        actualAmount <= 0 ||
        hasPlannedEventTransaction(event, date)) {
      return false;
    }
    final key =
        '${event.id}_${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final note = event.note.isEmpty
        ? event.title
        : '${event.title}\n${event.note}';
    _transactions.add(
      Transaction(
        id: 'event_$key',
        type: event.type,
        categoryId: categoryId,
        walletId: walletId,
        amount: actualAmount,
        date: DateTime(date.year, date.month, date.day, 12),
        note: note,
      ),
    );
    final recurringId = event.recurringId;
    if (recurringId != null) {
      final index = _recurrings.indexWhere((item) => item.id == recurringId);
      if (index != -1) {
        final recurring = _recurrings[index];
        final occurrence = RecurringTransaction.dateOnly(date);
        if (!recurring.isSkipped(occurrence)) {
          _recurrings[index] = recurring.copyWith(
            skippedDates: [...recurring.skippedDates, occurrence],
          );
        }
      }
    }
    notifyListeners();
    _save();
    return true;
  }

  void updateTransaction(Transaction updated) {
    final index = _transactions.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;
    _transactions[index] = updated;
    notifyListeners();
    _save();
  }

  List<Transaction> plannedEventTransactions(
    String eventId, {
    DateTime? occurrenceDate,
  }) {
    final eventIndex = _plannedEvents.indexWhere(
      (event) => event.id == eventId,
    );
    if (eventIndex == -1) return const [];
    final event = _plannedEvents[eventIndex];
    return _transactions.where((transaction) {
      final sameDate =
          occurrenceDate == null ||
          (transaction.date.year == occurrenceDate.year &&
              transaction.date.month == occurrenceDate.month &&
              transaction.date.day == occurrenceDate.day);
      if (!sameDate) return false;
      if (transaction.id.startsWith('event_${event.id}_')) return true;
      return transaction.id.startsWith('rec_') &&
          event.frequency != null &&
          event.walletId != null &&
          transaction.type == event.type &&
          transaction.amount == event.amount &&
          transaction.walletId == event.walletId &&
          transaction.note == event.title &&
          _isPlannedEventOccurrence(event, transaction.date);
    }).toList();
  }

  bool _isPlannedEventOccurrence(PlannedEvent event, DateTime date) {
    final frequency = event.frequency;
    if (frequency == null) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }
    var occurrence = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
    );
    final target = DateTime(date.year, date.month, date.day);
    var guard = 0;
    while (occurrence.isBefore(target) && guard < 100000) {
      occurrence = _advanceEventDate(occurrence, event.date, frequency);
      guard++;
    }
    return occurrence.year == target.year &&
        occurrence.month == target.month &&
        occurrence.day == target.day;
  }

  void removePlannedEventTransactions(
    String eventId, {
    DateTime? occurrenceDate,
  }) {
    final ids = plannedEventTransactions(
      eventId,
      occurrenceDate: occurrenceDate,
    ).map((transaction) => transaction.id).toSet();
    if (ids.isEmpty) return;
    _transactions.removeWhere((transaction) => ids.contains(transaction.id));
    notifyListeners();
    _save();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    _save();
  }

  List<PlannedEvent> get plannedEvents => List.unmodifiable(
    _plannedEvents.where((event) {
      if (event.currencyCode != _currency.code) return false;
      final selected = selectedWalletId;
      return selected == null ||
          event.walletId == null ||
          event.walletId == selected;
    }),
  );

  List<PlannedEvent> get allPlannedEvents => List.unmodifiable(_plannedEvents);

  bool _detachEventsFromRecurringPayments() {
    final linkedIds = <String>{};
    var changed = false;
    for (var i = 0; i < _plannedEvents.length; i++) {
      final event = _plannedEvents[i];
      final recurringId = event.recurringId;
      if (recurringId == null) continue;
      final recurring = recurringById(recurringId);
      _plannedEvents[i] = event.copyWith(
        clearRecurringId: true,
        frequency: event.frequency ?? recurring?.frequency,
        skippedDates: event.skippedDates.isEmpty
            ? recurring?.skippedDates ?? const []
            : event.skippedDates,
      );
      linkedIds.add(recurringId);
      changed = true;
    }
    if (linkedIds.isNotEmpty) {
      _recurrings.removeWhere((recurring) => linkedIds.contains(recurring.id));
    }
    return changed;
  }

  List<PlannedEvent> plannedEventsInRange(
    DateRange range, {
    bool includeAllWallets = false,
  }) {
    final result = <PlannedEvent>[];
    final source = includeAllWallets
        ? _plannedEvents.where((event) => event.currencyCode == _currency.code)
        : plannedEvents;
    for (final event in source) {
      final frequency = event.frequency;
      if (frequency == null) {
        if (range.contains(event.date)) result.add(event);
        continue;
      }
      var date = event.date;
      var guard = 0;
      while (date.isBefore(range.start) && guard < 100000) {
        date = _advanceEventDate(date, event.date, frequency);
        guard++;
      }
      while (date.isBefore(range.end) && guard < 100000) {
        if (!event.skippedDates.any(
          (skipped) =>
              skipped.year == date.year &&
              skipped.month == date.month &&
              skipped.day == date.day,
        )) {
          result.add(event.copyWith(date: date, seriesStartDate: event.date));
        }
        date = _advanceEventDate(date, event.date, frequency);
        guard++;
      }
    }
    return result;
  }

  DateTime _advanceEventDate(
    DateTime from,
    DateTime start,
    Frequency frequency,
  ) {
    switch (frequency) {
      case Frequency.daily:
        return DateTime(from.year, from.month, from.day + 1);
      case Frequency.weekly:
        return DateTime(from.year, from.month, from.day + 7);
      case Frequency.monthly:
        return _advanceEventMonth(from, start, 1);
      case Frequency.yearly:
        return _advanceEventMonth(from, start, 12);
    }
  }

  DateTime _advanceEventMonth(DateTime from, DateTime start, int months) {
    final total = from.month - 1 + months;
    final year = from.year + total ~/ 12;
    final month = total % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = start.day < lastDay ? start.day : lastDay;
    return DateTime(year, month, day);
  }

  void skipPlannedEventOccurrence(String eventId, DateTime date) {
    final index = _plannedEvents.indexWhere((event) => event.id == eventId);
    if (index == -1) return;
    final event = _plannedEvents[index];
    final skipped = DateTime(date.year, date.month, date.day);
    if (event.skippedDates.any(
      (item) =>
          item.year == skipped.year &&
          item.month == skipped.month &&
          item.day == skipped.day,
    )) {
      return;
    }
    _plannedEvents[index] = event.copyWith(
      skippedDates: [...event.skippedDates, skipped],
    );
    notifyListeners();
    _save();
  }

  void skipRecurringOccurrence(String recurringId, DateTime date) {
    final recurring = recurringById(recurringId);
    if (recurring == null || recurring.isSkipped(date)) return;
    final skipped = [
      ...recurring.skippedDates,
      RecurringTransaction.dateOnly(date),
    ];
    updateRecurring(recurring.copyWith(skippedDates: skipped));
  }

  void addPlannedEvent(PlannedEvent event) {
    _plannedEvents.add(event);
    notifyListeners();
    _save();
  }

  void updatePlannedEvent(PlannedEvent updated) {
    final index = _plannedEvents.indexWhere((event) => event.id == updated.id);
    if (index == -1) return;
    _plannedEvents[index] = updated;
    notifyListeners();
    _save();
  }

  void removePlannedEvent(String id) {
    _plannedEvents.removeWhere((event) => event.id == id);
    notifyListeners();
    _save();
  }

  void addCategory(Category c) {
    _categories.add(c);
    notifyListeners();
    _save();
  }

  int transactionCountOf(String categoryId) =>
      _transactions.where((t) => t.categoryId == categoryId).length;

  void updateCategory(Category updated) {
    final index = _categories.indexWhere((c) => c.id == updated.id);
    if (index == -1) return;
    _categories[index] = updated;
    notifyListeners();
    _save();
  }

  void removeCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    _transactions.removeWhere((t) => t.categoryId == id);
    _budgets.removeWhere((b) => b.categoryId == id);
    final recurringIds = _recurrings
        .where((r) => r.categoryId == id)
        .map((r) => r.id)
        .toSet();
    _recurrings.removeWhere((r) => recurringIds.contains(r.id));
    _plannedEvents.removeWhere(
      (event) => recurringIds.contains(event.recurringId),
    );
    notifyListeners();
    _save();
  }

  List<Budget> get budgets => List.unmodifiable(
    _budgets.where((b) => b.currencyCode == _currency.code),
  );

  List<Budget> get allBudgets => List.unmodifiable(_budgets);

  Budget? budgetOfCategory(String categoryId) {
    for (final b in _budgets) {
      if (b.categoryId == categoryId && b.currencyCode == _currency.code) {
        return b;
      }
    }
    return null;
  }

  double spentOfCategory(
    String categoryId,
    DateRange range, {
    String? currencyCode,
  }) {
    final code = currencyCode ?? _currency.code;
    var sum = 0.0;
    for (final t in _transactions) {
      if (t.type != TxType.expense ||
          t.categoryId != categoryId ||
          walletById(t.walletId)?.currencyCode != code) {
        continue;
      }
      if (range.contains(t.date)) sum += t.amount;
    }
    return sum;
  }

  double expenseTotal(DateRange range, {String? currencyCode}) {
    final code = currencyCode ?? _currency.code;
    var sum = 0.0;
    for (final t in _transactions) {
      if (t.type == TxType.expense &&
          range.contains(t.date) &&
          walletById(t.walletId)?.currencyCode == code) {
        sum += t.amount;
      }
    }
    return sum;
  }

  void addBudget(Budget b) {
    _budgets.add(b);
    notifyListeners();
    _save();
  }

  void updateBudget(Budget updated) {
    final index = _budgets.indexWhere((b) => b.id == updated.id);
    if (index == -1) return;
    _budgets[index] = updated;
    notifyListeners();
    _save();
  }

  void removeBudget(String id) {
    _budgets.removeWhere((b) => b.id == id);
    notifyListeners();
    _save();
  }

  List<Goal> get goals =>
      List.unmodifiable(_goals.where((g) => g.currencyCode == _currency.code));

  List<Goal> get allGoals => List.unmodifiable(_goals);

  Goal? goalById(String id) {
    for (final g in _goals) {
      if (g.id == id) return g;
    }
    return null;
  }

  void addGoal(Goal g) {
    _goals.add(g);
    notifyListeners();
    _save();
  }

  void updateGoal(Goal updated) {
    final index = _goals.indexWhere((g) => g.id == updated.id);
    if (index == -1) return;
    _goals[index] = updated;
    notifyListeners();
    _save();
  }

  void removeGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
    _save();
  }

  void addGoalEntry(String goalId, GoalEntry entry) {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index == -1) return;
    final goal = _goals[index];
    _goals[index] = goal.copyWith(entries: [...goal.entries, entry]);
    notifyListeners();
    _save();
  }

  void removeGoalEntry(String goalId, String entryId) {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index == -1) return;
    final goal = _goals[index];
    _goals[index] = goal.copyWith(
      entries: goal.entries.where((e) => e.id != entryId).toList(),
    );
    notifyListeners();
    _save();
  }

  List<Debt> get debts =>
      List.unmodifiable(_debts.where((d) => d.currencyCode == _currency.code));

  List<Debt> get allDebts => List.unmodifiable(_debts);

  Debt? debtById(String id) {
    for (final d in _debts) {
      if (d.id == id) return d;
    }
    return null;
  }

  void addDebt(Debt d) {
    _debts.add(d);
    notifyListeners();
    _save();
  }

  void updateDebt(Debt updated) {
    final index = _debts.indexWhere((d) => d.id == updated.id);
    if (index == -1) return;
    _debts[index] = updated;
    notifyListeners();
    _save();
  }

  void removeDebt(String id) {
    _debts.removeWhere((d) => d.id == id);
    notifyListeners();
    _save();
  }

  void addDebtPayment(String debtId, DebtPayment payment) {
    final index = _debts.indexWhere((d) => d.id == debtId);
    if (index == -1) return;
    final debt = _debts[index];
    _debts[index] = debt.copyWith(payments: [...debt.payments, payment]);
    notifyListeners();
    _save();
  }

  void removeDebtPayment(String debtId, String paymentId) {
    final index = _debts.indexWhere((d) => d.id == debtId);
    if (index == -1) return;
    final debt = _debts[index];
    _debts[index] = debt.copyWith(
      payments: debt.payments.where((p) => p.id != paymentId).toList(),
    );
    notifyListeners();
    _save();
  }

  List<RecurringTransaction> get recurrings => List.unmodifiable(
    _recurrings.where(
      (r) => walletById(r.walletId)?.currencyCode == _currency.code,
    ),
  );

  List<RecurringTransaction> get allRecurrings =>
      List.unmodifiable(_recurrings);

  RecurringTransaction? recurringById(String id) {
    for (final r in _recurrings) {
      if (r.id == id) return r;
    }
    return null;
  }

  int addRecurring(RecurringTransaction r) {
    _recurrings.add(r);
    notifyListeners();
    _save();
    return processRecurring();
  }

  int updateRecurring(RecurringTransaction updated) {
    final index = _recurrings.indexWhere((r) => r.id == updated.id);
    if (index == -1) return 0;
    _recurrings[index] = updated;
    notifyListeners();
    _save();
    return processRecurring();
  }

  void removeRecurring(String id, {bool preservePlannedEvent = false}) {
    _recurrings.removeWhere((r) => r.id == id);
    if (preservePlannedEvent) {
      for (var i = 0; i < _plannedEvents.length; i++) {
        final event = _plannedEvents[i];
        if (event.recurringId != id) continue;
        _plannedEvents[i] = PlannedEvent(
          id: event.id,
          title: event.title,
          type: event.type,
          amount: event.amount,
          date: event.date,
          currencyCode: event.currencyCode,
          note: event.note,
          walletId: event.walletId,
          reminderMinutes: event.reminderMinutes,
        );
      }
    } else {
      _plannedEvents.removeWhere((event) => event.recurringId == id);
    }
    notifyListeners();
    _save();
  }

  int toggleRecurring(String id) {
    final index = _recurrings.indexWhere((r) => r.id == id);
    if (index == -1) return 0;
    final r = _recurrings[index];
    if (r.active) {
      _recurrings[index] = r.copyWith(active: false);
    } else {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      var next = r.nextDate;
      var guard = 0;
      while (next.isBefore(today) && guard < 4000) {
        next = r.advance(next);
        guard++;
      }
      _recurrings[index] = r.copyWith(active: true, nextDate: next);
    }
    notifyListeners();
    _save();
    return processRecurring();
  }

  int processRecurring([DateTime? now]) {
    if (_guideDemoSnapshot != null) return 0;
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    var created = 0;
    var changed = false;
    for (var i = 0; i < _recurrings.length; i++) {
      var r = _recurrings[i];
      var steps = 0;
      while (r.isDue(today) && steps < 400) {
        final d = r.nextDate;
        if (!r.isSkipped(d)) {
          _transactions.add(
            Transaction(
              id: 'rec_${r.id}_${d.millisecondsSinceEpoch}',
              type: r.type,
              categoryId: r.categoryId,
              walletId: r.walletId,
              amount: r.amount,
              date: DateTime(d.year, d.month, d.day, 12),
              note: r.note,
            ),
          );
        }
        r = r.copyWith(nextDate: r.advance(d));
        steps++;
      }
      if (steps > 0) {
        _recurrings[i] = r;
        created += steps;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      _save();
    }
    return created;
  }

  void setHideBalancesByDefault(bool value) {
    _hideBalancesByDefault = value;
    _prefs.setBool(_hideBalancesKey, value);
    notifyListeners();
  }

  void setDateFormat(String value) {
    _dateFormat = value;
    _prefs.setString(_dateFormatKey, value);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setString(_themeModeKey, mode.name);
    notifyListeners();
  }

  void setLocale(Locale? locale) {
    _locale = locale;
    if (locale == null) {
      _prefs.remove(_localeKey);
    } else {
      _prefs.setString(_localeKey, locale.languageCode);
    }
    notifyListeners();
  }

  void setCurrency(AppCurrency currency) {
    _canUndoCurrencyConversion = false;
    _prefs.remove(_currencyConversionUndoKey);
    _currency = currency;
    AppCurrency.current = currency;
    _prefs.setString(_currencyKey, currency.code);
    notifyListeners();
  }

  Future<void> convertCurrency(
    AppCurrency from,
    AppCurrency to,
    double factor, {
    required Set<String> walletIds,
  }) async {
    final backupBeforeConversion = createBackup().encode();
    final fromCode = from.code;
    final sourceWalletIds = walletIds
        .where((id) => walletById(id)?.currencyCode == fromCode)
        .toSet();
    var expanded = true;
    while (expanded) {
      expanded = false;
      for (final goal in _goals) {
        if (goal.currencyCode != fromCode ||
            !goal.entries.any(
              (entry) => sourceWalletIds.contains(entry.walletId),
            )) {
          continue;
        }
        for (final entry in goal.entries) {
          final id = entry.walletId;
          if (id != null &&
              walletById(id)?.currencyCode == fromCode &&
              sourceWalletIds.add(id)) {
            expanded = true;
          }
        }
      }
      for (final debt in _debts) {
        final linked =
            sourceWalletIds.contains(debt.walletId) ||
            debt.payments.any(
              (payment) => sourceWalletIds.contains(payment.walletId),
            );
        if (debt.currencyCode != fromCode || !linked) continue;
        final linkedIds = <String?>[
          debt.walletId,
          ...debt.payments.map((payment) => payment.walletId),
        ];
        for (final id in linkedIds) {
          if (id != null &&
              walletById(id)?.currencyCode == fromCode &&
              sourceWalletIds.add(id)) {
            expanded = true;
          }
        }
      }
    }
    final scale = to.scale;
    double conv(double value) {
      final minor = (value * factor * scale).round();
      if (minor == 0 && value != 0) return value.sign / scale;
      return minor / scale;
    }

    for (var i = 0; i < _transactions.length; i++) {
      final t = _transactions[i];
      if (!sourceWalletIds.contains(t.walletId)) continue;
      _transactions[i] = Transaction(
        id: t.id,
        type: t.type,
        categoryId: t.categoryId,
        walletId: t.walletId,
        amount: conv(t.amount),
        date: t.date,
        note: t.note,
      );
    }
    for (var i = 0; i < _wallets.length; i++) {
      final w = _wallets[i];
      if (!sourceWalletIds.contains(w.id)) continue;
      _wallets[i] = Wallet(
        id: w.id,
        name: w.name,
        icon: w.icon,
        color: w.color,
        initialBalance: conv(w.initialBalance),
        currencyCode: to.code,
      );
    }
    for (var i = 0; i < _goals.length; i++) {
      final g = _goals[i];
      if (g.currencyCode != fromCode ||
          !g.entries.any((entry) => sourceWalletIds.contains(entry.walletId))) {
        continue;
      }
      _goals[i] = g.copyWith(
        target: conv(g.target),
        currencyCode: to.code,
        entries: [
          for (final e in g.entries)
            GoalEntry(
              id: e.id,
              amount: conv(e.amount),
              date: e.date,
              note: e.note,
              walletId: e.walletId,
            ),
        ],
      );
    }
    for (var i = 0; i < _debts.length; i++) {
      final d = _debts[i];
      if (d.currencyCode != fromCode ||
          (!sourceWalletIds.contains(d.walletId) &&
              !d.payments.any(
                (payment) => sourceWalletIds.contains(payment.walletId),
              ))) {
        continue;
      }
      _debts[i] = d.copyWith(
        amount: conv(d.amount),
        currencyCode: to.code,
        payments: [
          for (final p in d.payments)
            DebtPayment(
              id: p.id,
              amount: conv(p.amount),
              date: p.date,
              note: p.note,
              walletId: p.walletId,
            ),
        ],
      );
    }
    for (var i = 0; i < _recurrings.length; i++) {
      final r = _recurrings[i];
      if (!sourceWalletIds.contains(r.walletId)) continue;
      _recurrings[i] = r.copyWith(amount: conv(r.amount));
    }
    for (var i = 0; i < _plannedEvents.length; i++) {
      final event = _plannedEvents[i];
      if (!sourceWalletIds.contains(event.walletId)) continue;
      _plannedEvents[i] = event.copyWith(
        amount: conv(event.amount),
        currencyCode: to.code,
      );
    }
    _currency = to;
    AppCurrency.current = to;
    _prefs.setString(_currencyKey, to.code);
    notifyListeners();
    await _save();
    await _prefs.setString(_currencyConversionUndoKey, backupBeforeConversion);
    _canUndoCurrencyConversion = true;
    notifyListeners();
  }

  Future<bool> undoLastCurrencyConversion() async {
    final raw = _prefs.getString(_currencyConversionUndoKey);
    if (raw == null) return false;
    _canUndoCurrencyConversion = false;
    try {
      await restoreBackup(BackupData.parse(raw));
      return true;
    } catch (_) {
      await _prefs.remove(_currencyConversionUndoKey);
      notifyListeners();
      return false;
    }
  }

  BackupData createBackup() {
    return BackupData(
      categories: List.of(_categories),
      transactions: List.of(_transactions),
      wallets: List.of(_wallets),
      budgets: List.of(_budgets),
      goals: List.of(_goals),
      debts: List.of(_debts),
      recurrings: List.of(_recurrings),
      plannedEvents: List.of(_plannedEvents),
      currency: _currency.code,
    );
  }

  Future<void> restoreBackup(BackupData data) async {
    _categories
      ..clear()
      ..addAll(data.categories);
    _transactions
      ..clear()
      ..addAll(data.transactions);
    _wallets
      ..clear()
      ..addAll(data.wallets);
    _budgets
      ..clear()
      ..addAll(data.budgets);
    _goals
      ..clear()
      ..addAll(data.goals);
    _debts
      ..clear()
      ..addAll(data.debts);
    _recurrings
      ..clear()
      ..addAll(data.recurrings);
    _plannedEvents
      ..clear()
      ..addAll(data.plannedEvents);
    if (data.currency != null) {
      _currency = AppCurrency.byCode(data.currency);
      AppCurrency.current = _currency;
      _prefs.setString(_currencyKey, _currency.code);
    }
    notifyListeners();
    await _save();
  }

  void completeOnboarding(Wallet wallet) {
    _wallets.add(wallet);
    _onboarded = true;
    _prefs.setBool(_onboardedKey, true);
    notifyListeners();
    _save();
  }

  void beginOverviewGuideDemo() {
    if (_guideDemoSnapshot != null) return;
    _guideDemoSnapshot = _GuideDemoSnapshot(
      categories: _categories,
      transactions: _transactions,
      wallets: _wallets,
      budgets: _budgets,
      goals: _goals,
      debts: _debts,
      recurrings: _recurrings,
      plannedEvents: _plannedEvents,
      selectedWalletId: _selectedWalletId,
    );
    _categories.clear();
    _transactions.clear();
    _wallets.clear();
    _budgets.clear();
    _goals.clear();
    _debts.clear();
    _recurrings.clear();
    _plannedEvents.clear();
    _seed(includeExamples: true);
    _selectedWalletId = guideCashWalletId;
    notifyListeners();
  }

  void endOverviewGuideDemo() {
    final snapshot = _guideDemoSnapshot;
    if (snapshot == null) return;
    _categories
      ..clear()
      ..addAll(snapshot.categories);
    _transactions
      ..clear()
      ..addAll(snapshot.transactions);
    _wallets
      ..clear()
      ..addAll(snapshot.wallets);
    _budgets
      ..clear()
      ..addAll(snapshot.budgets);
    _goals
      ..clear()
      ..addAll(snapshot.goals);
    _debts
      ..clear()
      ..addAll(snapshot.debts);
    _recurrings
      ..clear()
      ..addAll(snapshot.recurrings);
    _plannedEvents
      ..clear()
      ..addAll(snapshot.plannedEvents);
    _selectedWalletId = snapshot.selectedWalletId;
    _guideDemoSnapshot = null;
    notifyListeners();
  }

  Future<bool> _removeLegacySampleData() async {
    if (_prefs.getBool(_legacySeedCleanupKey) ?? false) return false;
    final vi = lookupAppLocalizations(const Locale('vi'));
    final en = lookupAppLocalizations(const Locale('en'));
    const transactionCategories = <String, String>{
      '1': 'expense|food',
      '2': 'expense|transport',
      '3': 'expense|grocery',
      '4': 'expense|shop',
      '5': 'expense|food',
      '6': 'expense|bill',
      '7': 'expense|home',
      '8': 'expense|health',
      '9': 'expense|food',
      '10': 'income|salary',
      '11': 'income|bonus',
      '12': 'income|invest',
    };
    final transactionNotes = <String, Set<String>>{
      '1': {vi.seedNoteLunch, en.seedNoteLunch},
      '2': {vi.seedNoteRide, en.seedNoteRide},
      '3': {vi.seedNoteVegetables, en.seedNoteVegetables},
      '4': {vi.seedNoteTshirt, en.seedNoteTshirt},
      '5': {vi.seedNoteCoffee, en.seedNoteCoffee},
      '6': {vi.seedNoteElectricity, en.seedNoteElectricity},
      '7': {vi.seedNoteRent, en.seedNoteRent},
      '8': {vi.seedNoteMedicine, en.seedNoteMedicine},
      '9': {''},
      '10': {vi.seedNoteSalary, en.seedNoteSalary},
      '11': {vi.seedNoteProjectBonus, en.seedNoteProjectBonus},
      '12': {vi.seedNoteInterest, en.seedNoteInterest},
    };
    final transactionCount = _transactions.length;
    _transactions.removeWhere((transaction) {
      final category = transactionCategories[transaction.id];
      final notes = transactionNotes[transaction.id];
      return category == '${transaction.type.name}|${transaction.categoryId}' &&
          notes?.contains(transaction.note) == true;
    });
    final budgetCount = _budgets.length;
    _budgets.removeWhere(
      (budget) =>
          (budget.id == 'b_food' && budget.categoryId == 'food') ||
          (budget.id == 'b_shop' && budget.categoryId == 'shop') ||
          (budget.id == 'b_transport' && budget.categoryId == 'transport'),
    );
    final goalCount = _goals.length;
    final oldGoalNames = {vi.seedGoalTrip, en.seedGoalTrip};
    _goals.removeWhere(
      (goal) => goal.id == 'g_trip' && oldGoalNames.contains(goal.name),
    );
    final debtCount = _debts.length;
    final oldLenders = {vi.seedPersonMinh, en.seedPersonMinh};
    final oldBorrowers = {vi.seedPersonLan, en.seedPersonLan};
    _debts.removeWhere(
      (debt) =>
          (debt.id == 'd_minh' &&
              debt.type == DebtType.lend &&
              oldLenders.contains(debt.person)) ||
          (debt.id == 'd_lan' &&
              debt.type == DebtType.borrow &&
              oldBorrowers.contains(debt.person)),
    );
    final referencedWalletIds = <String>{
      ..._transactions.map((transaction) => transaction.walletId),
      ..._recurrings.map((recurring) => recurring.walletId),
      ..._plannedEvents.map((event) => event.walletId).whereType<String>(),
    };
    for (final goal in _goals) {
      referencedWalletIds.addAll(
        goal.entries.map((entry) => entry.walletId).whereType<String>(),
      );
    }
    for (final debt in _debts) {
      if (debt.walletId != null) referencedWalletIds.add(debt.walletId!);
      referencedWalletIds.addAll(
        debt.payments.map((payment) => payment.walletId).whereType<String>(),
      );
    }
    final walletCount = _wallets.length;
    final oldCashNames = {vi.cashWallet, en.cashWallet};
    final oldBankNames = {vi.bankWallet, en.bankWallet};
    _wallets.removeWhere(
      (wallet) =>
          ((wallet.id == 'cash' && oldCashNames.contains(wallet.name)) ||
              (wallet.id == 'bank' && oldBankNames.contains(wallet.name))) &&
          wallet.initialBalance == 0 &&
          !referencedWalletIds.contains(wallet.id),
    );
    if (_selectedWalletId != null &&
        !_wallets.any((wallet) => wallet.id == _selectedWalletId)) {
      _selectedWalletId = null;
      await _prefs.remove(_selectedWalletKey);
    }
    await _prefs.setBool(_legacySeedCleanupKey, true);
    return transactionCount != _transactions.length ||
        budgetCount != _budgets.length ||
        goalCount != _goals.length ||
        debtCount != _debts.length ||
        walletCount != _wallets.length;
  }

  void markOverviewGuideShown() {
    _overviewGuideShown = true;
    _prefs.setBool(_overviewGuideShownKey, true);
  }

  String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  AppLocalizations _seedStrings() {
    final preferred = _locale ?? PlatformDispatcher.instance.locale;
    final supported = AppLocalizations.supportedLocales.any(
      (e) => e.languageCode == preferred.languageCode,
    );
    return lookupAppLocalizations(
      supported ? Locale(preferred.languageCode) : const Locale('en'),
    );
  }

  Wallet _cashWallet(AppLocalizations l) => Wallet(
    id: 'cash',
    name: l.cashWallet,
    icon: AppIcons.payments,
    color: const Color(0xFF2A8C66),
    currencyCode: _currency.code,
  );

  void _seed({bool includeExamples = false}) {
    final l = _seedStrings();
    const e = TxType.expense;
    const i = TxType.income;
    _categories.addAll([
      Category(
        id: 'food',
        name: l.catFood,
        icon: AppIcons.restaurant,
        color: const Color(0xFFF5B82E),
        type: e,
      ),
      Category(
        id: 'grocery',
        name: l.catGrocery,
        icon: AppIcons.shoppingBasket,
        color: const Color(0xFF4C9BE8),
        type: e,
      ),
      Category(
        id: 'shop',
        name: l.catShop,
        icon: AppIcons.shoppingCart,
        color: const Color(0xFF9B5DE5),
        type: e,
      ),
      Category(
        id: 'home',
        name: l.catHome,
        icon: AppIcons.home,
        color: const Color(0xFFE8506E),
        type: e,
      ),
      Category(
        id: 'transport',
        name: l.catTransport,
        icon: AppIcons.bus,
        color: const Color(0xFF3CC6B0),
        type: e,
      ),
      Category(
        id: 'health',
        name: l.catHealth,
        icon: AppIcons.favorite,
        color: const Color(0xFFEF6C57),
        type: e,
      ),
      Category(
        id: 'bill',
        name: l.catBill,
        icon: AppIcons.bolt,
        color: const Color(0xFF6BB94A),
        type: e,
      ),
      Category(
        id: 'other_e',
        name: l.other,
        icon: AppIcons.help,
        color: const Color(0xFF8E9A93),
        type: e,
      ),
      Category(
        id: 'salary',
        name: l.catSalary,
        icon: AppIcons.wallet,
        color: const Color(0xFF2A8C66),
        type: i,
      ),
      Category(
        id: 'bonus',
        name: l.catBonus,
        icon: AppIcons.gift,
        color: const Color(0xFFF5B82E),
        type: i,
      ),
      Category(
        id: 'invest',
        name: l.catInvest,
        icon: AppIcons.trendingUp,
        color: const Color(0xFF4C9BE8),
        type: i,
      ),
      Category(
        id: 'other_i',
        name: l.catOtherIncome,
        icon: AppIcons.help,
        color: const Color(0xFF8E9A93),
        type: i,
      ),
    ]);

    if (!includeExamples) return;

    double scaleAmount(double value) {
      final factor = switch (_currency.code) {
        'USD' => 1 / 25000,
        'EUR' => 1 / 28000,
        'GBP' => 1 / 32000,
        'JPY' => 1 / 170,
        'CNY' => 1 / 3500,
        'KRW' => 1 / 18,
        'THB' => 1 / 700,
        'SGD' => 1 / 19000,
        'AUD' => 1 / 16000,
        'CAD' => 1 / 18000,
        'CHF' => 1 / 30000,
        'INR' => 1 / 300,
        'HKD' => 1 / 3200,
        'MYR' => 1 / 5500,
        'IDR' => 1.3,
        'PHP' => 1 / 450,
        'TWD' => 1 / 800,
        _ => 1.0,
      };
      final scale = _currency.scale;
      return (value * factor * scale).round() / scale;
    }

    _wallets.addAll([
      Wallet(
        id: 'guide_cash',
        name: l.overviewGuideSampleWallet,
        icon: AppIcons.payments,
        color: const Color(0xFF2A8C66),
        initialBalance: scaleAmount(3755000),
        currencyCode: _currency.code,
      ),
      Wallet(
        id: 'guide_bank',
        name: l.bankWallet,
        icon: AppIcons.bank,
        color: const Color(0xFF4C9BE8),
        initialBalance: scaleAmount(3000000),
        currencyCode: _currency.code,
      ),
    ]);

    _budgets.addAll([
      Budget(
        id: 'guide_budget_food',
        categoryId: 'food',
        limit: scaleAmount(2000000),
        currencyCode: _currency.code,
      ),
      Budget(
        id: 'guide_budget_shop',
        categoryId: 'shop',
        limit: scaleAmount(1000000),
        currencyCode: _currency.code,
      ),
      Budget(
        id: 'guide_budget_transport',
        categoryId: 'transport',
        limit: scaleAmount(500000),
        currencyCode: _currency.code,
      ),
    ]);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Transaction tx(
      String id,
      TxType type,
      String categoryId,
      double amount,
      int daysAgo, [
      String note = '',
      String walletId = guideCashWalletId,
    ]) => Transaction(
      id: id,
      type: type,
      categoryId: categoryId,
      walletId: walletId,
      amount: scaleAmount(amount),
      date: today
          .subtract(Duration(days: daysAgo))
          .add(const Duration(hours: 12)),
      note: note,
    );

    _transactions.addAll([
      tx('guide_tx_01', e, 'food', 85000, 0, l.seedNoteLunch),
      tx('guide_tx_02', e, 'transport', 30000, 0, l.seedNoteRide),
      tx('guide_tx_03', e, 'food', 55000, 0, l.seedNoteCoffee),
      tx('guide_tx_04', i, 'bonus', 300000, 0, l.seedNoteProjectBonus),
      tx('guide_tx_05', e, 'grocery', 220000, 1, l.seedNoteVegetables),
      tx('guide_tx_06', e, 'food', 65000, 1, l.seedNoteCoffee),
      tx('guide_tx_07', e, 'shop', 450000, 2, l.seedNoteTshirt),
      tx('guide_tx_08', e, 'food', 120000, 3, l.seedNoteLunch),
      tx('guide_tx_09', e, 'transport', 45000, 3, l.seedNoteRide),
      tx('guide_tx_10', e, 'bill', 650000, 5, l.seedNoteElectricity),
      tx('guide_tx_11', i, 'salary', 4500000, 4, l.seedNoteSalary),
      tx('guide_tx_12', e, 'home', 3000000, 8, l.seedNoteRent),
      tx('guide_tx_13', e, 'health', 180000, 12, l.seedNoteMedicine),
      tx('guide_tx_14', i, 'bonus', 1000000, 10, l.seedNoteProjectBonus),
      tx('guide_tx_15', e, 'food', 95000, 15, l.seedNoteLunch),
      tx('guide_tx_16', e, 'grocery', 240000, 18, l.seedNoteVegetables),
      tx('guide_tx_17', i, 'invest', 350000, 20, l.seedNoteInterest),
      tx('guide_tx_18', e, 'transport', 70000, 21, l.seedNoteRide),
      tx('guide_tx_19', e, 'shop', 250000, 24, l.seedNoteTshirt),
      tx(
        'guide_tx_20',
        i,
        'salary',
        1200000,
        25,
        l.seedNoteSalary,
        'guide_bank',
      ),
      tx('guide_tx_21', e, 'food', 150000, 26, l.seedNoteCoffee),
      tx(
        'guide_tx_22',
        e,
        'bill',
        220000,
        28,
        l.seedNoteElectricity,
        'guide_bank',
      ),
      tx(
        'guide_tx_23',
        i,
        'salary',
        15000000,
        4,
        l.seedNoteSalary,
        'guide_bank',
      ),
    ]);

    _goals.add(
      Goal(
        id: 'guide_goal_trip',
        name: l.seedGoalTrip,
        icon: AppIcons.flight,
        color: const Color(0xFF4C9BE8),
        target: scaleAmount(10000000),
        currencyCode: _currency.code,
        deadline: today.add(const Duration(days: 90)),
        entries: [
          GoalEntry(
            id: 'guide_goal_entry_1',
            amount: scaleAmount(2000000),
            date: today.subtract(const Duration(days: 20)),
            note: l.seedGoalInitial,
          ),
          GoalEntry(
            id: 'guide_goal_entry_2',
            amount: scaleAmount(1500000),
            date: today.subtract(const Duration(days: 6)),
            note: l.seedGoalMonthly,
          ),
        ],
      ),
    );

    _debts.addAll([
      Debt(
        id: 'guide_debt_lend',
        type: DebtType.lend,
        person: l.seedPersonMinh,
        amount: scaleAmount(1500000),
        date: today.subtract(const Duration(days: 12)),
        dueDate: today.add(const Duration(days: 18)),
        note: l.seedDebtLendNote,
        currencyCode: _currency.code,
        payments: [
          DebtPayment(
            id: 'guide_debt_payment_1',
            amount: scaleAmount(500000),
            date: today.subtract(const Duration(days: 4)),
            note: l.seedDebtPayment,
          ),
        ],
      ),
      Debt(
        id: 'guide_debt_borrow',
        type: DebtType.borrow,
        person: l.seedPersonLan,
        amount: scaleAmount(3000000),
        date: today.subtract(const Duration(days: 40)),
        dueDate: today.subtract(const Duration(days: 3)),
        note: l.seedDebtBorrowNote,
        currencyCode: _currency.code,
      ),
    ]);

    _recurrings.addAll([
      RecurringTransaction(
        id: 'guide_recurring_bill',
        type: e,
        categoryId: 'bill',
        walletId: 'guide_bank',
        amount: scaleAmount(650000),
        frequency: Frequency.monthly,
        startDate: today,
        nextDate: today.add(const Duration(days: 5)),
        note: l.seedNoteElectricity,
      ),
      RecurringTransaction(
        id: 'guide_recurring_grocery',
        type: e,
        categoryId: 'grocery',
        walletId: guideCashWalletId,
        amount: scaleAmount(220000),
        frequency: Frequency.weekly,
        startDate: today,
        nextDate: today.add(const Duration(days: 3)),
        note: l.seedNoteVegetables,
      ),
    ]);

    _plannedEvents.addAll([
      PlannedEvent(
        id: 'guide_event_today',
        title: l.seedNoteElectricity,
        type: e,
        amount: scaleAmount(650000),
        date: today.add(const Duration(hours: 18)),
        currencyCode: _currency.code,
        note: l.seedNoteElectricity,
        walletId: 'guide_bank',
      ),
      PlannedEvent(
        id: 'guide_event_upcoming',
        title: l.seedGoalTrip,
        type: e,
        amount: scaleAmount(1500000),
        date: today.add(const Duration(days: 4, hours: 10)),
        currencyCode: _currency.code,
        note: l.seedGoalTrip,
        walletId: guideCashWalletId,
      ),
    ]);
  }
}

class _GuideDemoSnapshot {
  _GuideDemoSnapshot({
    required List<Category> categories,
    required List<Transaction> transactions,
    required List<Wallet> wallets,
    required List<Budget> budgets,
    required List<Goal> goals,
    required List<Debt> debts,
    required List<RecurringTransaction> recurrings,
    required List<PlannedEvent> plannedEvents,
    required this.selectedWalletId,
  }) : categories = List.of(categories),
       transactions = List.of(transactions),
       wallets = List.of(wallets),
       budgets = List.of(budgets),
       goals = List.of(goals),
       debts = List.of(debts),
       recurrings = List.of(recurrings),
       plannedEvents = List.of(plannedEvents);

  final List<Category> categories;
  final List<Transaction> transactions;
  final List<Wallet> wallets;
  final List<Budget> budgets;
  final List<Goal> goals;
  final List<Debt> debts;
  final List<RecurringTransaction> recurrings;
  final List<PlannedEvent> plannedEvents;
  final String? selectedWalletId;
}


