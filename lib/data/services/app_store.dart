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
  static const _themeModeKey = 'themeMode';
  static const _currencyKey = 'currency';
  static const _selectedWalletKey = 'selectedWallet';
  static const _localeKey = 'locale';


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
  ThemeMode _themeMode = ThemeMode.system;
  AppCurrency _currency = AppCurrency.vnd;
  Locale? _locale;
  String? _selectedWalletId;

  bool get onboarded => _onboarded;

  ThemeMode get themeMode => _themeMode;

  AppCurrency get currency => _currency;

  Locale? get locale => _locale;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _onboarded = _prefs.getBool(_onboardedKey) ?? false;
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
            .map((e) => RecurringTransaction.fromJson(e as Map<String, dynamic>))
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
    final rawCategories = _prefs.getString(_categoriesKey);
    final rawTransactions = _prefs.getString(_transactionsKey);
    final rawWallets = _prefs.getString(_walletsKey);
    final rawBudgets = _prefs.getString(_budgetsKey);
    final rawGoals = _prefs.getString(_goalsKey);
    final rawDebts = _prefs.getString(_debtsKey);
    if (rawCategories != null && rawTransactions != null) {
      try {
        bool missingCurrencyCode(String? raw) => raw != null &&
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
        if (wallets.isEmpty) throw const FormatException('no wallets');
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
        if (rawWallets == null ||
            rawBudgets == null ||
            rawGoals == null ||
            rawDebts == null ||
            missingCurrencyCode(rawWallets) ||
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
    await _save();
  }

  Future<void> _save() async {
    await _prefs.setString(
      _categoriesKey,
      jsonEncode(_categories.map((c) => c.toJson()).toList()),
    );
    await _prefs.setString(
      _transactionsKey,
      jsonEncode(_transactions.map((t) => t.toJson()).toList()),
    );
    await _prefs.setString(
      _walletsKey,
      jsonEncode(_wallets.map((w) => w.toJson()).toList()),
    );
    await _prefs.setString(
      _budgetsKey,
      jsonEncode(_budgets.map((b) => b.toJson()).toList()),
    );
    await _prefs.setString(
      _goalsKey,
      jsonEncode(_goals.map((g) => g.toJson()).toList()),
    );
    await _prefs.setString(
      _debtsKey,
      jsonEncode(_debts.map((d) => d.toJson()).toList()),
    );
    await _prefs.setString(
      _recurringsKey,
      jsonEncode(_recurrings.map((r) => r.toJson()).toList()),
    );
    await _prefs.setString(
      _plannedEventsKey,
      jsonEncode(_plannedEvents.map((e) => e.toJson()).toList()),
    );
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
    if (id != null) setCurrency(AppCurrency.byCode(walletById(id)?.currencyCode));
    if (id == null) {
      _prefs.remove(_selectedWalletKey);
    } else {
      _prefs.setString(_selectedWalletKey, id);
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
        _wallets.where((w) => w.currencyCode == wallet.currencyCode).length <= 1) {
      return;
    }
    _wallets.removeWhere((w) => w.id == id);
    _transactions.removeWhere((t) => t.walletId == id);
    _recurrings.removeWhere((r) => r.walletId == id);
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

  void updateTransaction(Transaction updated) {
    final index = _transactions.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;
    _transactions[index] = updated;
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
      return selected == null || event.walletId == null || event.walletId == selected;
    }),
  );

  List<PlannedEvent> get allPlannedEvents => List.unmodifiable(_plannedEvents);

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
    _recurrings.removeWhere((r) => r.categoryId == id);
    notifyListeners();
    _save();
  }

  List<Budget> get budgets => List.unmodifiable(
    _budgets.where((b) => b.currencyCode == _currency.code),
  );

  List<Budget> get allBudgets => List.unmodifiable(_budgets);

  Budget? budgetOfCategory(String categoryId) {
    for (final b in _budgets) {
      if (b.categoryId == categoryId && b.currencyCode == _currency.code) return b;
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
      if (t.type != TxType.expense || t.categoryId != categoryId ||
          walletById(t.walletId)?.currencyCode != code) continue;
      if (range.contains(t.date)) sum += t.amount;
    }
    return sum;
  }

  double expenseTotal(DateRange range, {String? currencyCode}) {
    final code = currencyCode ?? _currency.code;
    var sum = 0.0;
    for (final t in _transactions) {
      if (t.type == TxType.expense && range.contains(t.date) &&
          walletById(t.walletId)?.currencyCode == code) sum += t.amount;
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

  List<Goal> get goals => List.unmodifiable(
    _goals.where((g) => g.currencyCode == _currency.code),
  );

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

  List<Debt> get debts => List.unmodifiable(
    _debts.where((d) => d.currencyCode == _currency.code),
  );

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
    _recurrings.where((r) => walletById(r.walletId)?.currencyCode == _currency.code),
  );

  List<RecurringTransaction> get allRecurrings => List.unmodifiable(_recurrings);

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

  void removeRecurring(String id) {
    _recurrings.removeWhere((r) => r.id == id);
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
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    var created = 0;
    var changed = false;
    for (var i = 0; i < _recurrings.length; i++) {
      var r = _recurrings[i];
      var steps = 0;
      while (r.isDue(today) && steps < 400) {
        final d = r.nextDate;
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
    final fromCode = from.code;
    final sourceWalletIds = walletIds
        .where((id) => walletById(id)?.currencyCode == fromCode)
        .toSet();
    var expanded = true;
    while (expanded) {
      expanded = false;
      for (final goal in _goals) {
        if (goal.currencyCode != fromCode ||
            !goal.entries.any((entry) => sourceWalletIds.contains(entry.walletId))) {
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
        final linked = sourceWalletIds.contains(debt.walletId) ||
            debt.payments.any((payment) => sourceWalletIds.contains(payment.walletId));
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
          !g.entries.any((entry) => sourceWalletIds.contains(entry.walletId))) continue;
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
              !d.payments.any((payment) => sourceWalletIds.contains(payment.walletId)))) continue;
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

  void completeOnboarding([Wallet? wallet]) {
    if (wallet != null) _wallets.add(wallet);
    _onboarded = true;
    _prefs.setBool(_onboardedKey, true);
    notifyListeners();
    _save();
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

  void _seed() {
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

    _wallets.addAll([
      _cashWallet(l),
      Wallet(
        id: 'bank',
        name: l.bankWallet,
        icon: AppIcons.bank,
        color: const Color(0xFF4C9BE8),
        currencyCode: _currency.code,
      ),
    ]);

    _budgets.addAll([
      Budget(id: 'b_food', categoryId: 'food', limit: 2000000, currencyCode: _currency.code),
      Budget(id: 'b_shop', categoryId: 'shop', limit: 1000000, currencyCode: _currency.code),
      Budget(id: 'b_transport', categoryId: 'transport', limit: 500000, currencyCode: _currency.code),
    ]);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Transaction tx(
      String id,
      TxType type,
      String cat,
      double amount,
      int daysAgo, [
      String note = '',
    ]) => Transaction(
      id: id,
      type: type,
      categoryId: cat,
      walletId: type == TxType.income ? 'bank' : 'cash',
      amount: amount,
      date: today
          .subtract(Duration(days: daysAgo))
          .add(const Duration(hours: 12)),
      note: note,
    );

    _transactions.addAll([
      tx('1', e, 'food', 85000, 0, l.seedNoteLunch),
      tx('2', e, 'transport', 30000, 0, l.seedNoteRide),
      tx('3', e, 'grocery', 220000, 1, l.seedNoteVegetables),
      tx('4', e, 'shop', 450000, 2, l.seedNoteTshirt),
      tx('5', e, 'food', 120000, 3, l.seedNoteCoffee),
      tx('6', e, 'bill', 650000, 5, l.seedNoteElectricity),
      tx('7', e, 'home', 3000000, 8, l.seedNoteRent),
      tx('8', e, 'health', 180000, 12, l.seedNoteMedicine),
      tx('9', e, 'food', 95000, 15),
      tx('10', i, 'salary', 15000000, 4, l.seedNoteSalary),
      tx('11', i, 'bonus', 1000000, 10, l.seedNoteProjectBonus),
      tx('12', i, 'invest', 350000, 20, l.seedNoteInterest),
    ]);

    _goals.add(
      Goal(
        id: 'g_trip',
        name: l.seedGoalTrip,
        icon: AppIcons.flight,
        color: const Color(0xFF4C9BE8),
        target: 10000000,
        currencyCode: _currency.code,
        deadline: today.add(const Duration(days: 90)),
        entries: [
          GoalEntry(
            id: 'ge_1',
            amount: 2000000,
            date: today.subtract(const Duration(days: 20)),
            note: l.seedGoalInitial,
          ),
          GoalEntry(
            id: 'ge_2',
            amount: 1500000,
            date: today.subtract(const Duration(days: 6)),
            note: l.seedGoalMonthly,
          ),
        ],
      ),
    );

    _debts.addAll([
      Debt(
        id: 'd_minh',
        type: DebtType.lend,
        person: l.seedPersonMinh,
        amount: 1500000,
        date: today.subtract(const Duration(days: 12)),
        dueDate: today.add(const Duration(days: 18)),
        note: l.seedDebtLendNote,
        currencyCode: _currency.code,
        payments: [
          DebtPayment(
            id: 'dp_1',
            amount: 500000,
            date: today.subtract(const Duration(days: 4)),
            note: l.seedDebtPayment,
          ),
        ],
      ),
      Debt(
        id: 'd_lan',
        type: DebtType.borrow,
        person: l.seedPersonLan,
        amount: 3000000,
        date: today.subtract(const Duration(days: 40)),
        dueDate: today.subtract(const Duration(days: 3)),
        note: l.seedDebtBorrowNote,
        currencyCode: _currency.code,
      ),
    ]);
  }
}
