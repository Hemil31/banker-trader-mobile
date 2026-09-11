import '../../domain/entities/news_article.dart';
import '../../domain/repositories/news_repository.dart';

class FetchNewsUseCase {
  FetchNewsUseCase({required NewsRepository repository})
    : _repository = repository;

  final NewsRepository _repository;

  Future<List<NewsArticle>> call({String? symbol}) =>
      _repository.fetchNews(symbol: symbol);
}