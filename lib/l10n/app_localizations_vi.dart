// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Money Manager';

  @override
  String get overview => 'Tổng quan';

  @override
  String get transactions => 'Sổ giao dịch';

  @override
  String get calendar => 'Lịch';

  @override
  String get previousMonth => 'Tháng trước';

  @override
  String get nextMonth => 'Tháng sau';

  @override
  String get plannedEvent => 'Sự kiện dự kiến';

  @override
  String get plannedEvents => 'Sự kiện dự kiến';

  @override
  String get addPlannedEvent => 'Tạo sự kiện';

  @override
  String get editPlannedEvent => 'Sửa sự kiện';

  @override
  String get plannedEventName => 'Tên sự kiện';

  @override
  String get pleaseEnterEventName => 'Vui lòng nhập tên sự kiện';

  @override
  String get deletePlannedEventTitle => 'Xóa sự kiện dự kiến?';

  @override
  String get deletePlannedEventMessage => 'Sự kiện này sẽ bị xóa khỏi lịch.';

  @override
  String get repeatEvent => 'Lặp lại sự kiện';

  @override
  String get repeatFrequency => 'Tần suất lặp lại';

  @override
  String get deleteThisOccurrence => 'Chỉ xóa ngày này';

  @override
  String get deleteEventSeries => 'Xóa tất cả các lần lặp';

  @override
  String get deleteRecurringEventWarning => 'Chọn phạm vi sự kiện muốn xóa.';

  @override
  String get pleaseSelectWallet => 'Vui lòng chọn ví';

  @override
  String get stopRecurringEventTitle => 'Tắt lặp lại sự kiện?';

  @override
  String get stopRecurringEventMessage =>
      'Giao dịch định kỳ liên kết sẽ bị xóa. Các giao dịch đã được tạo trước đó vẫn được giữ lại.';

  @override
  String get categories => 'Danh mục';

  @override
  String get manageCategories => 'Quản lý danh mục';

  @override
  String get wallet => 'Ví tiền';

  @override
  String get settings => 'Cài đặt';

  @override
  String get add => 'Thêm';

  @override
  String get edit => 'Sửa';

  @override
  String get delete => 'Xóa';

  @override
  String get save => 'Lưu';

  @override
  String get cancel => 'Hủy';

  @override
  String get no => 'Không';

  @override
  String get done => 'Xong';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get clearAll => 'Xóa hết';

  @override
  String get continueText => 'Tiếp tục';

  @override
  String get start => 'Bắt đầu';

  @override
  String get other => 'Khác';

  @override
  String get history => 'Lịch sử';

  @override
  String get note => 'Ghi chú';

  @override
  String get date => 'Ngày';

  @override
  String get amount => 'Số tiền';

  @override
  String get category => 'Danh mục';

  @override
  String get icon => 'Biểu tượng';

  @override
  String get color => 'Màu sắc';

  @override
  String get balance => 'Số dư';

  @override
  String get balanceUpper => 'SỐ DƯ';

  @override
  String get totalBalance => 'Tổng số dư';

  @override
  String get initialBalance => 'Số dư ban đầu';

  @override
  String get enterAmount => 'Nhập số tiền';

  @override
  String get expense => 'Chi tiêu';

  @override
  String get income => 'Thu nhập';

  @override
  String get expenseUpper => 'CHI TIÊU';

  @override
  String get incomeUpper => 'THU NHẬP';

  @override
  String get spent => 'Đã chi';

  @override
  String get received => 'Đã thu';

  @override
  String get incomeSummary => 'Thu';

  @override
  String get expenseSummary => 'Chi';

  @override
  String get difference => 'Chênh lệch';

  @override
  String get remaining => 'Còn lại';

  @override
  String get exceeded => 'Đã vượt ngân sách';

  @override
  String get day => 'Ngày';

  @override
  String get week => 'Tuần';

  @override
  String get month => 'Tháng';

  @override
  String get year => 'Năm';

  @override
  String get customPeriod => 'Kỳ';

  @override
  String get today => 'Hôm nay';

  @override
  String get selectDateRange => 'Chọn khoảng thời gian';

  @override
  String get startDate => 'Từ ngày';

  @override
  String get endDate => 'Đến ngày';

  @override
  String get invalidDate => 'Ngày không hợp lệ';

  @override
  String get mustBeAfterStartDate => 'Phải sau ngày bắt đầu';

  @override
  String monthLabel(int month, int year) {
    return 'Tháng $month, $year';
  }

  @override
  String yearLabel(int year) {
    return 'Năm $year';
  }

  @override
  String get searchCategoryOrNote => 'Tìm theo danh mục hoặc ghi chú';

  @override
  String get noTransactions => 'Chưa có giao dịch';

  @override
  String get noTransactionsFound => 'Không tìm thấy giao dịch';

  @override
  String get noTransactionsInRange => 'Chưa có giao dịch trong khoảng này';

  @override
  String get deleteTransactionTitle => 'Xóa giao dịch?';

  @override
  String get deleteTransactionMessage =>
      'Giao dịch này sẽ bị xóa khỏi danh sách.';

  @override
  String get deleteTransactionPermanent =>
      'Giao dịch này sẽ bị xóa và không thể khôi phục.';

  @override
  String get editTransaction => 'Sửa giao dịch';

  @override
  String get addTransaction => 'Thêm giao dịch';

  @override
  String get deleteTransaction => 'Xóa giao dịch';

  @override
  String transactionCount(int count) {
    return '$count giao dịch';
  }

  @override
  String get pleaseEnterAmount => 'Vui lòng nhập số tiền';

  @override
  String get pleaseSelectCategory => 'Vui lòng chọn danh mục';

  @override
  String budgetExceeded(String name, String amount) {
    return 'Đã vượt ngân sách \"$name\" $amount';
  }

  @override
  String budgetWarning(String name, String percent, String remaining) {
    return 'Ngân sách \"$name\" đã dùng $percent, còn lại $remaining';
  }

  @override
  String autoAddedRecurring(int count) {
    return 'Đã tự động thêm $count giao dịch định kỳ';
  }

  @override
  String get myWallets => 'Ví của tôi';

  @override
  String get addWallet => 'Thêm ví';

  @override
  String get editWallet => 'Sửa ví';

  @override
  String get deleteWallet => 'Xóa ví';

  @override
  String get walletName => 'Tên ví';

  @override
  String walletCount(int count) {
    return '$count ví';
  }

  @override
  String get allWallets => 'Tất cả ví';

  @override
  String get selectWallet => 'Chọn ví';

  @override
  String get noWalletAttached => 'Không gắn ví';

  @override
  String get pleaseEnterWalletName => 'Vui lòng nhập tên ví';

  @override
  String get keepAtLeastOneWallet => 'Cần giữ lại ít nhất một ví';

  @override
  String get deleteWalletTitle => 'Xóa ví?';

  @override
  String deleteWalletMessageSimple(String name) {
    return 'Ví \"$name\" sẽ bị xóa.';
  }

  @override
  String deleteWalletMessageWithTx(String name, int count) {
    return 'Ví \"$name\" và $count giao dịch trong ví này sẽ bị xóa.';
  }

  @override
  String deleteWalletLinkedNotice(int count) {
    return ' $count khoản ở mục tiêu và sổ nợ liên quan sẽ được giữ lại nhưng không còn gắn với ví.';
  }

  @override
  String get manageWalletsSubtitle => 'Tạo và quản lý các ví của bạn';

  @override
  String get cashWallet => 'Tiền mặt';

  @override
  String get bankWallet => 'Ngân hàng';

  @override
  String get eWallet => 'Ví điện tử';

  @override
  String get createCategory => 'Tạo danh mục mới';

  @override
  String get editCategory => 'Sửa danh mục';

  @override
  String get categoryName => 'Tên danh mục';

  @override
  String get pleaseEnterCategoryName => 'Vui lòng nhập tên danh mục';

  @override
  String get deleteCategoryTitle => 'Xóa danh mục?';

  @override
  String deleteCategorySimple(String name) {
    return 'Danh mục \"$name\" sẽ bị xóa.';
  }

  @override
  String deleteCategoryWithTx(String name, int count) {
    return 'Danh mục \"$name\" và $count giao dịch thuộc danh mục này sẽ bị xóa.';
  }

  @override
  String get catFood => 'Ăn uống';

  @override
  String get catGrocery => 'Đi chợ';

  @override
  String get catShop => 'Mua sắm';

  @override
  String get catHome => 'Nhà cửa';

  @override
  String get catTransport => 'Di chuyển';

  @override
  String get catHealth => 'Sức khỏe';

  @override
  String get catBill => 'Hóa đơn';

  @override
  String get catEntertain => 'Giải trí';

  @override
  String get catSalary => 'Lương';

  @override
  String get catBonus => 'Thưởng';

  @override
  String get catInvest => 'Đầu tư';

  @override
  String get catOtherIncome => 'Thu khác';

  @override
  String get budget => 'Ngân sách';

  @override
  String get budgetByCategory => 'Ngân sách theo danh mục';

  @override
  String get budgetSubtitle => 'Đặt hạn mức chi tiêu mỗi tháng';

  @override
  String get monthlyLimit => 'Hạn mức mỗi tháng';

  @override
  String get addBudget => 'Thêm ngân sách';

  @override
  String get editBudget => 'Sửa ngân sách';

  @override
  String get deleteBudget => 'Xóa ngân sách';

  @override
  String get deleteBudgetTitle => 'Xóa ngân sách?';

  @override
  String deleteBudgetMessage(String name) {
    return 'Ngân sách của danh mục \"$name\" sẽ bị xóa.';
  }

  @override
  String get noBudgetsYet => 'Chưa có ngân sách nào';

  @override
  String get allCategoriesHaveBudgets =>
      'Tất cả danh mục chi tiêu đã có ngân sách';

  @override
  String get pleaseEnterLimit => 'Vui lòng nhập hạn mức';

  @override
  String canSpendPerDay(String amount) {
    return 'Có thể chi $amount/ngày';
  }

  @override
  String outsideBudget(String amount) {
    return 'Chi ngoài ngân sách: $amount';
  }

  @override
  String get viewTransactions => 'Xem giao dịch';

  @override
  String spentOfLimit(String amount) {
    return 'Đã chi $amount';
  }

  @override
  String limitAmount(String amount) {
    return 'Hạn mức $amount';
  }

  @override
  String statusOver(String amount) {
    return 'Vượt $amount';
  }

  @override
  String statusRemaining(String amount) {
    return 'Còn $amount';
  }

  @override
  String get goals => 'Mục tiêu kiếm tiền';

  @override
  String get goalsSubtitle => 'Tiết kiệm cho kế hoạch của bạn';

  @override
  String get addGoal => 'Thêm mục tiêu';

  @override
  String get editGoal => 'Sửa mục tiêu';

  @override
  String get deleteGoal => 'Xóa mục tiêu';

  @override
  String get deleteGoalTitle => 'Xóa mục tiêu?';

  @override
  String deleteGoalMessage(String name) {
    return 'Mục tiêu \"$name\" và toàn bộ lịch sử sẽ bị xóa.';
  }

  @override
  String get goalName => 'Tên mục tiêu';

  @override
  String get targetAmount => 'Số tiền mục tiêu';

  @override
  String get totalSaved => 'Tổng đã tiết kiệm';

  @override
  String get savedLabel => 'Đã tiết kiệm';

  @override
  String targetLabel(String amount) {
    return 'Mục tiêu $amount';
  }

  @override
  String stillNeeded(String amount) {
    return 'Còn thiếu $amount';
  }

  @override
  String get deadline => 'Hạn hoàn thành';

  @override
  String get noDeadline => 'Không giới hạn thời gian';

  @override
  String activeGoalsCount(int count) {
    return 'Đang thực hiện ($count)';
  }

  @override
  String doneGoalsCount(int count) {
    return 'Hoàn thành ($count)';
  }

  @override
  String get noGoalsYet => 'Chưa có mục tiêu nào';

  @override
  String get noGoalsCompleted => 'Chưa có mục tiêu nào hoàn thành';

  @override
  String get noGoalsActive => 'Không có mục tiêu đang thực hiện';

  @override
  String goalsCompletedCount(int done, int total) {
    return '$done/$total hoàn thành';
  }

  @override
  String get deposit => 'Nạp tiền';

  @override
  String get withdraw => 'Rút tiền';

  @override
  String get depositAction => 'Nạp tiền vào mục tiêu';

  @override
  String get withdrawAction => 'Rút tiền từ mục tiêu';

  @override
  String congratsGoalCompleted(String name) {
    return 'Chúc mừng! Bạn đã hoàn thành mục tiêu \"$name\"';
  }

  @override
  String get pleaseEnterGoalName => 'Vui lòng nhập tên mục tiêu';

  @override
  String get pleaseEnterTarget => 'Vui lòng nhập số tiền mục tiêu';

  @override
  String get deadlineOptional => 'Hạn hoàn thành (không bắt buộc)';

  @override
  String get initialDeposit => 'Số tiền nạp ban đầu';

  @override
  String get selectDeadline => 'Chọn hạn';

  @override
  String daysRemaining(int days) {
    return 'Còn $days ngày';
  }

  @override
  String get dueToday => 'Hết hạn hôm nay';

  @override
  String daysOverdue(int days) {
    return 'Quá hạn $days ngày';
  }

  @override
  String get completed => 'Đã hoàn thành';

  @override
  String get deleteEntryTitle => 'Xóa giao dịch này?';

  @override
  String get deleteEntryMessage => 'Số tiền mục tiêu sẽ được tính lại.';

  @override
  String get debts => 'Sổ nợ';

  @override
  String get debtsSubtitle => 'Theo dõi các khoản cho vay và đi vay';

  @override
  String get addDebt => 'Thêm khoản nợ';

  @override
  String get editDebt => 'Sửa khoản nợ';

  @override
  String get deleteDebt => 'Xóa khoản nợ';

  @override
  String get deleteDebtTitle => 'Xóa khoản nợ?';

  @override
  String get deleteDebtMessage =>
      'Khoản nợ này và toàn bộ lịch sử trả sẽ bị xóa.';

  @override
  String get lend => 'Cho vay';

  @override
  String get borrow => 'Đi vay';

  @override
  String get collectDebt => 'Thu nợ';

  @override
  String get payDebt => 'Trả nợ';

  @override
  String get collected => 'Đã thu';

  @override
  String get paid => 'Đã trả';

  @override
  String get principalAmount => 'Số tiền gốc';

  @override
  String get person => 'Người liên quan';

  @override
  String get personHint => 'Tên người vay / cho vay';

  @override
  String get pleaseEnterPerson => 'Vui lòng nhập tên người liên quan';

  @override
  String openDebtsCount(int count) {
    return 'Chưa xong ($count)';
  }

  @override
  String settledDebtsCount(int count) {
    return 'Đã tất toán ($count)';
  }

  @override
  String lendCount(int count) {
    return 'Cho vay ($count)';
  }

  @override
  String borrowCount(int count) {
    return 'Đi vay ($count)';
  }

  @override
  String get receivable => 'Cần thu';

  @override
  String get payable => 'Cần trả';

  @override
  String overdueCount(int count) {
    return '$count khoản quá hạn';
  }

  @override
  String get noSettledDebts => 'Chưa có khoản nào đã tất toán';

  @override
  String get noLendDebts => 'Chưa có khoản cho vay nào';

  @override
  String get noBorrowDebts => 'Chưa có khoản đi vay nào';

  @override
  String debtSettledNotification(String person) {
    return 'Đã tất toán khoản của \"$person\"';
  }

  @override
  String get settled => 'Đã tất toán';

  @override
  String get dueDate => 'Hạn trả';

  @override
  String get noDueDate => 'Không có hạn trả';

  @override
  String debtCreatedDate(String type, String date) {
    return '$type ngày $date';
  }

  @override
  String get deletePaymentTitle => 'Xóa lần thanh toán?';

  @override
  String get deletePaymentMessage =>
      'Số tiền còn lại của khoản nợ sẽ được tính lại.';

  @override
  String get lendPrincipal => 'Khoản cho vay';

  @override
  String get borrowPrincipal => 'Khoản đi vay';

  @override
  String get repayment => 'Thanh toán nợ';

  @override
  String get recurring => 'Giao dịch định kỳ';

  @override
  String get recurringSubtitle => 'Tự động lặp lại theo chu kỳ';

  @override
  String get addRecurring => 'Thêm định kỳ';

  @override
  String get editRecurring => 'Sửa định kỳ';

  @override
  String get deleteRecurring => 'Xóa định kỳ';

  @override
  String get deleteRecurringTitle => 'Xóa định kỳ?';

  @override
  String get deleteRecurringMessage =>
      'Giao dịch định kỳ này sẽ bị xóa và không còn tự tạo nữa.';

  @override
  String get frequency => 'Tần suất';

  @override
  String get freqDaily => 'Hằng ngày';

  @override
  String get freqWeekly => 'Hằng tuần';

  @override
  String get freqMonthly => 'Hằng tháng';

  @override
  String get freqYearly => 'Hằng năm';

  @override
  String get nextDate => 'Lần tiếp theo';

  @override
  String get startDateLabel => 'Ngày bắt đầu';

  @override
  String get endDateOptional => 'Ngày kết thúc (không bắt buộc)';

  @override
  String get noRecurringYet => 'Chưa có giao dịch định kỳ nào';

  @override
  String get monthlyAvgExpense => 'Ước tính chi mỗi tháng';

  @override
  String get monthlyAvgIncome => 'Ước tính thu mỗi tháng';

  @override
  String get active => 'Đang bật';

  @override
  String get paused => 'Tạm dừng';

  @override
  String get finished => 'Đã kết thúc';

  @override
  String get currencyDefault => 'Tiền tệ mặc định';

  @override
  String get walletCurrency => 'Tiền tệ của ví';

  @override
  String get useExistingWallets => 'Dùng ví hiện có';

  @override
  String get currencyCodeLabel => 'Tiền tệ';

  @override
  String get currencyDefaultNotice =>
      'Chọn tiền tệ mặc định để hiển thị và nhập số tiền. Việc này không quy đổi số dư trong ví.';

  @override
  String get currencyConverter => 'Đổi tiền tệ';

  @override
  String get currencyConverterSubtitle => 'Quy đổi theo tỷ giá';

  @override
  String get theme => 'Giao diện';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get langSystem => 'Theo hệ thống';

  @override
  String get langVi => 'Tiếng Việt';

  @override
  String get langEn => 'English';

  @override
  String get backupAndRestore => 'Sao lưu & khôi phục';

  @override
  String get exportData => 'Xuất dữ liệu';

  @override
  String get exportCsv => 'Xuất ra file CSV';

  @override
  String get about => 'Giới thiệu';

  @override
  String appVersion(String version) {
    return 'Phiên bản $version';
  }

  @override
  String get backupData => 'Sao lưu dữ liệu';

  @override
  String get restoreData => 'Khôi phục dữ liệu';

  @override
  String get backupCopied =>
      'Đã sao chép bản sao lưu. Hãy dán vào nơi an toàn để lưu lại';

  @override
  String get restoreNotFound =>
      'Không tìm thấy bản sao lưu hợp lệ trong bộ nhớ tạm';

  @override
  String get restoreConfirmTitle => 'Khôi phục dữ liệu?';

  @override
  String get restoreConfirmMessage =>
      'Toàn bộ dữ liệu hiện tại sẽ bị thay thế.';

  @override
  String get restoreSuccess => 'Đã khôi phục dữ liệu';

  @override
  String convertCurrencyTitle(String code) {
    return 'Đổi sang $code';
  }

  @override
  String convertCurrencyPrompt(String currency) {
    return 'Dùng hoặc tạo ví bằng $currency mà không quy đổi, hay quy đổi dữ liệu hiện tại?';
  }

  @override
  String get displayOnly => 'Chỉ đổi hiển thị';

  @override
  String get convertAll => 'Quy đổi tất cả';

  @override
  String get selectWalletsToConvert =>
      'Chọn ví muốn quy đổi sang loại tiền mới';

  @override
  String get convertSelectedWallets => 'Quy đổi ví đã chọn';

  @override
  String get convertWallets => 'Quy đổi ví';

  @override
  String get walletConversionSubtitle =>
      'Chọn một hoặc nhiều ví cùng loại tiền tệ để quy đổi.';

  @override
  String get filterCurrencies => 'Lọc ví theo tiền tệ';

  @override
  String get showAllCurrencies => 'Hiện tất cả tiền tệ';

  @override
  String get walletsMustShareCurrency =>
      'Có thể chọn nhiều ví, nhưng các ví phải cùng loại tiền tệ.';

  @override
  String get selectTargetCurrency => 'Chọn tiền tệ muốn quy đổi sang';

  @override
  String get changeDefaultCurrency => 'Chuyển sang tiền tệ này';

  @override
  String askAddWalletForCurrency(String currency) {
    return 'Bạn có muốn tạo ví mới cho $currency không?';
  }

  @override
  String get currencyConvertLinkedNotice =>
      'Nếu mục tiêu hoặc khoản nợ liên kết nhiều ví, các ví đó cũng sẽ được quy đổi cùng để giữ dữ liệu nhất quán.';

  @override
  String get backupSavedConfirmation => 'Tôi đã lưu bản sao lưu ở nơi an toàn';

  @override
  String get ratesUpdated => 'Đã cập nhật tỷ giá';

  @override
  String get ratesOffline => 'Không có kết nối, đang dùng tỷ giá đã lưu';

  @override
  String get welcome => 'Chào mừng bạn!';

  @override
  String get welcomeSubtitle =>
      'Hãy tạo ví đầu tiên để bắt đầu quản lý chi tiêu';

  @override
  String get quickSuggestions => 'Gợi ý nhanh';

  @override
  String get createWalletAndStart => 'Tạo ví & bắt đầu';

  @override
  String get introTrackTitle => 'Theo dõi thu chi';

  @override
  String get introTrackDesc =>
      'Ghi lại mọi khoản thu và chi, xem biểu đồ theo danh mục để biết tiền của bạn đang đi đâu.';

  @override
  String get introWalletTitle => 'Quản lý nhiều ví';

  @override
  String get introWalletDesc =>
      'Tách riêng tiền mặt, ngân hàng, ví điện tử và xem số dư của từng ví một cách rõ ràng.';

  @override
  String get introBudgetTitle => 'Ngân sách & mục tiêu';

  @override
  String get introBudgetDesc =>
      'Đặt hạn mức chi tiêu mỗi tháng, nhận cảnh báo khi sắp vượt và tiết kiệm cho kế hoạch của bạn.';

  @override
  String get introRecurringTitle => 'Sổ nợ & giao dịch định kỳ';

  @override
  String get introRecurringDesc =>
      'Theo dõi các khoản cho vay, đi vay và để các khoản lặp lại như tiền nhà, lương tự động được ghi.';

  @override
  String get weekdayMon => 'T2';

  @override
  String get weekdayTue => 'T3';

  @override
  String get weekdayWed => 'T4';

  @override
  String get weekdayThu => 'T5';

  @override
  String get weekdayFri => 'T6';

  @override
  String get weekdaySat => 'T7';

  @override
  String get weekdaySun => 'CN';

  @override
  String get selectCurrency => 'Chọn tiền tệ';

  @override
  String get fromCurrency => 'Từ';

  @override
  String get toCurrency => 'Sang';

  @override
  String get refreshRates => 'Cập nhật tỷ giá';

  @override
  String get selectAll => 'Chọn tất cả';

  @override
  String get deleteSelectedTitle => 'Xóa các mục đã chọn?';

  @override
  String deleteSelectedMessage(int count) {
    return 'Bạn có chắc muốn xóa $count mục đã chọn không? Thao tác này không thể hoàn tác.';
  }

  @override
  String get exportCsvTitle => 'Xuất ra file CSV';

  @override
  String get splashTagline => 'Quản lý chi tiêu cá nhân';

  @override
  String get amountCannotBeLessThanPaid =>
      'Số tiền không được nhỏ hơn số đã thanh toán';

  @override
  String get exceedsRemainingAmount => 'Vượt quá số tiền còn lại';

  @override
  String collectAll(String amount) {
    return 'Thu hết: $amount';
  }

  @override
  String payAll(String amount) {
    return 'Trả hết: $amount';
  }

  @override
  String get creditToWallet => 'Cộng vào ví';

  @override
  String get debitFromWallet => 'Trừ từ ví';

  @override
  String get walletSourceLend => 'Lấy tiền từ ví';

  @override
  String get walletSourceBorrow => 'Nhận tiền vào ví';

  @override
  String get debtDateLend => 'Ngày cho vay';

  @override
  String get debtDateBorrow => 'Ngày vay';

  @override
  String get borrower => 'Người vay';

  @override
  String get lender => 'Người cho vay';

  @override
  String get backupExplainTitle => 'Tính năng này để làm gì?';

  @override
  String get backupExplainBody =>
      'Dữ liệu chỉ nằm trên máy này. Nếu bạn đổi điện thoại hoặc xóa app, dữ liệu sẽ mất.\n\nSao lưu: tạo một đoạn mã chứa toàn bộ dữ liệu và chép vào bộ nhớ tạm. Hãy dán nó vào Ghi chú hoặc email để lưu lại.\n\nKhôi phục: chép lại đoạn mã đó rồi bấm Khôi phục để đưa dữ liệu về.';

  @override
  String get exportExplainBody =>
      'CSV là file bảng tính dạng văn bản đơn giản. Chọn các phần dữ liệu muốn xuất bên dưới. Bạn có thể mở bằng Excel hoặc Google Sheets để xem, lọc và tính toán.\n\nKhác với Sao lưu, file này dùng để xem và phân tích dữ liệu, không dùng để khôi phục lại vào app.';

  @override
  String get restoreFromClipboard => 'Khôi phục từ bộ nhớ tạm';

  @override
  String get depositAmount => 'Số tiền nạp';

  @override
  String get withdrawAmount => 'Số tiền rút';

  @override
  String get exceedsSavedAmount => 'Vượt quá số tiền đã tiết kiệm';

  @override
  String reachGoalAmount(String amount) {
    return 'Đủ mục tiêu: $amount';
  }

  @override
  String walletBalanceLabel(String amount) {
    return 'Số dư ví: $amount';
  }

  @override
  String get deletePaymentConfirmTitle => 'Xóa lần thanh toán?';

  @override
  String get deletePaymentConfirmMessage =>
      'Số tiền còn lại của khoản nợ sẽ được tính lại.';

  @override
  String get lentItem => 'Khoản cho vay';

  @override
  String get borrowedItem => 'Khoản đi vay';

  @override
  String duePrefix(String date) {
    return 'Hạn trả $date';
  }

  @override
  String get exportSectionTransactions => 'Giao dịch';

  @override
  String get exportSectionWallets => 'Ví tiền';

  @override
  String get exportSectionBudgets => 'Ngân sách tháng này';

  @override
  String get exportSectionGoals => 'Mục tiêu tiết kiệm';

  @override
  String get exportSectionDebts => 'Sổ nợ';

  @override
  String get exportSectionRecurrings => 'Giao dịch định kỳ';

  @override
  String get defaultRatesWarning =>
      'Đang dùng tỷ giá mặc định có sẵn trong app, có thể đã cũ. Kết nối mạng và bấm cập nhật để lấy tỷ giá mới nhất.';

  @override
  String lastUpdated(String time) {
    return 'Cập nhật lần cuối: $time';
  }

  @override
  String get currencyDisclaimer =>
      'Tỷ giá cung cấp bởi ExchangeRate-API (exchangerate-api.com), cập nhật mỗi ngày, chỉ mang tính tham khảo.';

  @override
  String get currencyConvertWarning =>
      'Giao dịch, mục tiêu, khoản nợ và định kỳ gắn với ví được chọn sẽ được quy đổi. Ngân sách không gắn với ví sẽ giữ nguyên tiền tệ.';

  @override
  String get manageWallets => 'Ví tiền';

  @override
  String get manageWalletsDesc => 'Tạo và quản lý các ví của bạn';

  @override
  String get budgetDesc => 'Đặt hạn mức chi tiêu mỗi tháng';

  @override
  String get goalsDesc => 'Tiết kiệm cho kế hoạch của bạn';

  @override
  String get debtsDesc => 'Theo dõi các khoản cho vay và đi vay';

  @override
  String get recurringDesc => 'Tự động lặp lại theo chu kỳ';

  @override
  String get initialAmount => 'Số tiền đã có';

  @override
  String get initialAmountOptional => 'Số tiền đã có (không bắt buộc)';

  @override
  String get noEndDate => 'Không giới hạn';

  @override
  String get repeatCycle => 'Chu kỳ lặp';

  @override
  String get startsOn => 'Bắt đầu từ ngày';

  @override
  String get endsOn => 'Kết thúc (không bắt buộc)';

  @override
  String get deleteRecurringConfirm =>
      'Các giao dịch đã được tạo trước đó vẫn được giữ lại.';

  @override
  String get curVnd => 'Đồng Việt Nam';

  @override
  String get curUsd => 'Đô la Mỹ';

  @override
  String get curEur => 'Euro';

  @override
  String get curGbp => 'Bảng Anh';

  @override
  String get curJpy => 'Yên Nhật';

  @override
  String get curCny => 'Nhân dân tệ';

  @override
  String get curKrw => 'Won Hàn Quốc';

  @override
  String get curThb => 'Baht Thái';

  @override
  String get curSgd => 'Đô la Singapore';

  @override
  String get curAud => 'Đô la Úc';

  @override
  String get curCad => 'Đô la Canada';

  @override
  String get curChf => 'Franc Thụy Sĩ';

  @override
  String get curInr => 'Rupee Ấn Độ';

  @override
  String get curHkd => 'Đô la Hồng Kông';

  @override
  String get curMyr => 'Ringgit Malaysia';

  @override
  String get curIdr => 'Rupiah Indonesia';

  @override
  String get curPhp => 'Peso Philippines';

  @override
  String get curTwd => 'Đô la Đài Loan';

  @override
  String get type => 'Loại';

  @override
  String get status => 'Trạng thái';

  @override
  String get limitLabel => 'Hạn mức';

  @override
  String get progress => 'Tiến độ';

  @override
  String get currentBalance => 'Số dư hiện tại';

  @override
  String get createdDate => 'Ngày phát sinh';

  @override
  String csvBudgetTitle(int month, int year) {
    return 'NGÂN SÁCH THÁNG $month/$year';
  }

  @override
  String get csvGoalHistory => 'Lịch sử mục tiêu';

  @override
  String get csvDebtPayments => 'Lịch sử thanh toán nợ';

  @override
  String get dateFormatHint => 'dd/mm/yyyy';

  @override
  String get seedNoteLunch => 'Cơm trưa';

  @override
  String get seedNoteRide => 'Grab';

  @override
  String get seedNoteVegetables => 'Rau củ ở chợ';

  @override
  String get seedNoteTshirt => 'Áo thun';

  @override
  String get seedNoteCoffee => 'Cà phê + bánh';

  @override
  String get seedNoteElectricity => 'Tiền điện';

  @override
  String get seedNoteRent => 'Tiền nhà';

  @override
  String get seedNoteMedicine => 'Thuốc';

  @override
  String get seedNoteSalary => 'Lương tháng';

  @override
  String get seedNoteProjectBonus => 'Thưởng dự án';

  @override
  String get seedNoteInterest => 'Lãi tiết kiệm';

  @override
  String get seedGoalTrip => 'Du lịch Đà Lạt';

  @override
  String get seedGoalInitial => 'Số tiền ban đầu';

  @override
  String get seedGoalMonthly => 'Dành dụm tháng này';

  @override
  String get seedPersonMinh => 'Bạn Minh';

  @override
  String get seedDebtLendNote => 'Cho mượn đóng tiền trọ';

  @override
  String get seedDebtPayment => 'Trả đợt 1';

  @override
  String get seedPersonLan => 'Chị Lan';

  @override
  String get seedDebtBorrowNote => 'Mượn mua xe đạp';

  @override
  String get dayEvents => 'Sự kiện trong ngày';

  @override
  String get noTransactionsOnDate => 'Chưa có giao dịch trong ngày này';

  @override
  String get noEventsOnDate => 'Không có sự kiện trong ngày này';

  @override
  String get pastEvent => 'Sự kiện đã qua';

  @override
  String get todayEvent => 'Sự kiện hôm nay';

  @override
  String get todayEvents => 'Sự kiện hôm nay';

  @override
  String get recordEventTransaction => 'Ghi giao dịch';

  @override
  String get confirmEventTransactionTitle => 'Xác nhận tạo giao dịch?';

  @override
  String get confirmEventTransactionMessage =>
      'Khoản dự kiến dưới đây sẽ được ghi vào sổ và cập nhật số dư ví.';

  @override
  String get eventTransactionNeedsSetup =>
      'Cần có danh mục phù hợp và ví cùng loại tiền tệ để ghi giao dịch.';

  @override
  String get eventTransactionAlreadyRecorded =>
      'Sự kiện này đã có giao dịch trong sổ.';

  @override
  String get plannedExpense => 'Khoản chi dự kiến';

  @override
  String get plannedIncome => 'Khoản thu dự kiến';

  @override
  String get selectItemsToDelete => 'Chọn mục cần xóa';

  @override
  String get deleteEventTransactionsTitle => 'Xóa giao dịch liên quan?';

  @override
  String get deleteEventTransactionsMessage =>
      'Bạn có muốn xóa các giao dịch đã ghi từ sự kiện này không?';

  @override
  String get keepEventTransactions => 'Giữ lại giao dịch';

  @override
  String get deleteEventTransactions => 'Xóa giao dịch';

  @override
  String get actualAmount => 'Số tiền thực tế';

  @override
  String get linkEventToRecurring => 'Liên kết với giao dịch định kỳ';

  @override
  String get autoRecordLinkedRecurring => 'Tự động ghi giao dịch khi đến hạn';

  @override
  String get eventAmountOptional => 'Không bắt buộc';

  @override
  String get eventReminderToggle => 'Nhắc tôi';

  @override
  String get reminderTime => 'Giờ nhắc';

  @override
  String get eventReminderPermissionDenied =>
      'Chưa có quyền gửi thông báo. Hãy bật quyền trong cài đặt thiết bị.';

  @override
  String get eventReminderNotificationTitle => 'Nhắc nhở sự kiện';

  @override
  String get eventReminderChannel => 'Nhắc nhở sự kiện';

  @override
  String get eventReminderChannelDescription =>
      'Thông báo về các sự kiện đã lên lịch';

  @override
  String get negativeWalletBalanceTitle => 'Ví không đủ tiền';

  @override
  String get negativeWalletBalanceMessage =>
      'Số dư ví không đủ cho khoản chi này. Nếu tiếp tục, số dư ví sẽ thành số âm.';

  @override
  String get recordAnyway => 'Vẫn ghi giao dịch';

  @override
  String get hideBalanceByDefault => 'Ẩn số dư mặc định';

  @override
  String get hideBalanceDescription => 'Chạm vào số dư để hiện tạm thời.';

  @override
  String get showBalance => 'Hiện số dư';

  @override
  String get hideBalance => 'Ẩn số dư';

  @override
  String get dateFormat => 'Định dạng ngày';

  @override
  String get dateFormatDayMonthYear => 'Ngày / tháng / năm';

  @override
  String get dateFormatMonthDayYear => 'Tháng / ngày / năm';

  @override
  String get dateFormatYearMonthDay => 'Năm - tháng - ngày';

  @override
  String get showWalletBalances => 'Hiện số dư các ví';

  @override
  String get hideWalletBalances => 'Ẩn số dư các ví';

  @override
  String get undoLastWalletConversion => 'Hoàn tác lần quy đổi ví gần nhất';

  @override
  String get walletConversionUndone => 'Đã hoàn tác quy đổi ví';

  @override
  String get skipWalletSetup => 'Bỏ qua, tạo ví sau';

  @override
  String get skipGuide => 'Bỏ qua hướng dẫn';

  @override
  String get overviewGuideTitle => 'Làm quen với Tổng quan';

  @override
  String get overviewGuideIntro =>
      'Xem nhanh số dư, thu nhập, chi tiêu và phân bổ theo danh mục.';

  @override
  String get overviewGuideWalletTitle => 'Chọn ví cần xem';

  @override
  String get overviewGuideWalletDescription =>
      'Chạm vào bộ chọn ví để xem tổng quan của tất cả ví hoặc một ví riêng.';

  @override
  String get overviewGuideBalanceTitle => 'Xem số dư';

  @override
  String get overviewGuideBalanceDescription =>
      'Chạm vào số dư để hiện hoặc ẩn tạm thời theo cài đặt bảo mật.';

  @override
  String get overviewGuideTypeTitle => 'Chuyển giữa thu và chi';

  @override
  String get overviewGuideTypeDescription =>
      'Chọn tab thu hoặc chi để xem biểu đồ và danh mục tương ứng.';

  @override
  String get overviewGuidePeriodTitle => 'Chọn khoảng thời gian';

  @override
  String get overviewGuidePeriodDescription =>
      'Đổi ngày, tuần, tháng, năm hoặc kỳ tùy chỉnh để xem dữ liệu trong khoảng đó.';

  @override
  String get overviewGuideChartTitle => 'Xem biểu đồ và danh mục';

  @override
  String get overviewGuideChartDescription =>
      'Biểu đồ cho biết khoản tiền phân bổ theo danh mục. Chạm một danh mục để xem các giao dịch liên quan.';

  @override
  String get overviewGuideTransactionsTitle => 'Xem danh sách theo danh mục';

  @override
  String get overviewGuideTransactionsDescription =>
      'Các dòng bên dưới biểu đồ cho biết số tiền theo từng danh mục. Chạm vào một dòng để xem các giao dịch thuộc danh mục đó.';

  @override
  String get overviewGuideSettingsTitle => 'Mở cài đặt';

  @override
  String get overviewGuideSettingsDescription =>
      'Tùy chỉnh tiền tệ, định dạng ngày, giao diện, ngôn ngữ và sao lưu dữ liệu.';

  @override
  String get overviewGuideAddTitle => 'Thêm giao dịch';

  @override
  String get overviewGuideAddDescription =>
      'Nút dấu cộng ở giữa thanh điều hướng giúp ghi nhanh một khoản thu hoặc chi.';
}
