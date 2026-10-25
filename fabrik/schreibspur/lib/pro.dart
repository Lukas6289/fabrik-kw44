import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App Store products (set up in App Store Connect):
/// - yearly: auto-renewable subscription, 4,99 € / year
/// - lifetime: non-consumable, 12,99 €
const proYearlyId = 'com.lukasbeutler.schreibspur.pro.yearly';
const proLifetimeId = 'com.lukasbeutler.schreibspur.pro.lifetime';
const proIds = [proYearlyId, proLifetimeId];

/// Fallback prices, only shown if the App Store does not answer.
const fallbackYearlyPrice = '4,99 €';
const fallbackLifetimePrice = '12,99 €';

/// Legal links required next to a subscription offer.
const termsUrl = 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
const privacyUrl = 'https://lukas6289.github.io/schreibspur/datenschutz.html';

/// What Pro unlocks. Kept in one place so the paywall and the gates agree.
const freeWords = 3;
const proWords = 12;

enum PurchaseResult { purchased, pending, cancelled }

/// Seam over StoreKit 2 (native, see ios/Runner/AppDelegate.swift).
abstract class ProBackend {
  Future<Map<String, String>> prices(List<String> ids);
  Future<PurchaseResult> purchase(String id);
  Future<List<String>> entitlements();
  Future<List<String>> restore();
}

class AppleProBackend implements ProBackend {
  AppleProBackend([MethodChannel? channel])
      : _ch = channel ?? const MethodChannel('schreibspur/apple');
  final MethodChannel _ch;

  @override
  Future<Map<String, String>> prices(List<String> ids) async {
    final r = await _ch.invokeListMethod<Map<Object?, Object?>>('products', {'ids': ids});
    return {
      for (final p in r ?? const <Map<Object?, Object?>>[])
        p['id'] as String: p['price'] as String,
    };
  }

  @override
  Future<PurchaseResult> purchase(String id) async {
    final r = await _ch.invokeMethod<String>('purchase', {'id': id});
    return switch (r) {
      'purchased' => PurchaseResult.purchased,
      'pending' => PurchaseResult.pending,
      _ => PurchaseResult.cancelled,
    };
  }

  @override
  Future<List<String>> entitlements() async =>
      (await _ch.invokeListMethod<String>('entitlements')) ?? const [];

  @override
  Future<List<String>> restore() async =>
      (await _ch.invokeListMethod<String>('restore')) ?? const [];
}

enum ProState { idle, busy, pending, failed, nothingToRestore }

class Pro extends ChangeNotifier {
  Pro(this._prefs, this._backend) {
    isPro = _prefs.getBool('pro') ?? false;
  }

  final SharedPreferences _prefs;
  final ProBackend _backend;

  late bool isPro;
  Map<String, String> _prices = const {};
  ProState state = ProState.idle;

  String get yearlyPrice => _prices[proYearlyId] ?? fallbackYearlyPrice;
  String get lifetimePrice => _prices[proLifetimeId] ?? fallbackLifetimePrice;
  bool get storeReady => _prices.isNotEmpty;

  int get wordLimit => isPro ? proWords : freeWords;

  /// Loads prices and the current entitlement. Without a store (tests,
  /// simulator, offline) the cached state stays.
  Future<void> start() async {
    try {
      _prices = await _backend.prices(proIds);
    } catch (_) {}
    await refresh();
  }

  /// Re-checks the entitlement, e.g. when the app comes back to the
  /// foreground. Expired subscriptions drop out here.
  Future<void> refresh() async {
    try {
      _apply(await _backend.entitlements());
    } catch (_) {}
    notifyListeners();
  }

  Future<void> buy(String id) async {
    state = ProState.busy;
    notifyListeners();
    try {
      switch (await _backend.purchase(id)) {
        case PurchaseResult.purchased:
          _apply(await _backend.entitlements(), orGrant: id);
          state = ProState.idle;
        case PurchaseResult.pending:
          state = ProState.pending;
        case PurchaseResult.cancelled:
          state = ProState.idle;
      }
    } catch (_) {
      state = ProState.failed;
    }
    notifyListeners();
  }

  Future<void> restore() async {
    state = ProState.busy;
    notifyListeners();
    try {
      final ids = await _backend.restore();
      _apply(ids);
      state = isPro ? ProState.idle : ProState.nothingToRestore;
    } catch (_) {
      state = ProState.failed;
    }
    notifyListeners();
  }

  void _apply(List<String> ids, {String? orGrant}) {
    isPro = ids.any(proIds.contains) || orGrant != null;
    _prefs.setBool('pro', isPro);
  }
}
