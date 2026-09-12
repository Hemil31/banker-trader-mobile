import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:banker_trader/features/trading/domain/entities/account.dart';
import 'package:banker_trader/features/trading/domain/entities/config_row.dart';
import 'package:banker_trader/features/trading/domain/entities/portfolio_overview.dart';
import 'package:banker_trader/features/trading/domain/entities/portfolio_summary.dart';
import 'package:banker_trader/features/trading/domain/repositories/trading_repository.dart';
import 'package:banker_trader/features/trading/domain/usecases/fetch_config_usecase.dart';
import 'package:banker_trader/features/trading/domain/usecases/fetch_portfolio_usecase.dart';
import 'package:banker_trader/features/trading/domain/usecases/run_paper_session_usecase.dart';
import 'package:banker_trader/features/trading/domain/usecases/update_config_usecase.dart';
import 'package:banker_trader/features/trading/presentation/pages/config_tab.dart';
import 'package:banker_trader/features/trading/presentation/state/trading_cubit.dart';
import 'package:banker_trader/features/trading/presentation/state/trading_state.dart';

/// Records every `updateConfig` call so tests can assert the cubit reached
/// the repository with the right key/value.
class _FakeTradingRepository implements TradingRepository {
  final calls = <(String, Object)>[];

  @override
  Future<PortfolioOverview> fetchPortfolio() async => _overview;

  @override
  Future<List<ConfigRow>> fetchConfig() async => _rows;

  @override
  Future<PaperRunResult> runPaperSession({List<int>? symbols}) async =>
      const PaperRunResult(
        signalsGenerated: 0,
        marketOk: true,
        entered: 0,
        blocked: 0,
        monitored: 0,
        exits: 0,
      );

  @override
  Future<Object?> updateConfig(String key, Object value) async {
    calls.add((key, value));
    return value;
  }
}

final _overview = PortfolioOverview(
  account: const Account(
    id: 'acc-1',
    name: 'Paper Trading',
    mode: 'paper',
    startingCapital: 100000,
    availableCash: 50000,
    investedAmount: 50000,
  ),
  portfolio: const PortfolioSummary(
    invested: 50000,
    unrealized: 0,
    realized: 0,
    grossEquity: 100000,
    netEquity: 100000,
    openPositionsCount: 0,
  ),
  openPositions: const [],
  recentSignals: const [],
  recentPaperTrades: const [],
  marketBars: 0,
);

const _rows = [
  ConfigRow(
    key: 'entry.auto_enabled',
    group: 'Entry',
    type: 'boolean',
    value: false,
    label: 'Auto entries',
    isEditable: true,
  ),
  ConfigRow(
    key: 'risk.daily_target_pct',
    group: 'Risk',
    type: 'float',
    value: 5.0,
    label: 'Daily target %',
    isEditable: true,
  ),
  ConfigRow(
    key: 'strategy.name',
    group: 'Strategy',
    type: 'string',
    value: 'momentum',
    label: 'Strategy name',
    isEditable: false,
  ),
];

/// Wraps [ConfigTab] with the same `BlocProvider` + `BlocBuilder` wiring
/// `TradingHomePage` uses, so cubit emissions from `updateConfig` drive a
/// real rebuild instead of a static, prop-frozen state.
Widget _buildHarness(TradingCubit cubit) {
  return MaterialApp(
    home: Scaffold(
      body: BlocProvider<TradingCubit>.value(
        value: cubit,
        child: BlocBuilder<TradingCubit, TradingState>(
          builder: (context, state) {
            if (state is! TradingLoaded) return const SizedBox.shrink();
            return ConfigTab(state: state, onRefresh: () async {});
          },
        ),
      ),
    ),
  );
}

TradingCubit _buildCubit(_FakeTradingRepository repo) => TradingCubit(
  fetchPortfolio: FetchPortfolioUseCase(repository: repo),
  fetchConfig: FetchConfigUseCase(repository: repo),
  runPaperSession: RunPaperSessionUseCase(repository: repo),
  updateConfig: UpdateConfigUseCase(repository: repo),
)..emit(
  TradingLoaded(overview: _overview, config: _rows, runningSession: false),
);

void main() {
  testWidgets(
    'toggling a boolean switch calls updateConfig and reflects the new value',
    (tester) async {
      final repo = _FakeTradingRepository();
      final cubit = _buildCubit(repo);

      await tester.pumpWidget(_buildHarness(cubit));
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      // Read-only string row is untouched.
      expect(find.text('momentum'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(repo.calls, [('entry.auto_enabled', true)]);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

      await cubit.close();
    },
  );

  testWidgets('editing a numeric field and tapping save calls updateConfig', (
    tester,
  ) async {
    final repo = _FakeTradingRepository();
    final cubit = _buildCubit(repo);

    await tester.pumpWidget(_buildHarness(cubit));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '7.5');
    await tester.tap(find.byIcon(Icons.check_circle_outline));
    await tester.pumpAndSettle();

    expect(repo.calls, [('risk.daily_target_pct', 7.5)]);

    await cubit.close();
  });

  testWidgets('non-editable rows have no interactive controls', (
    tester,
  ) async {
    final repo = _FakeTradingRepository();
    final cubit = _buildCubit(repo);

    await tester.pumpWidget(_buildHarness(cubit));
    await tester.pumpAndSettle();

    // Only the two editable rows produce controls: one switch, one text field.
    expect(find.byType(Switch), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('momentum'), findsOneWidget);

    await cubit.close();
  });
}
