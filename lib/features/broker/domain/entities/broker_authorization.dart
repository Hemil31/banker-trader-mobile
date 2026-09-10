/// OAuth launch URL for a broker (from `GET /api/broker/connect/...`).
class BrokerAuthorization {
  const BrokerAuthorization({required this.authorizationUrl});

  final String authorizationUrl;

  factory BrokerAuthorization.fromJson(Map<String, dynamic> json) =>
      BrokerAuthorization(authorizationUrl: json['authorization_url'] as String? ?? '');
}