import '../../domain/entities/news_article.dart';
import '../../domain/repositories/news_repository.dart';
import '../sources/news_api.dart';

class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl({required this.api});

  final NewsApi api;

  @override
  Future<List<NewsArticle>> fetchNews({String? symbol}) =>
      api.fetchNews(symbol: symbol);
}