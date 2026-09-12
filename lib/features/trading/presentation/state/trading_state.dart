import '../../domain/entities/config_row.dart';
import '../../domain/entities/portfolio_overview.dart';

sealed class TradingState {
  const TradingState();
}

class TradingInitial extends TradingState {
  const TradingInitial();
}

class TradingLoading extends TradingState {
  const TradingLoading();
}

class TradingLoaded extends TradingState {
  const TradingLoaded({
    required this.overview,
    required this.config,
    required this.runningSession,
    this.sessionMessage,
    this.updatingConfigKeys = const {},
    this.configMessage,
  });

  final PortfolioOverview overview;
  final List<ConfigRow> config;
  final bool runningSession;
  final String? sessionMessage;

  /// Keys of config rows with an in-flight `updateConfig` call — drives the
  /// per-row loading indicator in the Config tab.
  final Set<String> updatingConfigKeys;

  /// Transient error message from the last `updateConfig` failure, shown
  /// once as a snackbar then cleared.
  final String? configMessage;

  TradingLoaded copyWith({
    PortfolioOverview? overview,
    List<ConfigRow>? config,
    bool? runningSession,
    String? sessionMessage,
    Set<String>? updatingConfigKeys,
    String? configMessage,
    bool clearConfigMessage = false,
  }) => TradingLoaded(
    overview: overview ?? this.overview,
    config: config ?? this.config,
    runningSession: runningSession ?? this.runningSession,
    sessionMessage: sessionMessage ?? this.sessionMessage,
    updatingConfigKeys: updatingConfigKeys ?? this.updatingConfigKeys,
    configMessage: clearConfigMessage
        ? null
        : (configMessage ?? this.configMessage),
  );
}

class TradingError extends TradingState {
  const TradingError(this.message);

  final String message;
}
