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
  });

  final PortfolioOverview overview;
  final List<ConfigRow> config;
  final bool runningSession;
  final String? sessionMessage;
}

class TradingError extends TradingState {
  const TradingError(this.message);

  final String message;
}
