import '../../domain/entities/news_article.dart';

sealed class NewsState {
  const NewsState();
}

class NewsInitial extends NewsState {
  const NewsInitial();
}

class NewsLoading extends NewsState {
  const NewsLoading();
}

class NewsLoaded extends NewsState {
  const NewsLoaded({required this.articles});

  final List<NewsArticle> articles;
}

class NewsError extends NewsState {
  const NewsError(this.message);

  final String message;
}