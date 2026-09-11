import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/fetch_news_usecase.dart';
import 'news_state.dart';

/// Owns the news feed: fetches the persisted headline list and handles the
/// loading / error / loaded transition.
class NewsCubit extends Cubit<NewsState> {
  NewsCubit({required FetchNewsUseCase fetchNews})
    : _fetchNews = fetchNews,
      super(const NewsInitial());

  final FetchNewsUseCase _fetchNews;

  Future<void> load() async {
    emit(const NewsLoading());
    try {
      final articles = await _fetchNews();
      emit(NewsLoaded(articles: articles));
    } catch (error) {
      emit(NewsError(error.toString().split(':').last.trim()));
    }
  }
}