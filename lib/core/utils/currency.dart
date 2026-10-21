class AppCurrency {
  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.quickAmounts,
    this.decimals = 2,
    this.symbolAfter = false,
    this.thousandsSep = ',',
    this.decimalSep = '.',
  });

  final String code;
  final String symbol;
  final String name;
  final List<int> quickAmounts;
  final int decimals;
  final bool symbolAfter;
  final String thousandsSep;
  final String decimalSep;

  int get scale {
    var value = 1;
    for (var i = 0; i < decimals; i++) {
      value *= 10;
    }
    return value;
  }

  String get label => '$code ($symbol)';

  static const vnd = AppCurrency(
    code: 'VND',
    symbol: '₫',
    name: 'Đồng Việt Nam',
    decimals: 0,
    symbolAfter: true,
    thousandsSep: '.',
    decimalSep: ',',
    quickAmounts: [500000, 1000000, 2000000, 5000000, 10000000],
  );
  static const usd = AppCurrency(
    code: 'USD',
    symbol: r'$',
    name: 'Đô la Mỹ',
    quickAmounts: [10, 20, 50, 100, 500],
  );
  static const eur = AppCurrency(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    symbolAfter: true,
    thousandsSep: '.',
    decimalSep: ',',
    quickAmounts: [10, 20, 50, 100, 500],
  );
  static const gbp = AppCurrency(
    code: 'GBP',
    symbol: '£',
    name: 'Bảng Anh',
    quickAmounts: [10, 20, 50, 100, 500],
  );
  static const jpy = AppCurrency(
    code: 'JPY',
    symbol: '¥',
    name: 'Yên Nhật',
    decimals: 0,
    quickAmounts: [1000, 5000, 10000, 50000, 100000],
  );
  static const cny = AppCurrency(
    code: 'CNY',
    symbol: 'CN¥',
    name: 'Nhân dân tệ',
    quickAmounts: [50, 100, 500, 1000, 5000],
  );
  static const krw = AppCurrency(
    code: 'KRW',
    symbol: '₩',
    name: 'Won Hàn Quốc',
    decimals: 0,
    quickAmounts: [10000, 50000, 100000, 500000, 1000000],
  );
  static const thb = AppCurrency(
    code: 'THB',
    symbol: '฿',
    name: 'Baht Thái',
    quickAmounts: [100, 500, 1000, 5000, 10000],
  );
  static const sgd = AppCurrency(
    code: 'SGD',
    symbol: r'S$',
    name: 'Đô la Singapore',
    quickAmounts: [10, 20, 50, 100, 500],
  );
  static const aud = AppCurrency(
    code: 'AUD',
    symbol: r'A$',
    name: 'Đô la Úc',
    quickAmounts: [10, 20, 50, 100, 500],
  );
  static const cad = AppCurrency(
    code: 'CAD',
    symbol: r'C$',
    name: 'Đô la Canada',
    quickAmounts: [10, 20, 50, 100, 500],
  );
  static const chf = AppCurrency(
    code: 'CHF',
    symbol: 'CHF',
    name: 'Franc Thụy Sĩ',
    quickAmounts: [10, 20, 50, 100, 500],
  );
  static const inr = AppCurrency(
    code: 'INR',
    symbol: '₹',
    name: 'Rupee Ấn Độ',
    quickAmounts: [100, 500, 1000, 5000, 10000],
  );
  static const hkd = AppCurrency(
    code: 'HKD',
    symbol: r'HK$',
    name: 'Đô la Hồng Kông',
    quickAmounts: [100, 200, 500, 1000, 5000],
  );
  static const myr = AppCurrency(
    code: 'MYR',
    symbol: 'RM',
    name: 'Ringgit Malaysia',
    quickAmounts: [10, 50, 100, 500, 1000],
  );
  static const idr = AppCurrency(
    code: 'IDR',
    symbol: 'Rp',
    name: 'Rupiah Indonesia',
    decimals: 0,
    thousandsSep: '.',
    decimalSep: ',',
    quickAmounts: [50000, 100000, 500000, 1000000, 5000000],
  );
  static const php = AppCurrency(
    code: 'PHP',
    symbol: '₱',
    name: 'Peso Philippines',
    quickAmounts: [100, 500, 1000, 5000, 10000],
  );
  static const twd = AppCurrency(
    code: 'TWD',
    symbol: r'NT$',
    name: 'Đô la Đài Loan',
    decimals: 0,
    quickAmounts: [100, 500, 1000, 5000, 10000],
  );

  static const List<AppCurrency> all = [
    vnd,
    usd,
    eur,
    gbp,
    jpy,
    cny,
    krw,
    thb,
    sgd,
    aud,
    cad,
    chf,
    inr,
    hkd,
    myr,
    idr,
    php,
    twd,
  ];

  static AppCurrency current = vnd;

  static AppCurrency byCode(String? code) =>
      all.firstWhere((c) => c.code == code, orElse: () => vnd);
}

String get currencySymbol => AppCurrency.current.symbol;
