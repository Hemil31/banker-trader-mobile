/// A user trading account with its broker connection state
/// (from `GET /api/broker/accounts`).
class BrokerAccount {
  const BrokerAccount({
    required this.id,
    required this.name,
    required this.mode,
    required this.connected,
    this.broker,
    this.connectedAt,
  });

  final String id;
  final String name;
  final String mode;

  /// Whether the account has a live broker token attached.
  final bool connected;

  /// The connected broker slug/name, when connected.
  final ConnectableBrokerDetail? broker;
  final String? connectedAt;

  bool get isLiveMode => connected && mode == 'live';

  factory BrokerAccount.fromJson(Map<String, dynamic> json) {
    final broker = json['broker'];
    return BrokerAccount(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Default',
      mode: json['mode'] as String? ?? 'paper',
      connected: json['connected'] as bool? ?? false,
      broker: broker is Map<String, dynamic>
          ? ConnectableBrokerDetail.fromJson(broker)
          : null,
      connectedAt: json['connected_at'] as String?,
    );
  }
}

class ConnectableBrokerDetail {
  const ConnectableBrokerDetail({required this.slug, required this.name});

  final String slug;
  final String name;

  factory ConnectableBrokerDetail.fromJson(Map<String, dynamic> json) =>
      ConnectableBrokerDetail(
        slug: json['slug'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );
}