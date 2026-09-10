import 'package:banker_trader/features/broker/data/sources/market_data_streamer.dart';
import 'package:banker_trader/features/broker/domain/entities/broker_account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrokerAccount.fromJson', () {
    test('parses a connected live account', () {
      final account = BrokerAccount.fromJson({
        'id': '1f0f0f0f-aaaa-4b4b-8c8c-000000000001',
        'name': 'Live',
        'connected': true,
        'broker': {'slug': 'upstox', 'name': 'Upstox'},
        'connected_at': '2026-09-09T10:00:00+05:30',
        'mode': 'live',
      });

      expect(account.id, '1f0f0f0f-aaaa-4b4b-8c8c-000000000001');
      expect(account.name, 'Live');
      expect(account.connected, isTrue);
      expect(account.broker?.slug, 'upstox');
      expect(account.isLiveMode, isTrue);
    });

    test('parses a paper account without broker', () {
      final account = BrokerAccount.fromJson({
        'id': '1f0f0f0f-aaaa-4b4b-8c8c-000000000002',
        'name': 'Default',
        'connected': false,
        'broker': null,
        'mode': 'paper',
      });

      expect(account.connected, isFalse);
      expect(account.broker, isNull);
      expect(account.isLiveMode, isFalse);
    });
  });

  group('MarketDataStreamer.buildRequest', () {
    test('subscribe request includes the mode', () {
      final stream = MarketDataStreamer();
      final request = stream.buildRequest(
        'sub',
        ['NSE_INDEX|Nifty 50'],
        MarketDataStreamer.modeFull,
      );

      expect(request['method'], 'sub');
      final data = request['data'] as Map;
      expect(data['instrumentKeys'], ['NSE_INDEX|Nifty 50']);
      expect(data['mode'], 'full');
    });

    test('unsubscribe request omits the mode', () {
      final stream = MarketDataStreamer();
      final request = stream.buildRequest(
        'unsub',
        ['NSE_INDEX|Nifty 50'],
      );

      expect(request['method'], 'unsub');
      final data = request['data'] as Map;
      expect(data['instrumentKeys'], ['NSE_INDEX|Nifty 50']);
      expect(data.containsKey('mode'), isFalse);
    });

    test('every request has a unique guid', () {
      final stream = MarketDataStreamer();
      final first = stream.buildRequest('sub', ['A'])['guid'];
      final second = stream.buildRequest('sub', ['A'])['guid'];
      expect(first, isNot(second));
    });
  });
}