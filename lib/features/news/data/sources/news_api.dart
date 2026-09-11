import 'package:dio/dio.dart';

import '../../domain/entities/news_article.dart';

/// Thin HTTP client for the news feed. The endpoint uses the Laravel
/// paginated envelope `{success, message, data: [...], pagination}`.
class NewsApi {
  NewsApi({required this.dio, required this.baseUrl});

  final Dio dio;
  final String baseUrl;

  Future<List<NewsArticle>> fetchNews({String? symbol}) async {
    final response = await dio.get(
      '$baseUrl/api/news',
      queryParameters:
          (symbol == null || symbol.isEmpty) ? null : {'symbol': symbol},
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      return const [];
    }
    final list = data['data'];
    if (list is! List) {
      return const [];
    }
    return list
        .whereType<Map<String, dynamic>>()
        .map(NewsArticle.fromJson)
        .toList(growable: false);
  }
}