import 'package:uuid/uuid.dart';

import 'feed_streamer.dart';

/// Live market data feed (Upstox V3) — mirror of `MarketDataFeederV3`.
///
/// Requests are JSON objects `{guid, method, data:{instrumentKeys, mode}}`
/// using the documented methods: `sub`, `change_mode`, `unsub`. Incoming
/// payloads are JSON market data snapshots emitted as [FeedMessage].
class MarketDataStreamer extends FeedStreamer {
  static const String modeLtpc = 'ltpc';
  static const String modeFull = 'full';
  static const String modeOptionGreeks = 'option_greeks';
  static const String modeFullD30 = 'full_d30';

  static const List<String> modes = [
    modeLtpc,
    modeFull,
    modeOptionGreeks,
    modeFullD30,
  ];

  final Uuid _uuid = const Uuid();

  /// Subscribe to instrument keys (e.g. `NSE_INDEX|Nifty 50`) in a mode.
  void subscribe(List<String> instrumentKeys, {String mode = modeLtpc}) {
    send(buildRequest('sub', instrumentKeys, mode));
  }

  /// Change the subscription mode for the given instrument keys.
  void changeMode(List<String> instrumentKeys, String newMode) {
    send(buildRequest('change_mode', instrumentKeys, newMode));
  }

  /// Unsubscribe from the given instrument keys.
  void unsubscribe(List<String> instrumentKeys) {
    send(buildRequest('unsub', instrumentKeys));
  }

  /// Build a JSON request payload (exposed for testing).
  Map<String, Object> buildRequest(
    String method,
    List<String> instrumentKeys, [
    String? mode,
  ]) => {
    'guid': _uuid.v4(),
    'method': method,
    'data': {
      'instrumentKeys': instrumentKeys,
      'mode': ?mode,
    },
  };
}