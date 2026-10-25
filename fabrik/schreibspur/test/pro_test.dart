import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schreibspur/pro.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pro', () {
    late SharedPreferences prefs;
    late FakeProBackend backend;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      backend = FakeProBackend();
    });

    test('starts free with store prices', () async {
      final pro = Pro(prefs, backend);
      await pro.start();
      expect(pro.isPro, isFalse);
      expect(pro.storeReady, isTrue);
      expect(pro.yearlyPrice, '4,99 €');
      expect(pro.lifetimePrice, '12,99 €');
      expect(pro.wordLimit, freeWords);
    });

    test('buying lifetime unlocks Pro and is remembered', () async {
      final pro = Pro(prefs, backend);
      await pro.start();
      await pro.buy(proLifetimeId);
      expect(pro.isPro, isTrue);
      expect(pro.wordLimit, proWords);
      expect(Pro(prefs, backend).isPro, isTrue, reason: 'cached for offline starts');
    });

    test('an expired subscription drops Pro on refresh', () async {
      final pro = Pro(prefs, backend);
      await pro.buy(proYearlyId);
      expect(pro.isPro, isTrue);
      backend.owned = []; // year is over, not renewed
      await pro.refresh();
      expect(pro.isPro, isFalse);
    });

    test('cancelled and pending purchases do not unlock', () async {
      final pro = Pro(prefs, backend);
      backend.next = PurchaseResult.cancelled;
      await pro.buy(proYearlyId);
      expect(pro.isPro, isFalse);
      expect(pro.state, ProState.idle);
      backend.next = PurchaseResult.pending;
      await pro.buy(proYearlyId);
      expect(pro.isPro, isFalse);
      expect(pro.state, ProState.pending);
    });

    test('restore finds an earlier purchase or says there is none', () async {
      final pro = Pro(prefs, backend);
      await pro.restore();
      expect(pro.state, ProState.nothingToRestore);
      backend.owned = [proLifetimeId];
      await pro.restore();
      expect(pro.isPro, isTrue);
    });

    test('without a store the cached state stays and fallback prices show', () async {
      prefs.setBool('pro', true);
      final pro = Pro(prefs, _ThrowingBackend());
      await pro.start();
      expect(pro.isPro, isTrue);
      expect(pro.storeReady, isFalse);
      expect(pro.lifetimePrice, fallbackLifetimePrice);
    });

    test('product ids use the bundle id', () {
      expect(proIds, [
        'com.lukasbeutler.schreibspur.pro.yearly',
        'com.lukasbeutler.schreibspur.pro.lifetime',
      ]);
    });

    test('native backend talks to the bridge', () async {
      const ch = MethodChannel('schreibspur/apple');
      final m = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      m.setMockMethodCallHandler(ch, (call) async => switch (call.method) {
            'products' => [
                {'id': proYearlyId, 'price': '4,99 €', 'kind': 'subscription'},
              ],
            'purchase' => 'purchased',
            'entitlements' => [proYearlyId],
            _ => null,
          });
      addTearDown(() => m.setMockMethodCallHandler(ch, null));
      final be = AppleProBackend();
      expect((await be.prices(proIds))[proYearlyId], '4,99 €');
      expect(await be.purchase(proYearlyId), PurchaseResult.purchased);
      expect(await be.entitlements(), [proYearlyId]);
    });
  });
}

class _ThrowingBackend implements ProBackend {
  @override
  Future<Map<String, String>> prices(List<String> ids) => throw Exception();
  @override
  Future<PurchaseResult> purchase(String id) => throw Exception();
  @override
  Future<List<String>> entitlements() => throw Exception();
  @override
  Future<List<String>> restore() => throw Exception();
}
