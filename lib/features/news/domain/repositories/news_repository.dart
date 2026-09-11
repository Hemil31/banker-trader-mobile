import '../entities/news_article.dart';

abstract interface class NewsRepository {
  Future<List<NewsArticle>> fetchNews({String? symbol});
}