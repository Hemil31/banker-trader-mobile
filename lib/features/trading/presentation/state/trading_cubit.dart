import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/config_row.dart';
import '../../domain/usecases/fetch_config_usecase.dart';
import '../../domain/usecases/fetch_portfolio_usecase.dart';
import '../../domain/usecases/run_paper_session_usecase.dart';
import 'trading_state.dart';

/// Owns the trading dashboard data: portfolio overview, editable config and
/// the manual paper-session run.
class TradingCubit extends Cubit<TradingState> {
  TradingCubit({
    required FetchPortfolioUseCase fetchPortfolio,
    required FetchConfigUseCase fetchConfig,
    required RunPaperSessionUseCase runPaperSession,
  }) : _fetchPortfolio = fetchPortfolio,
       _fetchConfig = fetchConfig,
       _runPaperSession = runPaperSession,
       super(const TradingInitial());

  final FetchPortfolioUseCase _fetchPortfolio;
  final FetchConfigUseCase _fetchConfig;
  final RunPaperSessionUseCase _runPaperSession;

  Future<void> load({bool withConfig = false}) async {
    emit(const TradingLoading());
    try {
      final overview = await _fetchPortfolio();
      final config = withConfig || _hasConfig()
          ? await _fetchConfig()
          : const <ConfigRow>[];
      emit(
        TradingLoaded(
          overview: overview,
          config: config,
          runningSession: false,
        ),
      );
    } catch (error) {
      emit(TradingError(_message(error)));
    }
  }

  Future<void> runSession() async {
    final current = state;
    if (current is! TradingLoaded || current.runningSession) {
      return;
    }
    emit(
      TradingLoaded(
        overview: current.overview,
        config: current.config,
        runningSession: true,
      ),
    );
    try {
      final result = await _runPaperSession();
      final overview = await _fetchPortfolio();
      emit(
        TradingLoaded(
          overview: overview,
          config: current.config,
          runningSession: false,
          sessionMessage:
              '${result.entered} entered · ${result.blocked} blocked · '
              '${result.monitored} monitored · ${result.exits} exits',
        ),
      );
    } catch (error) {
      emit(
        TradingLoaded(
          overview: current.overview,
          config: current.config,
          runningSession: false,
          sessionMessage: _message(error),
        ),
      );
    }
  }

  bool _hasConfig() {
    final current = state;
    return current is TradingLoaded && current.config.isNotEmpty;
  }

  String _message(Object error) => error.toString().split(':').last.trim();
}
