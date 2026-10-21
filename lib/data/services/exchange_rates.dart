import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRates extends ChangeNotifier {
  ExchangeRates._();
  static final ExchangeRates instance = ExchangeRates._();

  static const _ratesKey = 'exchangeRates';
  static const _updatedKey = 'exchangeRatesAt';
  static const _url = 'https://open.er-api.com/v6/latest/USD';
  static const _staleAfter = Duration(hours: 12);

  static const Map<String, double> _defaults = {
    'USD': 1,
    'VND': 26300,
    'EUR': 0.86,
    'GBP': 0.75,
    'JPY': 150,
    'CNY': 7.1,
    'KRW': 1450,
    'THB': 32.5,
    'SGD': 1.3,
    'AUD': 1.52,
    'CAD': 1.38,
    'CHF': 0.8,
    'INR': 88,
    'HKD': 7.78,
    'MYR': 4.2,
    'IDR': 16500,
    'PHP': 58,
    'TWD': 31,
  };

  Map<String, double> _rates = Map.of(_defaults);
  DateTime? _updatedAt;
  bool _loaded = false;
  bool _refreshing = false;

  DateTime? get updatedAt => _updatedAt;
  bool get isDefault => _updatedAt == null;
  bool get refreshing => _refreshing;
  bool get isStale {
    final at = _updatedAt;
    return at == null || DateTime.now().difference(at) > _staleAfter;
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ratesKey);
    final at = prefs.getInt(_updatedKey);
    if (raw == null || at == null) return;
    try {
      final map = (jsonDecode(raw) as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
      if (AppCurrency.all.every((c) => (map[c.code] ?? 0) > 0)) {
        _rates = map;
        _updatedAt = DateTime.fromMillisecondsSinceEpoch(at);
        notifyListeners();
      }
    } catch (_) {
      return;
    }
  }

  double rate(AppCurrency from, AppCurrency to) =>
      _rates[to.code]! / _rates[from.code]!;

  double convert(double amount, AppCurrency from, AppCurrency to) =>
      amount * rate(from, to);

  Future<bool> refresh() async {
    if (_refreshing) return false;
    await ensureLoaded();
    _refreshing = true;
    notifyListeners();
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client.getUrl(Uri.parse(_url));
      final response = await request.close().timeout(
        const Duration(seconds: 12),
      );
      if (response.statusCode != 200) return false;
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 12));
      final json = jsonDecode(body) as Map<String, dynamic>;
      if (json['result'] != 'success') return false;
      final raw = json['rates'] as Map<String, dynamic>;
      final fresh = <String, double>{};
      for (final currency in AppCurrency.all) {
        final value = raw[currency.code];
        if (value is! num || value <= 0) return false;
        fresh[currency.code] = value.toDouble();
      }
      _rates = fresh;
      _updatedAt = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_ratesKey, jsonEncode(fresh));
      await prefs.setInt(_updatedKey, _updatedAt!.millisecondsSinceEpoch);
      return true;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
      _refreshing = false;
      notifyListeners();
    }
  }
}
