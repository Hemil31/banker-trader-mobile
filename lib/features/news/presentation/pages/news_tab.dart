import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
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
          NewsLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          NewsError() => ErrorView(
            message: state.message,
            onRetry: () => context.read<NewsCubit>().load(),
          ),
          NewsLoaded() => RefreshIndicator(
            color: AppColors.accent,
            onRefresh: onRefresh,
            child: state.articles.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      EmptyHint(
                        'No news yet — check back soon.',
                        icon: Icons.newspaper_outlined,
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpace.lg),
                    itemCount: state.articles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpace.sm),
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
    final sentimentPill = article.isPositive
        ? PillBadge.positive(article.sentiment, dense: true)
        : article.isNegative
        ? PillBadge.negative(article.sentiment, dense: true)
        : PillBadge.neutral(article.sentiment, dense: true);

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
          padding: const EdgeInsets.all(AppSpace.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumb(article: article),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(size: 13.5, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (article.symbol != null)
                          Text(
                            article.symbol!,
                            style: AppFonts.body(
                              size: 11,
                              weight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        if (article.publisher != null &&
                            article.publisher!.isNotEmpty)
                          Text(
                            article.publisher!,
                            style: AppFonts.body(size: 11, color: AppColors.textMuted),
                          ),
                        Text(
                          _relativeTime(article.publishedAt),
                          style: AppFonts.body(size: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    sentimentPill,
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
        borderRadius: BorderRadius.circular(AppRadius.sm),
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
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Icon(
        Icons.article_outlined,
        size: 26,
        color: AppColors.textMuted,
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
