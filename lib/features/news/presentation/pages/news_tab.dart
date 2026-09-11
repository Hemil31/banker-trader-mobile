import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../trading/presentation/widgets/common_widgets.dart';
import '../../domain/entities/news_article.dart';
import '../state/news_cubit.dart';
import '../state/news_state.dart';
import 'article_webview_page.dart';

/// News feed tab: persisted headlines from the server (news_articles), newest
/// first, with a keyword sentiment chip and tap-through to the original URL.
class NewsTab extends StatelessWidget {
  const NewsTab({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        return switch (state) {
          NewsInitial() => const SizedBox.shrink(),
          NewsLoading() => const Center(child: CircularProgressIndicator()),
          NewsError() => ErrorView(
            message: state.message,
            onRetry: () => context.read<NewsCubit>().load(),
          ),
          NewsLoaded() => RefreshIndicator(
            onRefresh: onRefresh,
            child: state.articles.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      EmptyHint('No news yet — check back soon.'),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: state.articles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _NewsCard(article: state.articles[index]),
                  ),
          ),
        };
      },
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sentimentColor = article.isPositive
        ? Colors.green.shade700
        : article.isNegative
        ? Colors.red.shade700
        : Colors.blueGrey;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: article.originalUrl == null || article.originalUrl!.isEmpty
            ? null
            : () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ArticleWebViewPage(
                  title: article.symbol ?? 'News',
                  url: article.originalUrl!,
                ),
              ),
            ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumb(article: article),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (article.symbol != null)
                          Text(
                            article.symbol!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (article.publisher != null &&
                            article.publisher!.isNotEmpty)
                          Text(
                            article.publisher!,
                            style: theme.textTheme.bodySmall,
                          ),
                        Text(
                          _relativeTime(article.publishedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _SentimentChip(
                      label: article.sentiment,
                      color: sentimentColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final url = article.thumbnail;
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _ThumbFallback(),
        ),
      );
    }
    return const _ThumbFallback();
  }
}

class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.article_outlined, size: 28),
    );
  }
}

class _SentimentChip extends StatelessWidget {
  const _SentimentChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _relativeTime(String? iso) {
  final time = DateTime.tryParse(iso ?? '');
  if (time == null) {
    return '';
  }
  final diff = DateTime.now().difference(time.toLocal());
  if (diff.inMinutes < 1) {
    return 'just now';
  }
  if (diff.inHours < 1) {
    return '${diff.inMinutes}m ago';
  }
  if (diff.inDays < 1) {
    return '${diff.inHours}h ago';
  }
  return '${diff.inDays}d ago';
}