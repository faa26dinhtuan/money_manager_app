// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Money Manager';

  @override
  String get overview => 'Overview';

  @override
  String get transactions => 'Transactions';

  @override
  String get calendar => 'Calendar';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get plannedEvent => 'Planned event';

  @override
  String get plannedEvents => 'Planned events';

  @override
  String get addPlannedEvent => 'Add event';

  @override
  String get editPlannedEvent => 'Edit event';

  @override
  String get plannedEventName => 'Event name';

  @override
  String get pleaseEnterEventName => 'Enter an event name';

  @override
  String get deletePlannedEventTitle => 'Delete planned event?';

  @override
  String get deletePlannedEventMessage =>
      'This event will be removed from the calendar.';

  @override
  String get categories => 'Categories';

  @override
  String get manageCategories => 'Manage categories';

  @override
  String get wallet => 'Wallet';

  @override
  String get settings => 'Settings';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get no => 'No';

  @override
  String get done => 'Done';

  @override
  String get confirm => 'Confirm';

  @override
  String get clearAll => 'Clear all';

  @override
  String get continueText => 'Continue';

  @override
  String get start => 'Start';

  @override
  String get other => 'Other';

  @override
  String get history => 'History';

  @override
  String get note => 'Note';

  @override
  String get date => 'Date';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get icon => 'Icon';

  @override
  String get color => 'Color';

  @override
  String get balance => 'Balance';

  @override
  String get balanceUpper => 'BALANCE';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get initialBalance => 'Initial balance';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get expenseUpper => 'EXPENSE';

  @override
  String get incomeUpper => 'INCOME';

  @override
  String get spent => 'Spent';

  @override
  String get received => 'Received';

  @override
  String get incomeSummary => 'Income';

  @override
  String get expenseSummary => 'Expense';

  @override
  String get difference => 'Net';

  @override
  String get remaining => 'Remaining';

  @override
  String get exceeded => 'Over budget';

  @override
  String get day => 'Day';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get customPeriod => 'Period';

  @override
  String get today => 'Today';

  @override
  String get selectDateRange => 'Select date range';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get invalidDate => 'Invalid date';

  @override
  String get mustBeAfterStartDate => 'Must be after start date';

  @override
  String monthLabel(int month, int year) {
    return 'Month $month, $year';
  }

  @override
  String yearLabel(int year) {
    return 'Year $year';
  }

  @override
  String get searchCategoryOrNote => 'Search by category or note';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get noTransactionsInRange => 'No transactions in this period';

  @override
  String get deleteTransactionTitle => 'Delete transaction?';

  @override
  String get deleteTransactionMessage =>
      'This transaction will be removed from the list.';

  @override
  String get deleteTransactionPermanent =>
      'This transaction will be permanently deleted.';

  @override
  String get editTransaction => 'Edit transaction';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get deleteTransaction => 'Delete transaction';

  @override
  String transactionCount(int count) {
    return '$count transaction(s)';
  }

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String budgetExceeded(String name, String amount) {
    return 'Exceeded budget \"$name\" by $amount';
  }

  @override
  String budgetWarning(String name, String percent, String remaining) {
    return 'Budget \"$name\" used $percent, remaining $remaining';
  }

  @override
  String autoAddedRecurring(int count) {
    return 'Automatically added $count recurring transaction(s)';
  }

  @override
  String get myWallets => 'My wallets';

  @override
  String get addWallet => 'Add wallet';

  @override
  String get editWallet => 'Edit wallet';

  @override
  String get deleteWallet => 'Delete wallet';

  @override
  String get walletName => 'Wallet name';

  @override
  String walletCount(int count) {
    return '$count wallet(s)';
  }

  @override
  String get allWallets => 'All wallets';

  @override
  String get selectWallet => 'Select wallet';

  @override
  String get noWalletAttached => 'No wallet linked';

  @override
  String get pleaseEnterWalletName => 'Please enter a wallet name';

  @override
  String get keepAtLeastOneWallet => 'Must keep at least one wallet';

  @override
  String get deleteWalletTitle => 'Delete wallet?';

  @override
  String deleteWalletMessageSimple(String name) {
    return 'Wallet \"$name\" will be deleted.';
  }

  @override
  String deleteWalletMessageWithTx(String name, int count) {
    return 'Wallet \"$name\" and $count transactions in this wallet will be deleted.';
  }

  @override
  String deleteWalletLinkedNotice(int count) {
    return ' $count linked entries in goals and debts will be kept without a wallet.';
  }

  @override
  String get manageWalletsSubtitle => 'Create and manage your wallets';

  @override
  String get cashWallet => 'Cash';

  @override
  String get bankWallet => 'Bank';

  @override
  String get eWallet => 'E-Wallet';

  @override
  String get createCategory => 'New category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryName => 'Category name';

  @override
  String get pleaseEnterCategoryName => 'Please enter a category name';

  @override
  String get deleteCategoryTitle => 'Delete category?';

  @override
  String deleteCategorySimple(String name) {
    return 'Category \"$name\" will be deleted.';
  }

  @override
  String deleteCategoryWithTx(String name, int count) {
    return 'Category \"$name\" and $count transactions in this category will be deleted.';
  }

  @override
  String get catFood => 'Food & Dining';

  @override
  String get catGrocery => 'Groceries';

  @override
  String get catShop => 'Shopping';

  @override
  String get catHome => 'House';

  @override
  String get catTransport => 'Transport';

  @override
  String get catHealth => 'Health';

  @override
  String get catBill => 'Bills';

  @override
  String get catEntertain => 'Entertainment';

  @override
  String get catSalary => 'Salary';

  @override
  String get catBonus => 'Bonus';

  @override
  String get catInvest => 'Investment';

  @override
  String get catOtherIncome => 'Other income';

  @override
  String get budget => 'Budget';

  @override
  String get budgetByCategory => 'Category budget';

  @override
  String get budgetSubtitle => 'Set monthly spending limits';

  @override
  String get monthlyLimit => 'Monthly limit';

  @override
  String get addBudget => 'Add budget';

  @override
  String get editBudget => 'Edit budget';

  @override
  String get deleteBudget => 'Delete budget';

  @override
  String get deleteBudgetTitle => 'Delete budget?';

  @override
  String deleteBudgetMessage(String name) {
    return 'Budget for \"$name\" will be deleted.';
  }

  @override
  String get noBudgetsYet => 'No budgets yet';

  @override
  String get allCategoriesHaveBudgets =>
      'All expense categories already have budgets';

  @override
  String get pleaseEnterLimit => 'Please enter a budget limit';

  @override
  String canSpendPerDay(String amount) {
    return 'Can spend $amount/day';
  }

  @override
  String outsideBudget(String amount) {
    return 'Outside budget: $amount';
  }

  @override
  String get viewTransactions => 'View transactions';

  @override
  String spentOfLimit(String amount) {
    return 'Spent $amount';
  }

  @override
  String limitAmount(String amount) {
    return 'Limit $amount';
  }

  @override
  String statusOver(String amount) {
    return 'Over $amount';
  }

  @override
  String statusRemaining(String amount) {
    return 'Left $amount';
  }

  @override
  String get goals => 'Savings goals';

  @override
  String get goalsSubtitle => 'Save money for your future plans';

  @override
  String get addGoal => 'Add goal';

  @override
  String get editGoal => 'Edit goal';

  @override
  String get deleteGoal => 'Delete goal';

  @override
  String get deleteGoalTitle => 'Delete goal?';

  @override
  String deleteGoalMessage(String name) {
    return 'Goal \"$name\" and its history will be deleted.';
  }

  @override
  String get goalName => 'Goal name';

  @override
  String get targetAmount => 'Target amount';

  @override
  String get totalSaved => 'Total saved';

  @override
  String get savedLabel => 'Saved';

  @override
  String targetLabel(String amount) {
    return 'Target $amount';
  }

  @override
  String stillNeeded(String amount) {
    return 'Need $amount more';
  }

  @override
  String get deadline => 'Deadline';

  @override
  String get noDeadline => 'No deadline';

  @override
  String activeGoalsCount(int count) {
    return 'Active ($count)';
  }

  @override
  String doneGoalsCount(int count) {
    return 'Completed ($count)';
  }

  @override
  String get noGoalsYet => 'No goals yet';

  @override
  String get noGoalsCompleted => 'No completed goals yet';

  @override
  String get noGoalsActive => 'No active goals';

  @override
  String goalsCompletedCount(int done, int total) {
    return '$done/$total completed';
  }

  @override
  String get deposit => 'Deposit';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get depositAction => 'Deposit into goal';

  @override
  String get withdrawAction => 'Withdraw from goal';

  @override
  String congratsGoalCompleted(String name) {
    return 'Congratulations! You completed the goal \"$name\"';
  }

  @override
  String get pleaseEnterGoalName => 'Please enter a goal name';

  @override
  String get pleaseEnterTarget => 'Please enter a target amount';

  @override
  String get deadlineOptional => 'Deadline (optional)';

  @override
  String get initialDeposit => 'Initial deposit';

  @override
  String get selectDeadline => 'Pick deadline';

  @override
  String daysRemaining(int days) {
    return '$days day(s) left';
  }

  @override
  String get dueToday => 'Due today';

  @override
  String daysOverdue(int days) {
    return '$days day(s) overdue';
  }

  @override
  String get completed => 'Completed';

  @override
  String get deleteEntryTitle => 'Delete this entry?';

  @override
  String get deleteEntryMessage => 'The goal amount will be recalculated.';

  @override
  String get debts => 'Debts & Loans';

  @override
  String get debtsSubtitle => 'Track money you lend and borrow';

  @override
  String get addDebt => 'Add debt entry';

  @override
  String get editDebt => 'Edit debt entry';

  @override
  String get deleteDebt => 'Delete debt entry';

  @override
  String get deleteDebtTitle => 'Delete debt entry?';

  @override
  String get deleteDebtMessage =>
      'This debt and all payment history will be deleted.';

  @override
  String get lend => 'Lent';

  @override
  String get borrow => 'Borrowed';

  @override
  String get collectDebt => 'Collect';

  @override
  String get payDebt => 'Repay';

  @override
  String get collected => 'Collected';

  @override
  String get paid => 'Repaid';

  @override
  String get principalAmount => 'Principal amount';

  @override
  String get person => 'Person';

  @override
  String get personHint => 'Borrower / lender name';

  @override
  String get pleaseEnterPerson => 'Please enter person name';

  @override
  String openDebtsCount(int count) {
    return 'Unsettled ($count)';
  }

  @override
  String settledDebtsCount(int count) {
    return 'Settled ($count)';
  }

  @override
  String lendCount(int count) {
    return 'Lend ($count)';
  }

  @override
  String borrowCount(int count) {
    return 'Borrow ($count)';
  }

  @override
  String get receivable => 'To collect';

  @override
  String get payable => 'To repay';

  @override
  String overdueCount(int count) {
    return '$count overdue';
  }

  @override
  String get noSettledDebts => 'No settled debts';

  @override
  String get noLendDebts => 'No lent items';

  @override
  String get noBorrowDebts => 'No borrowed items';

  @override
  String debtSettledNotification(String person) {
    return 'Settled debt with \"$person\"';
  }

  @override
  String get settled => 'Settled';

  @override
  String get dueDate => 'Due date';

  @override
  String get noDueDate => 'No due date';

  @override
  String debtCreatedDate(String type, String date) {
    return '$type on $date';
  }

  @override
  String get deletePaymentTitle => 'Delete this payment?';

  @override
  String get deletePaymentMessage =>
      'The remaining balance will be recalculated.';

  @override
  String get lendPrincipal => 'Lent amount';

  @override
  String get borrowPrincipal => 'Borrowed amount';

  @override
  String get repayment => 'Debt payment';

  @override
  String get recurring => 'Recurring';

  @override
  String get recurringSubtitle => 'Automate scheduled transactions';

  @override
  String get addRecurring => 'Add recurring';

  @override
  String get editRecurring => 'Edit recurring';

  @override
  String get deleteRecurring => 'Delete recurring';

  @override
  String get deleteRecurringTitle => 'Delete recurring?';

  @override
  String get deleteRecurringMessage =>
      'This recurring transaction will be removed and no longer generate entries.';

  @override
  String get frequency => 'Frequency';

  @override
  String get freqDaily => 'Daily';

  @override
  String get freqWeekly => 'Weekly';

  @override
  String get freqMonthly => 'Monthly';

  @override
  String get freqYearly => 'Yearly';

  @override
  String get nextDate => 'Next date';

  @override
  String get startDateLabel => 'Start date';

  @override
  String get endDateOptional => 'End date (optional)';

  @override
  String get noRecurringYet => 'No recurring transactions yet';

  @override
  String get monthlyAvgExpense => 'Estimated monthly expense';

  @override
  String get monthlyAvgIncome => 'Estimated monthly income';

  @override
  String get active => 'Active';

  @override
  String get paused => 'Paused';

  @override
  String get finished => 'Ended';

  @override
  String get currencyDefault => 'Default currency';

  @override
  String get walletCurrency => 'Wallet currency';

  @override
  String get useExistingWallets => 'Use existing wallets';

  @override
  String get currencyCodeLabel => 'Currency';

  @override
  String get currencyDefaultNotice =>
      'Choose the default currency for display and entering amounts. This does not convert wallet balances.';

  @override
  String get currencyConverter => 'Currency converter';

  @override
  String get currencyConverterSubtitle =>
      'Convert amounts and wallets using exchange rates';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System default';

  @override
  String get language => 'Language';

  @override
  String get langSystem => 'System default';

  @override
  String get langVi => 'Tiếng Việt';

  @override
  String get langEn => 'English';

  @override
  String get backupAndRestore => 'Backup & restore';

  @override
  String get exportData => 'Export data';

  @override
  String get exportCsv => 'Export to CSV';

  @override
  String get about => 'About';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get backupData => 'Backup data';

  @override
  String get restoreData => 'Restore data';

  @override
  String get backupCopied =>
      'Backup copied to clipboard. Save it in a safe place';

  @override
  String get restoreNotFound => 'No valid backup found in clipboard';

  @override
  String get restoreConfirmTitle => 'Restore data?';

  @override
  String get restoreConfirmMessage => 'All current data will be overwritten.';

  @override
  String get restoreSuccess => 'Data restored successfully';

  @override
  String convertCurrencyTitle(String code) {
    return 'Switch to $code';
  }

  @override
  String convertCurrencyPrompt(String currency) {
    return 'Use or create wallets in $currency without conversion, or convert the current data?';
  }

  @override
  String get displayOnly => 'Display only';

  @override
  String get convertAll => 'Convert all';

  @override
  String get selectWalletsToConvert =>
      'Select wallets to convert to the new currency';

  @override
  String get convertSelectedWallets => 'Convert selected wallets';

  @override
  String get convertWallets => 'Convert wallets';

  @override
  String get walletConversionSubtitle =>
      'Select one or more wallets with the same currency to convert.';

  @override
  String get filterCurrencies => 'Filter wallets by currency';

  @override
  String get showAllCurrencies => 'Show all currencies';

  @override
  String get walletsMustShareCurrency =>
      'You can select multiple wallets, but they must use the same currency.';

  @override
  String get selectTargetCurrency => 'Choose the currency to convert to';

  @override
  String get changeDefaultCurrency => 'Use this currency';

  @override
  String askAddWalletForCurrency(String currency) {
    return 'Do you want to add a new wallet for $currency?';
  }

  @override
  String get currencyConvertLinkedNotice =>
      'If a goal or debt is linked to multiple wallets, those wallets will be converted together to keep the data consistent.';

  @override
  String get backupSavedConfirmation => 'I saved the backup somewhere safe';

  @override
  String get ratesUpdated => 'Exchange rates updated';

  @override
  String get ratesOffline => 'No connection, using saved rates';

  @override
  String get welcome => 'Welcome!';

  @override
  String get welcomeSubtitle =>
      'Create your first wallet to start tracking your money';

  @override
  String get quickSuggestions => 'Quick suggestions';

  @override
  String get createWalletAndStart => 'Create wallet & start';

  @override
  String get introTrackTitle => 'Track expenses & income';

  @override
  String get introTrackDesc =>
      'Record every transaction, view charts by category to understand your spending.';

  @override
  String get introWalletTitle => 'Multiple wallets';

  @override
  String get introWalletDesc =>
      'Separate cash, banks, e-wallets, and keep tabs on balances effortlessly.';

  @override
  String get introBudgetTitle => 'Budgets & goals';

  @override
  String get introBudgetDesc =>
      'Set monthly spending limits, receive warning alerts and save for your dreams.';

  @override
  String get introRecurringTitle => 'Debts & recurring bills';

  @override
  String get introRecurringDesc =>
      'Track loans and debts, and let regular expenses like rent and salary log automatically.';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get selectCurrency => 'Select currency';

  @override
  String get fromCurrency => 'From';

  @override
  String get toCurrency => 'To';

  @override
  String get refreshRates => 'Refresh rates';

  @override
  String get selectAll => 'Select all';

  @override
  String get deleteSelectedTitle => 'Delete selected items?';

  @override
  String deleteSelectedMessage(int count) {
    return 'Delete $count selected items? This action cannot be undone.';
  }

  @override
  String get exportCsvTitle => 'Export to CSV file';

  @override
  String get splashTagline => 'Personal expense manager';

  @override
  String get amountCannotBeLessThanPaid =>
      'Amount cannot be less than paid amount';

  @override
  String get exceedsRemainingAmount => 'Exceeds remaining amount';

  @override
  String collectAll(String amount) {
    return 'Collect all: $amount';
  }

  @override
  String payAll(String amount) {
    return 'Repay all: $amount';
  }

  @override
  String get creditToWallet => 'Add to wallet';

  @override
  String get debitFromWallet => 'Deduct from wallet';

  @override
  String get walletSourceLend => 'Fund from wallet';

  @override
  String get walletSourceBorrow => 'Deposit into wallet';

  @override
  String get debtDateLend => 'Date lent';

  @override
  String get debtDateBorrow => 'Date borrowed';

  @override
  String get borrower => 'Borrower';

  @override
  String get lender => 'Lender';

  @override
  String get backupExplainTitle => 'What is this feature for?';

  @override
  String get backupExplainBody =>
      'Data is stored only on this device. If you switch phones or delete the app, your data will be lost.\n\nBackup: creates a code containing all your data and copies it to clipboard. Paste it in Notes or email to keep safe.\n\nRestore: copy that code and tap Restore to bring your data back.';

  @override
  String get exportExplainBody =>
      'CSV is a simple spreadsheet text file. Select the sections you want to export below. You can open it with Excel or Google Sheets to view, filter, and calculate.\n\nUnlike Backup, this file is for analysis and reporting, not for restoring back into the app.';

  @override
  String get restoreFromClipboard => 'Restore from clipboard';

  @override
  String get depositAmount => 'Deposit amount';

  @override
  String get withdrawAmount => 'Withdraw amount';

  @override
  String get exceedsSavedAmount => 'Exceeds saved amount';

  @override
  String reachGoalAmount(String amount) {
    return 'Reach goal: $amount';
  }

  @override
  String walletBalanceLabel(String amount) {
    return 'Wallet balance: $amount';
  }

  @override
  String get deletePaymentConfirmTitle => 'Delete payment?';

  @override
  String get deletePaymentConfirmMessage =>
      'Remaining balance will be recalculated.';

  @override
  String get lentItem => 'Lent entry';

  @override
  String get borrowedItem => 'Borrowed entry';

  @override
  String duePrefix(String date) {
    return 'Due $date';
  }

  @override
  String get exportSectionTransactions => 'Transactions';

  @override
  String get exportSectionWallets => 'Wallets';

  @override
  String get exportSectionBudgets => 'Monthly budgets';

  @override
  String get exportSectionGoals => 'Savings goals';

  @override
  String get exportSectionDebts => 'Debts & Loans';

  @override
  String get exportSectionRecurrings => 'Recurring transactions';

  @override
  String get defaultRatesWarning =>
      'Using default offline rates which may be outdated. Connect to the internet and tap refresh to get the latest rates.';

  @override
  String lastUpdated(String time) {
    return 'Last updated: $time';
  }

  @override
  String get currencyDisclaimer =>
      'Exchange rates provided by ExchangeRate-API, updated daily, for reference only.';

  @override
  String get currencyConvertWarning =>
      'Transactions, goals, debts, and recurring items linked to selected wallets will be converted. Budgets are not linked to wallets and will keep their currency.';

  @override
  String get manageWallets => 'Wallets';

  @override
  String get manageWalletsDesc => 'Create and manage your wallets';

  @override
  String get budgetDesc => 'Set monthly spending limits';

  @override
  String get goalsDesc => 'Save money for your future plans';

  @override
  String get debtsDesc => 'Track money you lend and borrow';

  @override
  String get recurringDesc => 'Automate scheduled transactions';

  @override
  String get initialAmount => 'Initial amount';

  @override
  String get initialAmountOptional => 'Initial amount (optional)';

  @override
  String get noEndDate => 'No end date';

  @override
  String get repeatCycle => 'Repeat cycle';

  @override
  String get startsOn => 'Starts on';

  @override
  String get endsOn => 'Ends on (optional)';

  @override
  String get deleteRecurringConfirm =>
      'Previously generated transactions will still be kept.';

  @override
  String get curVnd => 'Vietnamese Dong';

  @override
  String get curUsd => 'US Dollar';

  @override
  String get curEur => 'Euro';

  @override
  String get curGbp => 'British Pound';

  @override
  String get curJpy => 'Japanese Yen';

  @override
  String get curCny => 'Chinese Yuan';

  @override
  String get curKrw => 'South Korean Won';

  @override
  String get curThb => 'Thai Baht';

  @override
  String get curSgd => 'Singapore Dollar';

  @override
  String get curAud => 'Australian Dollar';

  @override
  String get curCad => 'Canadian Dollar';

  @override
  String get curChf => 'Swiss Franc';

  @override
  String get curInr => 'Indian Rupee';

  @override
  String get curHkd => 'Hong Kong Dollar';

  @override
  String get curMyr => 'Malaysian Ringgit';

  @override
  String get curIdr => 'Indonesian Rupiah';

  @override
  String get curPhp => 'Philippine Peso';

  @override
  String get curTwd => 'New Taiwan Dollar';

  @override
  String get type => 'Type';

  @override
  String get status => 'Status';

  @override
  String get limitLabel => 'Limit';

  @override
  String get progress => 'Progress';

  @override
  String get currentBalance => 'Current balance';

  @override
  String get createdDate => 'Date created';

  @override
  String csvBudgetTitle(int month, int year) {
    return 'BUDGET FOR $month/$year';
  }

  @override
  String get csvGoalHistory => 'Goal history';

  @override
  String get csvDebtPayments => 'Debt payment history';

  @override
  String get dateFormatHint => 'dd/mm/yyyy';

  @override
  String get seedNoteLunch => 'Lunch';

  @override
  String get seedNoteRide => 'Ride-hailing';

  @override
  String get seedNoteVegetables => 'Vegetables from the market';

  @override
  String get seedNoteTshirt => 'T-shirt';

  @override
  String get seedNoteCoffee => 'Coffee & cake';

  @override
  String get seedNoteElectricity => 'Electricity bill';

  @override
  String get seedNoteRent => 'Rent';

  @override
  String get seedNoteMedicine => 'Medicine';

  @override
  String get seedNoteSalary => 'Monthly salary';

  @override
  String get seedNoteProjectBonus => 'Project bonus';

  @override
  String get seedNoteInterest => 'Savings interest';

  @override
  String get seedGoalTrip => 'Da Lat trip';

  @override
  String get seedGoalInitial => 'Initial amount';

  @override
  String get seedGoalMonthly => 'Saved this month';

  @override
  String get seedPersonMinh => 'Minh (friend)';

  @override
  String get seedDebtLendNote => 'Lent for rent';

  @override
  String get seedDebtPayment => 'First installment';

  @override
  String get seedPersonLan => 'Lan (older sister)';

  @override
  String get seedDebtBorrowNote => 'Borrowed to buy a bicycle';
}
