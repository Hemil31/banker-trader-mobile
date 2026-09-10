import 'dart:async';

import 'feed_streamer.dart';

/// Live portfolio feed (orders/holdings/positions) — mirror of
/// `PortfolioDataFeeder`. Incoming payloads are JSON objects like
/// `{"data": {"type": "order|holding|position", ...}}`.
class PortfolioStreamer extends FeedStreamer {
  PortfolioStreamer({
    super.autoReconnect,
    super.maxRetries,
    super.reconnectDelay,
  });

  /// Events filtered to a single payload type (order/holding/position).
  Stream<Map<String, dynamic>> messagesOf(String type) => events
      .where((e) => e is FeedMessage)
      .cast<FeedMessage>()
      .map((e) => e.payload)
      .where((p) => p is Map<String, dynamic> && p['type'] == type)
      .cast<Map<String, dynamic>>();
}