/// A persisted headline from the server's news feed (news_articles).
class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.sentiment,
    required this.sentimentScore,
    this.symbol,
    this.publisher,
    this.publishedAt,
    this.originalUrl,
    this.thumbnail,
    this.authors = const [],
    this.topics = const [],
  });

  final String id;
  final String? symbol;
  final String title;
  final String? publisher;
  final String? publishedAt;
  final String sentiment;
  final double sentimentScore;
  final String? originalUrl;
  final String? thumbnail;
  final List<String> authors;
  final List<String> topics;

  bool get isPositive => sentiment == 'positive';
  bool get isNegative => sentiment == 'negative';

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String?,
      title: json['title'] as String? ?? '',
      publisher: json['publisher'] as String?,
      publishedAt: json['published_at'] as String?,
      sentiment: json['sentiment'] as String? ?? 'neutral',
      sentimentScore: (json['sentiment_score'] as num?)?.toDouble() ?? 0,
      originalUrl: json['original_url'] as String?,
      thumbnail: json['thumbnail'] as String?,
      authors: _strings(json['authors']),
      topics: _strings(json['topics']),
    );
  }
}

List<String> _strings(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.whereType<String>().toList(growable: false);
}