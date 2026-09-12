import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/config_row.dart';
import '../../domain/usecases/fetch_config_usecase.dart';
import '../../domain/usecases/fetch_portfolio_usecase.dart';
import '../../domain/usecases/run_paper_session_usecase.dart';
import '../../domain/usecases/update_config_usecase.dart';
import 'trading_state.dart';

/// Owns the trading dashboard data: portfolio overview, editable config and
/// the manual paper-session run.
class TradingCubit extends Cubit<TradingState> {
  TradingCubit({
    required FetchPortfolioUseCase fetchPortfolio,
    required FetchConfigUseCase fetchConfig,
    required RunPaperSessionUseCase runPaperSession,
    required UpdateConfigUseCase updateConfig,
  }) : _fetchPortfolio = fetchPortfolio,
       _fetchConfig = fetchConfig,
       _runPaperSession = runPaperSession,
       _updateConfig = updateConfig,
       super(const TradingInitial());

  final FetchPortfolioUseCase _fetchPortfolio;
  final FetchConfigUseCase _fetchConfig;
  final RunPaperSessionUseCase _runPaperSession;
  final UpdateConfigUseCase _updateConfig;

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

  /// Updates a single config row (per-row loading, in-place refresh on
  /// success, transient [TradingLoaded.configMessage] on failure).
  Future<void> updateConfig(String key, Object value) async {
    final current = state;
    if (current is! TradingLoaded || current.updatingConfigKeys.contains(key)) {
      return;
    }
    emit(
      current.copyWith(
        updatingConfigKeys: {...current.updatingConfigKeys, key},
        clearConfigMessage: true,
      ),
    );
    try {
      final updatedValue = await _updateConfig(key, value);
      final latest = state;
      if (latest is! TradingLoaded) return;
      emit(
        latest.copyWith(
          config: [
            for (final row in latest.config)
              if (row.key == key) row.copyWith(value: updatedValue) else row,
          ],
          updatingConfigKeys: {...latest.updatingConfigKeys}..remove(key),
        ),
      );
    } catch (error) {
      final latest = state;
      if (latest is! TradingLoaded) return;
      emit(
        latest.copyWith(
          updatingConfigKeys: {...latest.updatingConfigKeys}..remove(key),
          configMessage: _message(error),
        ),
      );
    }
  }

  /// Dismiss the transient config-update error after it has been shown.
  void clearConfigMessage() {
    final current = state;
    if (current is TradingLoaded && current.configMessage != null) {
      emit(current.copyWith(clearConfigMessage: true));
    }
  }

  bool _hasConfig() {
    final current = state;
    return current is TradingLoaded && current.config.isNotEmpty;
  }

  String _message(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            return first.first.toString();
          }
        }
      }
    }
    return error.toString().split(':').last.trim();
  }
}
