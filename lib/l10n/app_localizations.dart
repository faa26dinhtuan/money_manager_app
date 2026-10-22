import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'Money Manager'**
  String get appName;

  /// No description provided for @overview.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get overview;

  /// No description provided for @transactions.
  ///
  /// In vi, this message translates to:
  /// **'Sổ giao dịch'**
  String get transactions;

  /// No description provided for @categories.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get categories;

  /// No description provided for @wallet.
  ///
  /// In vi, this message translates to:
  /// **'Ví tiền'**
  String get wallet;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @add.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @no.
  ///
  /// In vi, this message translates to:
  /// **'Không'**
  String get no;

  /// No description provided for @done.
  ///
  /// In vi, this message translates to:
  /// **'Xong'**
  String get done;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @clearAll.
  ///
  /// In vi, this message translates to:
  /// **'Xóa hết'**
  String get clearAll;

  /// No description provided for @continueText.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get continueText;

  /// No description provided for @start.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu'**
  String get start;

  /// No description provided for @other.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get other;

  /// No description provided for @history.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get history;

  /// No description provided for @note.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get note;

  /// No description provided for @date.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get date;

  /// No description provided for @amount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get category;

  /// No description provided for @icon.
  ///
  /// In vi, this message translates to:
  /// **'Biểu tượng'**
  String get icon;

  /// No description provided for @color.
  ///
  /// In vi, this message translates to:
  /// **'Màu sắc'**
  String get color;

  /// No description provided for @balance.
  ///
  /// In vi, this message translates to:
  /// **'Số dư'**
  String get balance;

  /// No description provided for @balanceUpper.
  ///
  /// In vi, this message translates to:
  /// **'SỐ DƯ'**
  String get balanceUpper;

  /// No description provided for @totalBalance.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số dư'**
  String get totalBalance;

  /// No description provided for @initialBalance.
  ///
  /// In vi, this message translates to:
  /// **'Số dư ban đầu'**
  String get initialBalance;

  /// No description provided for @enterAmount.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số tiền'**
  String get enterAmount;

  /// No description provided for @expense.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập'**
  String get income;

  /// No description provided for @expenseUpper.
  ///
  /// In vi, this message translates to:
  /// **'CHI TIÊU'**
  String get expenseUpper;

  /// No description provided for @incomeUpper.
  ///
  /// In vi, this message translates to:
  /// **'THU NHẬP'**
  String get incomeUpper;

  /// No description provided for @spent.
  ///
  /// In vi, this message translates to:
  /// **'Đã chi'**
  String get spent;

  /// No description provided for @received.
  ///
  /// In vi, this message translates to:
  /// **'Đã thu'**
  String get received;

  /// No description provided for @incomeSummary.
  ///
  /// In vi, this message translates to:
  /// **'Thu'**
  String get incomeSummary;

  /// No description provided for @expenseSummary.
  ///
  /// In vi, this message translates to:
  /// **'Chi'**
  String get expenseSummary;

  /// No description provided for @difference.
  ///
  /// In vi, this message translates to:
  /// **'Chênh lệch'**
  String get difference;

  /// No description provided for @remaining.
  ///
  /// In vi, this message translates to:
  /// **'Còn lại'**
  String get remaining;

  /// No description provided for @exceeded.
  ///
  /// In vi, this message translates to:
  /// **'Đã vượt ngân sách'**
  String get exceeded;

  /// No description provided for @day.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get day;

  /// No description provided for @week.
  ///
  /// In vi, this message translates to:
  /// **'Tuần'**
  String get week;

  /// No description provided for @month.
  ///
  /// In vi, this message translates to:
  /// **'Tháng'**
  String get month;

  /// No description provided for @year.
  ///
  /// In vi, this message translates to:
  /// **'Năm'**
  String get year;

  /// No description provided for @customPeriod.
  ///
  /// In vi, this message translates to:
  /// **'Kỳ'**
  String get customPeriod;

  /// No description provided for @today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// No description provided for @selectDateRange.
  ///
  /// In vi, this message translates to:
  /// **'Chọn khoảng thời gian'**
  String get selectDateRange;

  /// No description provided for @startDate.
  ///
  /// In vi, this message translates to:
  /// **'Từ ngày'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In vi, this message translates to:
  /// **'Đến ngày'**
  String get endDate;

  /// No description provided for @invalidDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày không hợp lệ'**
  String get invalidDate;

  /// No description provided for @mustBeAfterStartDate.
  ///
  /// In vi, this message translates to:
  /// **'Phải sau ngày bắt đầu'**
  String get mustBeAfterStartDate;

  /// No description provided for @monthLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tháng {month}, {year}'**
  String monthLabel(int month, int year);

  /// No description provided for @yearLabel.
  ///
  /// In vi, this message translates to:
  /// **'Năm {year}'**
  String yearLabel(int year);

  /// No description provided for @searchCategoryOrNote.
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo danh mục hoặc ghi chú'**
  String get searchCategoryOrNote;

  /// No description provided for @noTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giao dịch'**
  String get noTransactions;

  /// No description provided for @noTransactionsFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy giao dịch'**
  String get noTransactionsFound;

  /// No description provided for @noTransactionsInRange.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giao dịch trong khoảng này'**
  String get noTransactionsInRange;

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa giao dịch?'**
  String get deleteTransactionTitle;

  /// No description provided for @deleteTransactionMessage.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch này sẽ bị xóa khỏi danh sách.'**
  String get deleteTransactionMessage;

  /// No description provided for @deleteTransactionPermanent.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch này sẽ bị xóa và không thể khôi phục.'**
  String get deleteTransactionPermanent;

  /// No description provided for @editTransaction.
  ///
  /// In vi, this message translates to:
  /// **'Sửa giao dịch'**
  String get editTransaction;

  /// No description provided for @addTransaction.
  ///
  /// In vi, this message translates to:
  /// **'Thêm giao dịch'**
  String get addTransaction;

  /// No description provided for @deleteTransaction.
  ///
  /// In vi, this message translates to:
  /// **'Xóa giao dịch'**
  String get deleteTransaction;

  /// No description provided for @transactionCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} giao dịch'**
  String transactionCount(int count);

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập số tiền'**
  String get pleaseEnterAmount;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn danh mục'**
  String get pleaseSelectCategory;

  /// No description provided for @budgetExceeded.
  ///
  /// In vi, this message translates to:
  /// **'Đã vượt ngân sách \"{name}\" {amount}'**
  String budgetExceeded(String name, String amount);

  /// No description provided for @budgetWarning.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách \"{name}\" đã dùng {percent}, còn lại {remaining}'**
  String budgetWarning(String name, String percent, String remaining);

  /// No description provided for @autoAddedRecurring.
  ///
  /// In vi, this message translates to:
  /// **'Đã tự động thêm {count} giao dịch định kỳ'**
  String autoAddedRecurring(int count);

  /// No description provided for @myWallets.
  ///
  /// In vi, this message translates to:
  /// **'Ví của tôi'**
  String get myWallets;

  /// No description provided for @addWallet.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ví'**
  String get addWallet;

  /// No description provided for @editWallet.
  ///
  /// In vi, this message translates to:
  /// **'Sửa ví'**
  String get editWallet;

  /// No description provided for @deleteWallet.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ví'**
  String get deleteWallet;

  /// No description provided for @walletName.
  ///
  /// In vi, this message translates to:
  /// **'Tên ví'**
  String get walletName;

  /// No description provided for @walletCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} ví'**
  String walletCount(int count);

  /// No description provided for @allWallets.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả ví'**
  String get allWallets;

  /// No description provided for @selectWallet.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ví'**
  String get selectWallet;

  /// No description provided for @noWalletAttached.
  ///
  /// In vi, this message translates to:
  /// **'Không gắn ví'**
  String get noWalletAttached;

  /// No description provided for @pleaseEnterWalletName.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên ví'**
  String get pleaseEnterWalletName;

  /// No description provided for @keepAtLeastOneWallet.
  ///
  /// In vi, this message translates to:
  /// **'Cần giữ lại ít nhất một ví'**
  String get keepAtLeastOneWallet;

  /// No description provided for @deleteWalletTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ví?'**
  String get deleteWalletTitle;

  /// No description provided for @deleteWalletMessageSimple.
  ///
  /// In vi, this message translates to:
  /// **'Ví \"{name}\" sẽ bị xóa.'**
  String deleteWalletMessageSimple(String name);

  /// No description provided for @deleteWalletMessageWithTx.
  ///
  /// In vi, this message translates to:
  /// **'Ví \"{name}\" và {count} giao dịch trong ví này sẽ bị xóa.'**
  String deleteWalletMessageWithTx(String name, int count);

  /// No description provided for @deleteWalletLinkedNotice.
  ///
  /// In vi, this message translates to:
  /// **' {count} khoản ở mục tiêu và sổ nợ liên quan sẽ được giữ lại nhưng không còn gắn với ví.'**
  String deleteWalletLinkedNotice(int count);

  /// No description provided for @manageWalletsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo và quản lý các ví của bạn'**
  String get manageWalletsSubtitle;

  /// No description provided for @cashWallet.
  ///
  /// In vi, this message translates to:
  /// **'Tiền mặt'**
  String get cashWallet;

  /// No description provided for @bankWallet.
  ///
  /// In vi, this message translates to:
  /// **'Ngân hàng'**
  String get bankWallet;

  /// No description provided for @eWallet.
  ///
  /// In vi, this message translates to:
  /// **'Ví điện tử'**
  String get eWallet;

  /// No description provided for @createCategory.
  ///
  /// In vi, this message translates to:
  /// **'Tạo danh mục mới'**
  String get createCategory;

  /// No description provided for @editCategory.
  ///
  /// In vi, this message translates to:
  /// **'Sửa danh mục'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In vi, this message translates to:
  /// **'Tên danh mục'**
  String get categoryName;

  /// No description provided for @pleaseEnterCategoryName.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên danh mục'**
  String get pleaseEnterCategoryName;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa danh mục?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategorySimple.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục \"{name}\" sẽ bị xóa.'**
  String deleteCategorySimple(String name);

  /// No description provided for @deleteCategoryWithTx.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục \"{name}\" và {count} giao dịch thuộc danh mục này sẽ bị xóa.'**
  String deleteCategoryWithTx(String name, int count);

  /// No description provided for @catFood.
  ///
  /// In vi, this message translates to:
  /// **'Ăn uống'**
  String get catFood;

  /// No description provided for @catGrocery.
  ///
  /// In vi, this message translates to:
  /// **'Đi chợ'**
  String get catGrocery;

  /// No description provided for @catShop.
  ///
  /// In vi, this message translates to:
  /// **'Mua sắm'**
  String get catShop;

  /// No description provided for @catHome.
  ///
  /// In vi, this message translates to:
  /// **'Nhà cửa'**
  String get catHome;

  /// No description provided for @catTransport.
  ///
  /// In vi, this message translates to:
  /// **'Di chuyển'**
  String get catTransport;

  /// No description provided for @catHealth.
  ///
  /// In vi, this message translates to:
  /// **'Sức khỏe'**
  String get catHealth;

  /// No description provided for @catBill.
  ///
  /// In vi, this message translates to:
  /// **'Hóa đơn'**
  String get catBill;

  /// No description provided for @catEntertain.
  ///
  /// In vi, this message translates to:
  /// **'Giải trí'**
  String get catEntertain;

  /// No description provided for @catSalary.
  ///
  /// In vi, this message translates to:
  /// **'Lương'**
  String get catSalary;

  /// No description provided for @catBonus.
  ///
  /// In vi, this message translates to:
  /// **'Thưởng'**
  String get catBonus;

  /// No description provided for @catInvest.
  ///
  /// In vi, this message translates to:
  /// **'Đầu tư'**
  String get catInvest;

  /// No description provided for @catOtherIncome.
  ///
  /// In vi, this message translates to:
  /// **'Thu khác'**
  String get catOtherIncome;

  /// No description provided for @budget.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách'**
  String get budget;

  /// No description provided for @budgetByCategory.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách theo danh mục'**
  String get budgetByCategory;

  /// No description provided for @budgetSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Đặt hạn mức chi tiêu mỗi tháng'**
  String get budgetSubtitle;

  /// No description provided for @monthlyLimit.
  ///
  /// In vi, this message translates to:
  /// **'Hạn mức mỗi tháng'**
  String get monthlyLimit;

  /// No description provided for @addBudget.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ngân sách'**
  String get addBudget;

  /// No description provided for @editBudget.
  ///
  /// In vi, this message translates to:
  /// **'Sửa ngân sách'**
  String get editBudget;

  /// No description provided for @deleteBudget.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ngân sách'**
  String get deleteBudget;

  /// No description provided for @deleteBudgetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ngân sách?'**
  String get deleteBudgetTitle;

  /// No description provided for @deleteBudgetMessage.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách của danh mục \"{name}\" sẽ bị xóa.'**
  String deleteBudgetMessage(String name);

  /// No description provided for @noBudgetsYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có ngân sách nào'**
  String get noBudgetsYet;

  /// No description provided for @allCategoriesHaveBudgets.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả danh mục chi tiêu đã có ngân sách'**
  String get allCategoriesHaveBudgets;

  /// No description provided for @pleaseEnterLimit.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập hạn mức'**
  String get pleaseEnterLimit;

  /// No description provided for @canSpendPerDay.
  ///
  /// In vi, this message translates to:
  /// **'Có thể chi {amount}/ngày'**
  String canSpendPerDay(String amount);

  /// No description provided for @outsideBudget.
  ///
  /// In vi, this message translates to:
  /// **'Chi ngoài ngân sách: {amount}'**
  String outsideBudget(String amount);

  /// No description provided for @viewTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Xem giao dịch'**
  String get viewTransactions;

  /// No description provided for @spentOfLimit.
  ///
  /// In vi, this message translates to:
  /// **'Đã chi {amount}'**
  String spentOfLimit(String amount);

  /// No description provided for @limitAmount.
  ///
  /// In vi, this message translates to:
  /// **'Hạn mức {amount}'**
  String limitAmount(String amount);

  /// No description provided for @statusOver.
  ///
  /// In vi, this message translates to:
  /// **'Vượt {amount}'**
  String statusOver(String amount);

  /// No description provided for @statusRemaining.
  ///
  /// In vi, this message translates to:
  /// **'Còn {amount}'**
  String statusRemaining(String amount);

  /// No description provided for @goals.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu kiếm tiền'**
  String get goals;

  /// No description provided for @goalsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tiết kiệm cho kế hoạch của bạn'**
  String get goalsSubtitle;

  /// No description provided for @addGoal.
  ///
  /// In vi, this message translates to:
  /// **'Thêm mục tiêu'**
  String get addGoal;

  /// No description provided for @editGoal.
  ///
  /// In vi, this message translates to:
  /// **'Sửa mục tiêu'**
  String get editGoal;

  /// No description provided for @deleteGoal.
  ///
  /// In vi, this message translates to:
  /// **'Xóa mục tiêu'**
  String get deleteGoal;

  /// No description provided for @deleteGoalTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa mục tiêu?'**
  String get deleteGoalTitle;

  /// No description provided for @deleteGoalMessage.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu \"{name}\" và toàn bộ lịch sử sẽ bị xóa.'**
  String deleteGoalMessage(String name);

  /// No description provided for @goalName.
  ///
  /// In vi, this message translates to:
  /// **'Tên mục tiêu'**
  String get goalName;

  /// No description provided for @targetAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền mục tiêu'**
  String get targetAmount;

  /// No description provided for @totalSaved.
  ///
  /// In vi, this message translates to:
  /// **'Tổng đã tiết kiệm'**
  String get totalSaved;

  /// No description provided for @savedLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đã tiết kiệm'**
  String get savedLabel;

  /// No description provided for @targetLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu {amount}'**
  String targetLabel(String amount);

  /// No description provided for @stillNeeded.
  ///
  /// In vi, this message translates to:
  /// **'Còn thiếu {amount}'**
  String stillNeeded(String amount);

  /// No description provided for @deadline.
  ///
  /// In vi, this message translates to:
  /// **'Hạn hoàn thành'**
  String get deadline;

  /// No description provided for @noDeadline.
  ///
  /// In vi, this message translates to:
  /// **'Không giới hạn thời gian'**
  String get noDeadline;

  /// No description provided for @activeGoalsCount.
  ///
  /// In vi, this message translates to:
  /// **'Đang thực hiện ({count})'**
  String activeGoalsCount(int count);

  /// No description provided for @doneGoalsCount.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành ({count})'**
  String doneGoalsCount(int count);

  /// No description provided for @noGoalsYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có mục tiêu nào'**
  String get noGoalsYet;

  /// No description provided for @noGoalsCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có mục tiêu nào hoàn thành'**
  String get noGoalsCompleted;

  /// No description provided for @noGoalsActive.
  ///
  /// In vi, this message translates to:
  /// **'Không có mục tiêu đang thực hiện'**
  String get noGoalsActive;

  /// No description provided for @goalsCompletedCount.
  ///
  /// In vi, this message translates to:
  /// **'{done}/{total} hoàn thành'**
  String goalsCompletedCount(int done, int total);

  /// No description provided for @deposit.
  ///
  /// In vi, this message translates to:
  /// **'Nạp tiền'**
  String get deposit;

  /// No description provided for @withdraw.
  ///
  /// In vi, this message translates to:
  /// **'Rút tiền'**
  String get withdraw;

  /// No description provided for @depositAction.
  ///
  /// In vi, this message translates to:
  /// **'Nạp tiền vào mục tiêu'**
  String get depositAction;

  /// No description provided for @withdrawAction.
  ///
  /// In vi, this message translates to:
  /// **'Rút tiền từ mục tiêu'**
  String get withdrawAction;

  /// No description provided for @congratsGoalCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Chúc mừng! Bạn đã hoàn thành mục tiêu \"{name}\"'**
  String congratsGoalCompleted(String name);

  /// No description provided for @pleaseEnterGoalName.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên mục tiêu'**
  String get pleaseEnterGoalName;

  /// No description provided for @pleaseEnterTarget.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập số tiền mục tiêu'**
  String get pleaseEnterTarget;

  /// No description provided for @deadlineOptional.
  ///
  /// In vi, this message translates to:
  /// **'Hạn hoàn thành (không bắt buộc)'**
  String get deadlineOptional;

  /// No description provided for @initialDeposit.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền nạp ban đầu'**
  String get initialDeposit;

  /// No description provided for @selectDeadline.
  ///
  /// In vi, this message translates to:
  /// **'Chọn hạn'**
  String get selectDeadline;

  /// No description provided for @daysRemaining.
  ///
  /// In vi, this message translates to:
  /// **'Còn {days} ngày'**
  String daysRemaining(int days);

  /// No description provided for @dueToday.
  ///
  /// In vi, this message translates to:
  /// **'Hết hạn hôm nay'**
  String get dueToday;

  /// No description provided for @daysOverdue.
  ///
  /// In vi, this message translates to:
  /// **'Quá hạn {days} ngày'**
  String daysOverdue(int days);

  /// No description provided for @completed.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn thành'**
  String get completed;

  /// No description provided for @deleteEntryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa giao dịch này?'**
  String get deleteEntryTitle;

  /// No description provided for @deleteEntryMessage.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền mục tiêu sẽ được tính lại.'**
  String get deleteEntryMessage;

  /// No description provided for @debts.
  ///
  /// In vi, this message translates to:
  /// **'Sổ nợ'**
  String get debts;

  /// No description provided for @debtsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi các khoản cho vay và đi vay'**
  String get debtsSubtitle;

  /// No description provided for @addDebt.
  ///
  /// In vi, this message translates to:
  /// **'Thêm khoản nợ'**
  String get addDebt;

  /// No description provided for @editDebt.
  ///
  /// In vi, this message translates to:
  /// **'Sửa khoản nợ'**
  String get editDebt;

  /// No description provided for @deleteDebt.
  ///
  /// In vi, this message translates to:
  /// **'Xóa khoản nợ'**
  String get deleteDebt;

  /// No description provided for @deleteDebtTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa khoản nợ?'**
  String get deleteDebtTitle;

  /// No description provided for @deleteDebtMessage.
  ///
  /// In vi, this message translates to:
  /// **'Khoản nợ này và toàn bộ lịch sử trả sẽ bị xóa.'**
  String get deleteDebtMessage;

  /// No description provided for @lend.
  ///
  /// In vi, this message translates to:
  /// **'Cho vay'**
  String get lend;

  /// No description provided for @borrow.
  ///
  /// In vi, this message translates to:
  /// **'Đi vay'**
  String get borrow;

  /// No description provided for @collectDebt.
  ///
  /// In vi, this message translates to:
  /// **'Thu nợ'**
  String get collectDebt;

  /// No description provided for @payDebt.
  ///
  /// In vi, this message translates to:
  /// **'Trả nợ'**
  String get payDebt;

  /// No description provided for @collected.
  ///
  /// In vi, this message translates to:
  /// **'Đã thu'**
  String get collected;

  /// No description provided for @paid.
  ///
  /// In vi, this message translates to:
  /// **'Đã trả'**
  String get paid;

  /// No description provided for @principalAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền gốc'**
  String get principalAmount;

  /// No description provided for @person.
  ///
  /// In vi, this message translates to:
  /// **'Người liên quan'**
  String get person;

  /// No description provided for @personHint.
  ///
  /// In vi, this message translates to:
  /// **'Tên người vay / cho vay'**
  String get personHint;

  /// No description provided for @pleaseEnterPerson.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên người liên quan'**
  String get pleaseEnterPerson;

  /// No description provided for @openDebtsCount.
  ///
  /// In vi, this message translates to:
  /// **'Chưa xong ({count})'**
  String openDebtsCount(int count);

  /// No description provided for @settledDebtsCount.
  ///
  /// In vi, this message translates to:
  /// **'Đã tất toán ({count})'**
  String settledDebtsCount(int count);

  /// No description provided for @lendCount.
  ///
  /// In vi, this message translates to:
  /// **'Cho vay ({count})'**
  String lendCount(int count);

  /// No description provided for @borrowCount.
  ///
  /// In vi, this message translates to:
  /// **'Đi vay ({count})'**
  String borrowCount(int count);

  /// No description provided for @receivable.
  ///
  /// In vi, this message translates to:
  /// **'Cần thu'**
  String get receivable;

  /// No description provided for @payable.
  ///
  /// In vi, this message translates to:
  /// **'Cần trả'**
  String get payable;

  /// No description provided for @overdueCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} khoản quá hạn'**
  String overdueCount(int count);

  /// No description provided for @noSettledDebts.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có khoản nào đã tất toán'**
  String get noSettledDebts;

  /// No description provided for @noLendDebts.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có khoản cho vay nào'**
  String get noLendDebts;

  /// No description provided for @noBorrowDebts.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có khoản đi vay nào'**
  String get noBorrowDebts;

  /// No description provided for @debtSettledNotification.
  ///
  /// In vi, this message translates to:
  /// **'Đã tất toán khoản của \"{person}\"'**
  String debtSettledNotification(String person);

  /// No description provided for @settled.
  ///
  /// In vi, this message translates to:
  /// **'Đã tất toán'**
  String get settled;

  /// No description provided for @dueDate.
  ///
  /// In vi, this message translates to:
  /// **'Hạn trả'**
  String get dueDate;

  /// No description provided for @noDueDate.
  ///
  /// In vi, this message translates to:
  /// **'Không có hạn trả'**
  String get noDueDate;

  /// No description provided for @debtCreatedDate.
  ///
  /// In vi, this message translates to:
  /// **'{type} ngày {date}'**
  String debtCreatedDate(String type, String date);

  /// No description provided for @deletePaymentTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa lần thanh toán?'**
  String get deletePaymentTitle;

  /// No description provided for @deletePaymentMessage.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền còn lại của khoản nợ sẽ được tính lại.'**
  String get deletePaymentMessage;

  /// No description provided for @lendPrincipal.
  ///
  /// In vi, this message translates to:
  /// **'Khoản cho vay'**
  String get lendPrincipal;

  /// No description provided for @borrowPrincipal.
  ///
  /// In vi, this message translates to:
  /// **'Khoản đi vay'**
  String get borrowPrincipal;

  /// No description provided for @repayment.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán nợ'**
  String get repayment;

  /// No description provided for @recurring.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch định kỳ'**
  String get recurring;

  /// No description provided for @recurringSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tự động lặp lại theo chu kỳ'**
  String get recurringSubtitle;

  /// No description provided for @addRecurring.
  ///
  /// In vi, this message translates to:
  /// **'Thêm định kỳ'**
  String get addRecurring;

  /// No description provided for @editRecurring.
  ///
  /// In vi, this message translates to:
  /// **'Sửa định kỳ'**
  String get editRecurring;

  /// No description provided for @deleteRecurring.
  ///
  /// In vi, this message translates to:
  /// **'Xóa định kỳ'**
  String get deleteRecurring;

  /// No description provided for @deleteRecurringTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa định kỳ?'**
  String get deleteRecurringTitle;

  /// No description provided for @deleteRecurringMessage.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch định kỳ này sẽ bị xóa và không còn tự tạo nữa.'**
  String get deleteRecurringMessage;

  /// No description provided for @frequency.
  ///
  /// In vi, this message translates to:
  /// **'Tần suất'**
  String get frequency;

  /// No description provided for @freqDaily.
  ///
  /// In vi, this message translates to:
  /// **'Hằng ngày'**
  String get freqDaily;

  /// No description provided for @freqWeekly.
  ///
  /// In vi, this message translates to:
  /// **'Hằng tuần'**
  String get freqWeekly;

  /// No description provided for @freqMonthly.
  ///
  /// In vi, this message translates to:
  /// **'Hằng tháng'**
  String get freqMonthly;

  /// No description provided for @freqYearly.
  ///
  /// In vi, this message translates to:
  /// **'Hằng năm'**
  String get freqYearly;

  /// No description provided for @nextDate.
  ///
  /// In vi, this message translates to:
  /// **'Lần tiếp theo'**
  String get nextDate;

  /// No description provided for @startDateLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngày bắt đầu'**
  String get startDateLabel;

  /// No description provided for @endDateOptional.
  ///
  /// In vi, this message translates to:
  /// **'Ngày kết thúc (không bắt buộc)'**
  String get endDateOptional;

  /// No description provided for @noRecurringYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giao dịch định kỳ nào'**
  String get noRecurringYet;

  /// No description provided for @monthlyAvgExpense.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính chi mỗi tháng'**
  String get monthlyAvgExpense;

  /// No description provided for @monthlyAvgIncome.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính thu mỗi tháng'**
  String get monthlyAvgIncome;

  /// No description provided for @active.
  ///
  /// In vi, this message translates to:
  /// **'Đang bật'**
  String get active;

  /// No description provided for @paused.
  ///
  /// In vi, this message translates to:
  /// **'Tạm dừng'**
  String get paused;

  /// No description provided for @finished.
  ///
  /// In vi, this message translates to:
  /// **'Đã kết thúc'**
  String get finished;

  /// No description provided for @currencyDefault.
  ///
  /// In vi, this message translates to:
  /// **'Tiền tệ mặc định'**
  String get currencyDefault;

  /// No description provided for @walletCurrency.
  ///
  /// In vi, this message translates to:
  /// **'Tiền tệ của ví'**
  String get walletCurrency;

  /// No description provided for @useExistingWallets.
  ///
  /// In vi, this message translates to:
  /// **'Dùng ví hiện có'**
  String get useExistingWallets;

  /// No description provided for @currencyCodeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tiền tệ'**
  String get currencyCodeLabel;

  /// No description provided for @currencyDefaultNotice.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tiền tệ mặc định để hiển thị và nhập số tiền. Việc này không quy đổi số dư trong ví.'**
  String get currencyDefaultNotice;

  /// No description provided for @currencyConverter.
  ///
  /// In vi, this message translates to:
  /// **'Đổi tiền tệ'**
  String get currencyConverter;

  /// No description provided for @currencyConverterSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Quy đổi theo tỷ giá'**
  String get currencyConverterSubtitle;

  /// No description provided for @theme.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @langSystem.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get langSystem;

  /// No description provided for @langVi.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get langVi;

  /// No description provided for @langEn.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @backupAndRestore.
  ///
  /// In vi, this message translates to:
  /// **'Sao lưu & khôi phục'**
  String get backupAndRestore;

  /// No description provided for @exportData.
  ///
  /// In vi, this message translates to:
  /// **'Xuất dữ liệu'**
  String get exportData;

  /// No description provided for @exportCsv.
  ///
  /// In vi, this message translates to:
  /// **'Xuất ra file CSV'**
  String get exportCsv;

  /// No description provided for @about.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản {version}'**
  String appVersion(String version);

  /// No description provided for @backupData.
  ///
  /// In vi, this message translates to:
  /// **'Sao lưu dữ liệu'**
  String get backupData;

  /// No description provided for @restoreData.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục dữ liệu'**
  String get restoreData;

  /// No description provided for @backupCopied.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép bản sao lưu. Hãy dán vào nơi an toàn để lưu lại'**
  String get backupCopied;

  /// No description provided for @restoreNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy bản sao lưu hợp lệ trong bộ nhớ tạm'**
  String get restoreNotFound;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục dữ liệu?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmMessage.
  ///
  /// In vi, this message translates to:
  /// **'Toàn bộ dữ liệu hiện tại sẽ bị thay thế.'**
  String get restoreConfirmMessage;

  /// No description provided for @restoreSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã khôi phục dữ liệu'**
  String get restoreSuccess;

  /// No description provided for @convertCurrencyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đổi sang {code}'**
  String convertCurrencyTitle(String code);

  /// No description provided for @convertCurrencyPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Dùng hoặc tạo ví bằng {currency} mà không quy đổi, hay quy đổi dữ liệu hiện tại?'**
  String convertCurrencyPrompt(String currency);

  /// No description provided for @displayOnly.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ đổi hiển thị'**
  String get displayOnly;

  /// No description provided for @convertAll.
  ///
  /// In vi, this message translates to:
  /// **'Quy đổi tất cả'**
  String get convertAll;

  /// No description provided for @selectWalletsToConvert.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ví muốn quy đổi sang loại tiền mới'**
  String get selectWalletsToConvert;

  /// No description provided for @convertSelectedWallets.
  ///
  /// In vi, this message translates to:
  /// **'Quy đổi ví đã chọn'**
  String get convertSelectedWallets;

  /// No description provided for @convertWallets.
  ///
  /// In vi, this message translates to:
  /// **'Quy đổi ví'**
  String get convertWallets;

  /// No description provided for @walletConversionSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn loại tiền nguồn và đích ở trên, sau đó chọn ví muốn quy đổi.'**
  String get walletConversionSubtitle;

  /// No description provided for @filterCurrencies.
  ///
  /// In vi, this message translates to:
  /// **'Lọc ví theo tiền tệ'**
  String get filterCurrencies;

  /// No description provided for @showAllCurrencies.
  ///
  /// In vi, this message translates to:
  /// **'Hiện tất cả tiền tệ'**
  String get showAllCurrencies;

  /// No description provided for @walletsMustShareCurrency.
  ///
  /// In vi, this message translates to:
  /// **'Có thể chọn nhiều ví, nhưng các ví phải cùng loại tiền tệ.'**
  String get walletsMustShareCurrency;

  /// No description provided for @selectTargetCurrency.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tiền tệ muốn quy đổi sang'**
  String get selectTargetCurrency;

  /// No description provided for @changeDefaultCurrency.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển sang tiền tệ này'**
  String get changeDefaultCurrency;

  /// No description provided for @askAddWalletForCurrency.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có muốn tạo ví mới cho {currency} không?'**
  String askAddWalletForCurrency(String currency);

  /// No description provided for @currencyConvertLinkedNotice.
  ///
  /// In vi, this message translates to:
  /// **'Nếu mục tiêu hoặc khoản nợ liên kết nhiều ví, các ví đó cũng sẽ được quy đổi cùng để giữ dữ liệu nhất quán.'**
  String get currencyConvertLinkedNotice;

  /// No description provided for @backupSavedConfirmation.
  ///
  /// In vi, this message translates to:
  /// **'Tôi đã lưu bản sao lưu ở nơi an toàn'**
  String get backupSavedConfirmation;

  /// No description provided for @ratesUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật tỷ giá'**
  String get ratesUpdated;

  /// No description provided for @ratesOffline.
  ///
  /// In vi, this message translates to:
  /// **'Không có kết nối, đang dùng tỷ giá đã lưu'**
  String get ratesOffline;

  /// No description provided for @welcome.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng bạn!'**
  String get welcome;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Hãy tạo ví đầu tiên để bắt đầu quản lý chi tiêu'**
  String get welcomeSubtitle;

  /// No description provided for @quickSuggestions.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý nhanh'**
  String get quickSuggestions;

  /// No description provided for @createWalletAndStart.
  ///
  /// In vi, this message translates to:
  /// **'Tạo ví & bắt đầu'**
  String get createWalletAndStart;

  /// No description provided for @introTrackTitle.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi thu chi'**
  String get introTrackTitle;

  /// No description provided for @introTrackDesc.
  ///
  /// In vi, this message translates to:
  /// **'Ghi lại mọi khoản thu và chi, xem biểu đồ theo danh mục để biết tiền của bạn đang đi đâu.'**
  String get introTrackDesc;

  /// No description provided for @introWalletTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý nhiều ví'**
  String get introWalletTitle;

  /// No description provided for @introWalletDesc.
  ///
  /// In vi, this message translates to:
  /// **'Tách riêng tiền mặt, ngân hàng, ví điện tử và xem số dư của từng ví một cách rõ ràng.'**
  String get introWalletDesc;

  /// No description provided for @introBudgetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách & mục tiêu'**
  String get introBudgetTitle;

  /// No description provided for @introBudgetDesc.
  ///
  /// In vi, this message translates to:
  /// **'Đặt hạn mức chi tiêu mỗi tháng, nhận cảnh báo khi sắp vượt và tiết kiệm cho kế hoạch của bạn.'**
  String get introBudgetDesc;

  /// No description provided for @introRecurringTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sổ nợ & giao dịch định kỳ'**
  String get introRecurringTitle;

  /// No description provided for @introRecurringDesc.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi các khoản cho vay, đi vay và để các khoản lặp lại như tiền nhà, lương tự động được ghi.'**
  String get introRecurringDesc;

  /// No description provided for @weekdayMon.
  ///
  /// In vi, this message translates to:
  /// **'T2'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In vi, this message translates to:
  /// **'T3'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In vi, this message translates to:
  /// **'T4'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In vi, this message translates to:
  /// **'T5'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In vi, this message translates to:
  /// **'T6'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In vi, this message translates to:
  /// **'T7'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In vi, this message translates to:
  /// **'CN'**
  String get weekdaySun;

  /// No description provided for @selectCurrency.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tiền tệ'**
  String get selectCurrency;

  /// No description provided for @fromCurrency.
  ///
  /// In vi, this message translates to:
  /// **'Từ'**
  String get fromCurrency;

  /// No description provided for @toCurrency.
  ///
  /// In vi, this message translates to:
  /// **'Sang'**
  String get toCurrency;

  /// No description provided for @refreshRates.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật tỷ giá'**
  String get refreshRates;

  /// No description provided for @selectAll.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tất cả'**
  String get selectAll;

  /// No description provided for @deleteSelectedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa các mục đã chọn?'**
  String get deleteSelectedTitle;

  /// No description provided for @deleteSelectedMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa {count} mục đã chọn không? Thao tác này không thể hoàn tác.'**
  String deleteSelectedMessage(int count);

  /// No description provided for @exportCsvTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xuất ra file CSV'**
  String get exportCsvTitle;

  /// No description provided for @splashTagline.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý chi tiêu cá nhân'**
  String get splashTagline;

  /// No description provided for @amountCannotBeLessThanPaid.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền không được nhỏ hơn số đã thanh toán'**
  String get amountCannotBeLessThanPaid;

  /// No description provided for @exceedsRemainingAmount.
  ///
  /// In vi, this message translates to:
  /// **'Vượt quá số tiền còn lại'**
  String get exceedsRemainingAmount;

  /// No description provided for @collectAll.
  ///
  /// In vi, this message translates to:
  /// **'Thu hết: {amount}'**
  String collectAll(String amount);

  /// No description provided for @payAll.
  ///
  /// In vi, this message translates to:
  /// **'Trả hết: {amount}'**
  String payAll(String amount);

  /// No description provided for @creditToWallet.
  ///
  /// In vi, this message translates to:
  /// **'Cộng vào ví'**
  String get creditToWallet;

  /// No description provided for @debitFromWallet.
  ///
  /// In vi, this message translates to:
  /// **'Trừ từ ví'**
  String get debitFromWallet;

  /// No description provided for @walletSourceLend.
  ///
  /// In vi, this message translates to:
  /// **'Lấy tiền từ ví'**
  String get walletSourceLend;

  /// No description provided for @walletSourceBorrow.
  ///
  /// In vi, this message translates to:
  /// **'Nhận tiền vào ví'**
  String get walletSourceBorrow;

  /// No description provided for @debtDateLend.
  ///
  /// In vi, this message translates to:
  /// **'Ngày cho vay'**
  String get debtDateLend;

  /// No description provided for @debtDateBorrow.
  ///
  /// In vi, this message translates to:
  /// **'Ngày vay'**
  String get debtDateBorrow;

  /// No description provided for @borrower.
  ///
  /// In vi, this message translates to:
  /// **'Người vay'**
  String get borrower;

  /// No description provided for @lender.
  ///
  /// In vi, this message translates to:
  /// **'Người cho vay'**
  String get lender;

  /// No description provided for @backupExplainTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng này để làm gì?'**
  String get backupExplainTitle;

  /// No description provided for @backupExplainBody.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu chỉ nằm trên máy này. Nếu bạn đổi điện thoại hoặc xóa app, dữ liệu sẽ mất.\n\nSao lưu: tạo một đoạn mã chứa toàn bộ dữ liệu và chép vào bộ nhớ tạm. Hãy dán nó vào Ghi chú hoặc email để lưu lại.\n\nKhôi phục: chép lại đoạn mã đó rồi bấm Khôi phục để đưa dữ liệu về.'**
  String get backupExplainBody;

  /// No description provided for @exportExplainBody.
  ///
  /// In vi, this message translates to:
  /// **'CSV là file bảng tính dạng văn bản đơn giản. Chọn các phần dữ liệu muốn xuất bên dưới. Bạn có thể mở bằng Excel hoặc Google Sheets để xem, lọc và tính toán.\n\nKhác với Sao lưu, file này dùng để xem và phân tích dữ liệu, không dùng để khôi phục lại vào app.'**
  String get exportExplainBody;

  /// No description provided for @restoreFromClipboard.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục từ bộ nhớ tạm'**
  String get restoreFromClipboard;

  /// No description provided for @depositAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền nạp'**
  String get depositAmount;

  /// No description provided for @withdrawAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền rút'**
  String get withdrawAmount;

  /// No description provided for @exceedsSavedAmount.
  ///
  /// In vi, this message translates to:
  /// **'Vượt quá số tiền đã tiết kiệm'**
  String get exceedsSavedAmount;

  /// No description provided for @reachGoalAmount.
  ///
  /// In vi, this message translates to:
  /// **'Đủ mục tiêu: {amount}'**
  String reachGoalAmount(String amount);

  /// No description provided for @walletBalanceLabel.
  ///
  /// In vi, this message translates to:
  /// **'Số dư ví: {amount}'**
  String walletBalanceLabel(String amount);

  /// No description provided for @deletePaymentConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa lần thanh toán?'**
  String get deletePaymentConfirmTitle;

  /// No description provided for @deletePaymentConfirmMessage.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền còn lại của khoản nợ sẽ được tính lại.'**
  String get deletePaymentConfirmMessage;

  /// No description provided for @lentItem.
  ///
  /// In vi, this message translates to:
  /// **'Khoản cho vay'**
  String get lentItem;

  /// No description provided for @borrowedItem.
  ///
  /// In vi, this message translates to:
  /// **'Khoản đi vay'**
  String get borrowedItem;

  /// No description provided for @duePrefix.
  ///
  /// In vi, this message translates to:
  /// **'Hạn trả {date}'**
  String duePrefix(String date);

  /// No description provided for @exportSectionTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch'**
  String get exportSectionTransactions;

  /// No description provided for @exportSectionWallets.
  ///
  /// In vi, this message translates to:
  /// **'Ví tiền'**
  String get exportSectionWallets;

  /// No description provided for @exportSectionBudgets.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách tháng này'**
  String get exportSectionBudgets;

  /// No description provided for @exportSectionGoals.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu tiết kiệm'**
  String get exportSectionGoals;

  /// No description provided for @exportSectionDebts.
  ///
  /// In vi, this message translates to:
  /// **'Sổ nợ'**
  String get exportSectionDebts;

  /// No description provided for @exportSectionRecurrings.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch định kỳ'**
  String get exportSectionRecurrings;

  /// No description provided for @defaultRatesWarning.
  ///
  /// In vi, this message translates to:
  /// **'Đang dùng tỷ giá mặc định có sẵn trong app, có thể đã cũ. Kết nối mạng và bấm cập nhật để lấy tỷ giá mới nhất.'**
  String get defaultRatesWarning;

  /// No description provided for @lastUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật lần cuối: {time}'**
  String lastUpdated(String time);

  /// No description provided for @currencyDisclaimer.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ giá cung cấp bởi ExchangeRate-API (exchangerate-api.com), cập nhật mỗi ngày, chỉ mang tính tham khảo.'**
  String get currencyDisclaimer;

  /// No description provided for @currencyConvertWarning.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch, mục tiêu, khoản nợ và định kỳ gắn với ví được chọn sẽ được quy đổi. Ngân sách không gắn với ví sẽ giữ nguyên tiền tệ.'**
  String get currencyConvertWarning;

  /// No description provided for @manageWallets.
  ///
  /// In vi, this message translates to:
  /// **'Ví tiền'**
  String get manageWallets;

  /// No description provided for @manageWalletsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Tạo và quản lý các ví của bạn'**
  String get manageWalletsDesc;

  /// No description provided for @budgetDesc.
  ///
  /// In vi, this message translates to:
  /// **'Đặt hạn mức chi tiêu mỗi tháng'**
  String get budgetDesc;

  /// No description provided for @goalsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Tiết kiệm cho kế hoạch của bạn'**
  String get goalsDesc;

  /// No description provided for @debtsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi các khoản cho vay và đi vay'**
  String get debtsDesc;

  /// No description provided for @recurringDesc.
  ///
  /// In vi, this message translates to:
  /// **'Tự động lặp lại theo chu kỳ'**
  String get recurringDesc;

  /// No description provided for @initialAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền đã có'**
  String get initialAmount;

  /// No description provided for @initialAmountOptional.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền đã có (không bắt buộc)'**
  String get initialAmountOptional;

  /// No description provided for @noEndDate.
  ///
  /// In vi, this message translates to:
  /// **'Không giới hạn'**
  String get noEndDate;

  /// No description provided for @repeatCycle.
  ///
  /// In vi, this message translates to:
  /// **'Chu kỳ lặp'**
  String get repeatCycle;

  /// No description provided for @startsOn.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu từ ngày'**
  String get startsOn;

  /// No description provided for @endsOn.
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc (không bắt buộc)'**
  String get endsOn;

  /// No description provided for @deleteRecurringConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Các giao dịch đã được tạo trước đó vẫn được giữ lại.'**
  String get deleteRecurringConfirm;

  /// No description provided for @curVnd.
  ///
  /// In vi, this message translates to:
  /// **'Đồng Việt Nam'**
  String get curVnd;

  /// No description provided for @curUsd.
  ///
  /// In vi, this message translates to:
  /// **'Đô la Mỹ'**
  String get curUsd;

  /// No description provided for @curEur.
  ///
  /// In vi, this message translates to:
  /// **'Euro'**
  String get curEur;

  /// No description provided for @curGbp.
  ///
  /// In vi, this message translates to:
  /// **'Bảng Anh'**
  String get curGbp;

  /// No description provided for @curJpy.
  ///
  /// In vi, this message translates to:
  /// **'Yên Nhật'**
  String get curJpy;

  /// No description provided for @curCny.
  ///
  /// In vi, this message translates to:
  /// **'Nhân dân tệ'**
  String get curCny;

  /// No description provided for @curKrw.
  ///
  /// In vi, this message translates to:
  /// **'Won Hàn Quốc'**
  String get curKrw;

  /// No description provided for @curThb.
  ///
  /// In vi, this message translates to:
  /// **'Baht Thái'**
  String get curThb;

  /// No description provided for @curSgd.
  ///
  /// In vi, this message translates to:
  /// **'Đô la Singapore'**
  String get curSgd;

  /// No description provided for @curAud.
  ///
  /// In vi, this message translates to:
  /// **'Đô la Úc'**
  String get curAud;

  /// No description provided for @curCad.
  ///
  /// In vi, this message translates to:
  /// **'Đô la Canada'**
  String get curCad;

  /// No description provided for @curChf.
  ///
  /// In vi, this message translates to:
  /// **'Franc Thụy Sĩ'**
  String get curChf;

  /// No description provided for @curInr.
  ///
  /// In vi, this message translates to:
  /// **'Rupee Ấn Độ'**
  String get curInr;

  /// No description provided for @curHkd.
  ///
  /// In vi, this message translates to:
  /// **'Đô la Hồng Kông'**
  String get curHkd;

  /// No description provided for @curMyr.
  ///
  /// In vi, this message translates to:
  /// **'Ringgit Malaysia'**
  String get curMyr;

  /// No description provided for @curIdr.
  ///
  /// In vi, this message translates to:
  /// **'Rupiah Indonesia'**
  String get curIdr;

  /// No description provided for @curPhp.
  ///
  /// In vi, this message translates to:
  /// **'Peso Philippines'**
  String get curPhp;

  /// No description provided for @curTwd.
  ///
  /// In vi, this message translates to:
  /// **'Đô la Đài Loan'**
  String get curTwd;

  /// No description provided for @type.
  ///
  /// In vi, this message translates to:
  /// **'Loại'**
  String get type;

  /// No description provided for @status.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái'**
  String get status;

  /// No description provided for @limitLabel.
  ///
  /// In vi, this message translates to:
  /// **'Hạn mức'**
  String get limitLabel;

  /// No description provided for @progress.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ'**
  String get progress;

  /// No description provided for @currentBalance.
  ///
  /// In vi, this message translates to:
  /// **'Số dư hiện tại'**
  String get currentBalance;

  /// No description provided for @createdDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày phát sinh'**
  String get createdDate;

  /// No description provided for @csvBudgetTitle.
  ///
  /// In vi, this message translates to:
  /// **'NGÂN SÁCH THÁNG {month}/{year}'**
  String csvBudgetTitle(int month, int year);

  /// No description provided for @csvGoalHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử mục tiêu'**
  String get csvGoalHistory;

  /// No description provided for @csvDebtPayments.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử thanh toán nợ'**
  String get csvDebtPayments;

  /// No description provided for @dateFormatHint.
  ///
  /// In vi, this message translates to:
  /// **'dd/mm/yyyy'**
  String get dateFormatHint;

  /// No description provided for @seedNoteLunch.
  ///
  /// In vi, this message translates to:
  /// **'Cơm trưa'**
  String get seedNoteLunch;

  /// No description provided for @seedNoteRide.
  ///
  /// In vi, this message translates to:
  /// **'Grab'**
  String get seedNoteRide;

  /// No description provided for @seedNoteVegetables.
  ///
  /// In vi, this message translates to:
  /// **'Rau củ ở chợ'**
  String get seedNoteVegetables;

  /// No description provided for @seedNoteTshirt.
  ///
  /// In vi, this message translates to:
  /// **'Áo thun'**
  String get seedNoteTshirt;

  /// No description provided for @seedNoteCoffee.
  ///
  /// In vi, this message translates to:
  /// **'Cà phê + bánh'**
  String get seedNoteCoffee;

  /// No description provided for @seedNoteElectricity.
  ///
  /// In vi, this message translates to:
  /// **'Tiền điện'**
  String get seedNoteElectricity;

  /// No description provided for @seedNoteRent.
  ///
  /// In vi, this message translates to:
  /// **'Tiền nhà'**
  String get seedNoteRent;

  /// No description provided for @seedNoteMedicine.
  ///
  /// In vi, this message translates to:
  /// **'Thuốc'**
  String get seedNoteMedicine;

  /// No description provided for @seedNoteSalary.
  ///
  /// In vi, this message translates to:
  /// **'Lương tháng'**
  String get seedNoteSalary;

  /// No description provided for @seedNoteProjectBonus.
  ///
  /// In vi, this message translates to:
  /// **'Thưởng dự án'**
  String get seedNoteProjectBonus;

  /// No description provided for @seedNoteInterest.
  ///
  /// In vi, this message translates to:
  /// **'Lãi tiết kiệm'**
  String get seedNoteInterest;

  /// No description provided for @seedGoalTrip.
  ///
  /// In vi, this message translates to:
  /// **'Du lịch Đà Lạt'**
  String get seedGoalTrip;

  /// No description provided for @seedGoalInitial.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền ban đầu'**
  String get seedGoalInitial;

  /// No description provided for @seedGoalMonthly.
  ///
  /// In vi, this message translates to:
  /// **'Dành dụm tháng này'**
  String get seedGoalMonthly;

  /// No description provided for @seedPersonMinh.
  ///
  /// In vi, this message translates to:
  /// **'Bạn Minh'**
  String get seedPersonMinh;

  /// No description provided for @seedDebtLendNote.
  ///
  /// In vi, this message translates to:
  /// **'Cho mượn đóng tiền trọ'**
  String get seedDebtLendNote;

  /// No description provided for @seedDebtPayment.
  ///
  /// In vi, this message translates to:
  /// **'Trả đợt 1'**
  String get seedDebtPayment;

  /// No description provided for @seedPersonLan.
  ///
  /// In vi, this message translates to:
  /// **'Chị Lan'**
  String get seedPersonLan;

  /// No description provided for @seedDebtBorrowNote.
  ///
  /// In vi, this message translates to:
  /// **'Mượn mua xe đạp'**
  String get seedDebtBorrowNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
