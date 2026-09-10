import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Base class for the Upstox live feed consumers.
///
/// Handles authorization, WebSocket lifecycle and automatic reconnection.
/// Subclasses parse the concrete payloads. Lifecycle is exposed through
/// [events] as a stream of [FeedEvent].
abstract class FeedStreamer {
  FeedStreamer({
    this.autoReconnect = true,
    this.maxRetries = 5,
    this.reconnectDelay = const Duration(seconds: 3),
  });

  final bool autoReconnect;
  final int maxRetries;
  final Duration reconnectDelay;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  StreamController<FeedEvent>? _controller;
  Uri? _uri;
  int _retries = 0;
  bool _closed = true;

  /// Live connection events. Broadcast — safe for multiple listeners.
  Stream<FeedEvent> get events {
    _controller ??= StreamController<FeedEvent>.broadcast();
    return _controller!.stream;
  }

  bool get isConnected => _channel != null;

  /// Connect to the authorized WebSocket URI.
  Future<void> connect(Uri uri) async {
    _uri = uri;
    _closed = false;

    final channel = WebSocketChannel.connect(uri);
    _channel = channel;

    _subscription?.cancel();
    _subscription = channel.stream.listen(
      _onRaw,
      onError: (Object error, StackTrace stack) => _emit(FeedError(error, stack)),
      onDone: _onDone,
    );

    _emit(FeedOpen(uri));
  }

  /// Disconnect and stop reconnecting.
  Future<void> close() async {
    _closed = true;
    _retries = 0;
    _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
  }

  /// Send a text payload (JSON-encoded unless already a string). No-ops when
  /// disconnected.
  void send(Object payload) {
    _channel?.sink.add(
      payload is String ? payload : jsonEncode(payload),
    );
  }

  void _onRaw(dynamic data) {
    _retries = 0;

    if (data is String && data == '100') {
      // Server heartbeat — acknowledge to keep the session alive.
      _channel?.sink.add('100');
      _emit(const FeedHeartbeat());
      return;
    }

    Object message;
    try {
      message = jsonDecode(
        data is String ? data : utf8.decode((data as List<int>).toList()),
      );
    } catch (_) {
      message = data;
    }

    _emit(FeedMessage(message));
  }

  void _onDone() {
    _channel = null;

    if (_closed) {
      _emit(const FeedClosed('closed'));
      return;
    }

    if (autoReconnect && _retries < maxRetries) {
      _retries++;
      _emit(FeedError(StateError('Connection lost; reconnecting…')));
      final uri = _uri;
      Future<void>.delayed(reconnectDelay, () {
        if (!_closed && uri != null) {
          connect(uri);
        }
      });
      return;
    }

    _emit(const FeedClosed('closed'));
  }

  void _emit(FeedEvent event) {
    if (!_controller!.isClosed) {
      _controller!.add(event);
    }
  }
}

/// Discriminated union of WebSocket lifecycle events.
sealed class FeedEvent {
  const FeedEvent();
}

class FeedOpen extends FeedEvent {
  const FeedOpen(this.uri);

  final Uri uri;
}

class FeedMessage extends FeedEvent {
  const FeedMessage(this.payload);

  /// Decoded JSON payload (map/list) — anything successfully JSON-decoded.
  final Object payload;
}

class FeedHeartbeat extends FeedEvent {
  const FeedHeartbeat();
}

class FeedError extends FeedEvent {
  const FeedError(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;
}

class FeedClosed extends FeedEvent {
  const FeedClosed(this.reason);

  final String reason;
}