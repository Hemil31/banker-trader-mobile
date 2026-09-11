import 'package:banker_trader/features/news/domain/entities/news_article.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewsArticle.fromJson', () {
    test('parses a full enriched article', () {
      final article = NewsArticle.fromJson({
        'id': '1f0f0f0f-aaaa-4b4b-8c8c-000000000001',
        'symbol': 'SBIN',
        'title': 'SBIN surges to record high',
        'publisher': 'Reuters',
        'published_at': '2026-09-10T07:00:00.000Z',
        'sentiment': 'positive',
        'sentiment_score': 90,
        'original_url': 'https://example.com/sbin',
        'thumbnail': 'https://example.com/thumb.jpg',
        'authors': ['Jane Trader'],
        'topics': ['markets', 'banking'],
      });

      expect(article.symbol, 'SBIN');
      expect(article.title, 'SBIN surges to record high');
      expect(article.sentiment, 'positive');
      expect(article.sentimentScore, 90);
      expect(article.originalUrl, 'https://example.com/sbin');
      expect(article.authors, ['Jane Trader']);
      expect(article.topics, ['markets', 'banking']);
      expect(article.isPositive, isTrue);
      expect(article.isNegative, isFalse);
    });

    test('parses a bare article with neutral defaults', () {
      final article = NewsArticle.fromJson({
        'id': '1f0f0f0f-aaaa-4b4b-8c8c-000000000002',
        'title': 'Firm schedules annual meeting',
      });

      expect(article.symbol, isNull);
      expect(article.title, 'Firm schedules annual meeting');
      expect(article.sentiment, 'neutral');
      expect(article.sentimentScore, 0);
      expect(article.originalUrl, isNull);
      expect(article.authors, isEmpty);
      expect(article.isPositive, isFalse);
      expect(article.isNegative, isFalse);
    });
  });
}