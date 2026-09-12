import 'package:dio/dio.dart';

import '../../domain/entities/config_row.dart';
import '../../domain/entities/portfolio_overview.dart';

/// Thin HTTP client for the trading endpoints. Responses use the Laravel
/// envelope `{success, message, data}` — parsers read [data].
class TradingApi {
  TradingApi({required this.dio, required this.baseUrl});

  final Dio dio;
  final String baseUrl;

  Future<PortfolioOverview> fetchPortfolio() async {
    final response = await dio.get('$baseUrl/api/portfolio');
    return PortfolioOverview.fromJson(_data(response.data));
  }

  Future<List<ConfigRow>> fetchConfig() async {
    final response = await dio.get('$baseUrl/api/trading/config');
    return _list(
      _data(response.data),
    ).map(ConfigRow.fromJson).toList(growable: false);
  }

  Future<Map<String, dynamic>> runPaperSession({List<int>? symbols}) async {
    final response = await dio.post(
      '$baseUrl/api/trading/run',
      data: symbols == null || symbols.isEmpty ? null : {'symbols': symbols},
      options: symbols == null
          ? null
          : Options(contentType: Headers.jsonContentType),
    );
    return _data(response.data);
  }

  /// Updates a single editable config row. Returns the coerced value the
  /// backend stored, so the caller can refresh just that row.
  Future<Object?> updateConfig(String key, Object value) async {
    final response = await dio.patch(
      '$baseUrl/api/trading/config',
      data: {'key': key, 'value': value},
      options: Options(contentType: Headers.jsonContentType),
    );
    return _data(response.data)['value'];
  }
}

Map<String, dynamic> _data(Object? body) {
  if (body is! Map<String, dynamic>) {
    return const {};
  }
  final data = body['data'];
  return data is Map<String, dynamic> ? data : const {};
}

List<Map<String, dynamic>> _list(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}
