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
    name: 'Vietnamese Dong',
    decimals: 0,
    symbolAfter: true,
    thousandsSep: '.',
    decimalSep: ',',
    quickAmounts: [500000, 1000000, 2000000, 5000000, 10000000],
  );
  static const usd = AppCurrency(
    code: 'USD',
    symbol: r'$',
    name: 'US Dollar',
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
    name: 'British Pound',
    quickAmounts: [10, 20, 50, 100, 500],
  );
  static const jpy = AppCurrency(
    code: 'JPY',
    symbol: '¥',
    name: 'Japanese Yen',
    decimals: 0,
    quickAmounts: [1000, 5000, 10000, 50000, 100000],
  );
  static const cny = AppCurrency(
    code: 'CNY',
    symbol: 'CN¥',
    name: 'Chinese Yuan',
    quickAmounts: [50, 100, 500, 1000, 5000],
  );
  static const krw = AppCurrency(
    code: 'KRW',
    symbol: '₩',
    name: 'South Korean Won',
    decimals: 0,
    quickAmounts: [10000, 50000, 100000, 500000, 1000000],
  );
  static const thb = AppCurrency(
    code: 'THB',
    symbol: '฿',
    name: 'Thai Baht',
    quickAmounts: [100, 500, 1000, 5000, 10000],
  );
  static const sgd = AppCurrency(
    code: 'SGD',
    symbol: r'S$',
    name: 'Singapore Dollar',
    quickAmounts: [10, 20, 50, 100, 500],
  );
  static const aud = AppCurrency(
    code: 'AUD',
    symbol: r'A$',
    name: 'Australian Dollar',
    quickAmounts: [10, 20, 50, 100, 500],
  );
  static const cad = AppCurrency(
    code: 'CAD',
    symbol: r'C$',
    name: 'Canadian Dollar',
    quickAmounts: [10, 20, 50, 100, 500],
  );
  static const chf = AppCurrency(
    code: 'CHF',
    symbol: 'CHF',
    name: 'Swiss Franc',
    quickAmounts: [10, 20, 50, 100, 500],
  );
  static const inr = AppCurrency(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
    quickAmounts: [100, 500, 1000, 5000, 10000],
  );
  static const hkd = AppCurrency(
    code: 'HKD',
    symbol: r'HK$',
    name: 'Hong Kong Dollar',
    quickAmounts: [100, 200, 500, 1000, 5000],
  );
  static const myr = AppCurrency(
    code: 'MYR',
    symbol: 'RM',
    name: 'Malaysian Ringgit',
    quickAmounts: [10, 50, 100, 500, 1000],
  );
  static const idr = AppCurrency(
    code: 'IDR',
    symbol: 'Rp',
    name: 'Indonesian Rupiah',
    decimals: 0,
    thousandsSep: '.',
    decimalSep: ',',
    quickAmounts: [50000, 100000, 500000, 1000000, 5000000],
  );
  static const php = AppCurrency(
    code: 'PHP',
    symbol: '₱',
    name: 'Philippine Peso',
    quickAmounts: [100, 500, 1000, 5000, 10000],
  );
  static const twd = AppCurrency(
    code: 'TWD',
    symbol: r'NT$',
    name: 'New Taiwan Dollar',
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
