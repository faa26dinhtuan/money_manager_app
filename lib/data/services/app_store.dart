import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/date_range.dart';
import 'package:money_manager_app/data/models/backup_data.dart';
import 'package:money_manager_app/data/models/budget.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/debt.dart';
import 'package:money_manager_app/data/models/goal.dart';
import 'package:money_manager_app/data/models/recurring_transaction.dart';
import 'package:money_manager_app/data/models/transaction.dart';
import 'package:money_manager_app/data/models/wallet.dart';
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
  static const _onboardedKey = 'onboarded';
  static const _themeModeKey = 'themeMode';
  static const _currencyKey = 'currency';
  static const _selectedWalletKey = 'selectedWallet';

  static const _cashWallet = Wallet(
    id: 'cash',
    name: 'Tiền mặt',
    icon: Icons.payments,
    color: Color(0xFF2A8C66),
  );

  late final SharedPreferences _prefs;

  final List<Category> _categories = [];
  final List<Transaction> _transactions = [];
  final List<Wallet> _wallets = [];
  final List<Budget> _budgets = [];
  final List<Goal> _goals = [];
  final List<Debt> _debts = [];
  final List<RecurringTransaction> _recurrings = [];
  bool _onboarded = false;
  ThemeMode _themeMode = ThemeMode.light;
  AppCurrency _currency = AppCurrency.vnd;
  String? _selectedWalletId;

  bool get onboarded => _onboarded;

  ThemeMode get themeMode => _themeMode;

  AppCurrency get currency => _currency;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _onboarded = _prefs.getBool(_onboardedKey) ?? false;
    _themeMode =
        ThemeMode.values.asNameMap()[_prefs.getString(_themeModeKey)] ??
        ThemeMode.light;
    _currency = AppCurrency.byCode(_prefs.getString(_currencyKey));
    AppCurrency.current = _currency;
    _selectedWalletId = _prefs.getString(_selectedWalletKey);
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
    final rawCategories = _prefs.getString(_categoriesKey);
    final rawTransactions = _prefs.getString(_transactionsKey);
    final rawWallets = _prefs.getString(_walletsKey);
    final rawBudgets = _prefs.getString(_budgetsKey);
    final rawGoals = _prefs.getString(_goalsKey);
    final rawDebts = _prefs.getString(_debtsKey);
    if (rawCategories != null && rawTransactions != null) {
      try {
        final categories = (jsonDecode(rawCategories) as List)
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList();
        final transactions = (jsonDecode(rawTransactions) as List)
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
        final wallets = rawWallets == null
            ? <Wallet>[_cashWallet]
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
            rawDebts == null) {
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
                  (walletId == null || t.walletId == walletId),
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

  double get balance =>
      _wallets.fold<double>(0, (sum, w) => sum + walletBalance(w.id));

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

  List<Budget> get budgets => List.unmodifiable(_budgets);

  Budget? budgetOfCategory(String categoryId) {
    for (final b in _budgets) {
      if (b.categoryId == categoryId) return b;
    }
    return null;
  }

  double spentOfCategory(String categoryId, DateRange range) {
    var sum = 0.0;
    for (final t in _transactions) {
      if (t.type != TxType.expense || t.categoryId != categoryId) continue;
      if (range.contains(t.date)) sum += t.amount;
    }
    return sum;
  }

  double expenseTotal(DateRange range) {
    var sum = 0.0;
    for (final t in _transactions) {
      if (t.type == TxType.expense && range.contains(t.date)) sum += t.amount;
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

  List<Goal> get goals => List.unmodifiable(_goals);

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

  List<Debt> get debts => List.unmodifiable(_debts);

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

  List<RecurringTransaction> get recurrings => List.unmodifiable(_recurrings);

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

  void setCurrency(AppCurrency currency) {
    _currency = currency;
    AppCurrency.current = currency;
    _prefs.setString(_currencyKey, currency.code);
    notifyListeners();
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

  void _seed() {
    const e = TxType.expense;
    const i = TxType.income;
    _categories.addAll(const [
      Category(
        id: 'food',
        name: 'Ăn uống',
        icon: Icons.restaurant,
        color: Color(0xFFF5B82E),
        type: e,
      ),
      Category(
        id: 'grocery',
        name: 'Đi chợ',
        icon: Icons.shopping_basket,
        color: Color(0xFF4C9BE8),
        type: e,
      ),
      Category(
        id: 'shop',
        name: 'Mua sắm',
        icon: Icons.shopping_cart,
        color: Color(0xFF9B5DE5),
        type: e,
      ),
      Category(
        id: 'home',
        name: 'Nhà cửa',
        icon: Icons.home,
        color: Color(0xFFE8506E),
        type: e,
      ),
      Category(
        id: 'transport',
        name: 'Di chuyển',
        icon: Icons.directions_bus,
        color: Color(0xFF3CC6B0),
        type: e,
      ),
      Category(
        id: 'health',
        name: 'Sức khỏe',
        icon: Icons.favorite,
        color: Color(0xFFEF6C57),
        type: e,
      ),
      Category(
        id: 'bill',
        name: 'Hóa đơn',
        icon: Icons.bolt,
        color: Color(0xFF6BB94A),
        type: e,
      ),
      Category(
        id: 'other_e',
        name: 'Khác',
        icon: Icons.help_outline,
        color: Color(0xFF8E9A93),
        type: e,
      ),
      Category(
        id: 'salary',
        name: 'Lương',
        icon: Icons.account_balance_wallet,
        color: Color(0xFF2A8C66),
        type: i,
      ),
      Category(
        id: 'bonus',
        name: 'Thưởng',
        icon: Icons.card_giftcard,
        color: Color(0xFFF5B82E),
        type: i,
      ),
      Category(
        id: 'invest',
        name: 'Đầu tư',
        icon: Icons.trending_up,
        color: Color(0xFF4C9BE8),
        type: i,
      ),
      Category(
        id: 'other_i',
        name: 'Khác',
        icon: Icons.help_outline,
        color: Color(0xFF8E9A93),
        type: i,
      ),
    ]);

    _wallets.addAll(const [
      _cashWallet,
      Wallet(
        id: 'bank',
        name: 'Ngân hàng',
        icon: Icons.account_balance,
        color: Color(0xFF4C9BE8),
      ),
    ]);

    _budgets.addAll(const [
      Budget(id: 'b_food', categoryId: 'food', limit: 2000000),
      Budget(id: 'b_shop', categoryId: 'shop', limit: 1000000),
      Budget(id: 'b_transport', categoryId: 'transport', limit: 500000),
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
      tx('1', e, 'food', 85000, 0, 'Cơm trưa'),
      tx('2', e, 'transport', 30000, 0, 'Grab'),
      tx('3', e, 'grocery', 220000, 1, 'Rau củ ở chợ'),
      tx('4', e, 'shop', 450000, 2, 'Áo thun'),
      tx('5', e, 'food', 120000, 3, 'Cà phê + bánh'),
      tx('6', e, 'bill', 650000, 5, 'Tiền điện'),
      tx('7', e, 'home', 3000000, 8, 'Tiền nhà'),
      tx('8', e, 'health', 180000, 12, 'Thuốc'),
      tx('9', e, 'food', 95000, 15),
      tx('10', i, 'salary', 15000000, 4, 'Lương tháng'),
      tx('11', i, 'bonus', 1000000, 10, 'Thưởng dự án'),
      tx('12', i, 'invest', 350000, 20, 'Lãi tiết kiệm'),
    ]);

    _goals.add(
      Goal(
        id: 'g_trip',
        name: 'Du lịch Đà Lạt',
        icon: Icons.flight,
        color: const Color(0xFF4C9BE8),
        target: 10000000,
        deadline: today.add(const Duration(days: 90)),
        entries: [
          GoalEntry(
            id: 'ge_1',
            amount: 2000000,
            date: today.subtract(const Duration(days: 20)),
            note: 'Số tiền ban đầu',
          ),
          GoalEntry(
            id: 'ge_2',
            amount: 1500000,
            date: today.subtract(const Duration(days: 6)),
            note: 'Dành dụm tháng này',
          ),
        ],
      ),
    );

    _debts.addAll([
      Debt(
        id: 'd_minh',
        type: DebtType.lend,
        person: 'Bạn Minh',
        amount: 1500000,
        date: today.subtract(const Duration(days: 12)),
        dueDate: today.add(const Duration(days: 18)),
        note: 'Cho mượn đóng tiền trọ',
        payments: [
          DebtPayment(
            id: 'dp_1',
            amount: 500000,
            date: today.subtract(const Duration(days: 4)),
            note: 'Trả đợt 1',
          ),
        ],
      ),
      Debt(
        id: 'd_lan',
        type: DebtType.borrow,
        person: 'Chị Lan',
        amount: 3000000,
        date: today.subtract(const Duration(days: 40)),
        dueDate: today.subtract(const Duration(days: 3)),
        note: 'Mượn mua xe đạp',
      ),
    ]);
  }
}
