import 'package:dio/dio.dart';

import '../../domain/entities/broker.dart';
import '../../domain/entities/broker_account.dart';
import '../../domain/entities/broker_authorization.dart';

/// Thin HTTP client for the broker endpoints. Responses use the Laravel
/// envelope `{success, message, data}` — parsers read [data].
class BrokerApi {
  BrokerApi({required this.dio, required this.baseUrl});

  final Dio dio;
  final String baseUrl;

  Future<List<Broker>> fetchBrokers() async {
    final response = await dio.get('$baseUrl/api/brokers');
    return _list(_listData(response.data))
        .map(Broker.fromJson)
        .toList(growable: false);
  }

  Future<List<BrokerAccount>> fetchAccounts() async {
    final response = await dio.get('$baseUrl/api/broker/accounts');
    return _list(_listData(response.data))
        .map(BrokerAccount.fromJson)
        .toList(growable: false);
  }

  Future<BrokerAccount> fetchStatus(String tradingAccountId) async {
    final response = await dio.get('$baseUrl/api/broker/status/$tradingAccountId');
    return BrokerAccount.fromJson({
      'id': tradingAccountId,
      ..._data(response.data),
    });
  }

  Future<BrokerAuthorization> getAuthorization(
    String tradingAccountId,
    String slug,
  ) async {
    final response = await dio.get(
      '$baseUrl/api/broker/connect/$tradingAccountId/$slug',
    );
    return BrokerAuthorization.fromJson(_data(response.data));
  }

  Future<void> disconnect(String tradingAccountId) async {
    await dio.delete('$baseUrl/api/broker/disconnect/$tradingAccountId');
  }

  /// Connects a Kotak Neo account directly with credentials (no OAuth
  /// redirect): the backend logs in with [mobileNumber]/[ucc]/[totp], then
  /// validates the session with [mpin], in one round trip.
  Future<void> kotakConnect(
    String tradingAccountId, {
    required String mobileNumber,
    required String ucc,
    required String totp,
    required String mpin,
  }) async {
    await dio.post(
      '$baseUrl/api/broker/connect/$tradingAccountId/kotak',
      data: {
        'mobile_number': mobileNumber,
        'ucc': ucc,
        'totp': totp,
        'mpin': mpin,
      },
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<String> authorizeFeed(String tradingAccountId, String type) async {
    final response = await dio.get(
      '$baseUrl/api/broker/feed/$tradingAccountId/$type',
    );
    return _data(response.data)['uri'] as String? ?? '';
  }
}

Map<String, dynamic> _data(Object? body) {
  if (body is! Map<String, dynamic>) {
    return const {};
  }
  final data = body['data'];
  return data is Map<String, dynamic> ? data : const {};
}

Object? _listData(Object? body) {
  if (body is! Map<String, dynamic>) {
    return const [];
  }
  return body['data'];
}

List<Map<String, dynamic>> _list(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}