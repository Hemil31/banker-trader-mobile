# BankerTrader — Flutter Client

Flutter trading client for the [BankerTrader backend](https://github.com/Hemil31/banker-trader-web). Each user authenticates with their own **Upstox** account via OAuth; trades are executed against that account's broker.

## Features

- Per-user Upstox OAuth linking (`BrokerOAuthPage`) — account ids are UUID **strings**
- Paper trading with live-style portfolio/positions/PnL
- Live Upstox integration (feed, orders, holdings) gated behind scopes
- Broker account management: create, connect, disconnect, status

## Setup

```bash
flutter pub get
flutter run
```

Requires a running BankerTrader API; the base URL is in `lib/core/`.

## Quality gates

```bash
flutter analyze     # 0 errors / 0 warnings
flutter test        # unit + widget tests
```

## Architecture

```
lib/
├─ core/         app config, api client, shared utilities
├─ features/
│  ├─ auth/      login/passkeys/token storage
│  ├─ broker/    Upstox OAuth + broker account management
│  └─ trading/   paper & live trading, portfolio, orders, pnl
```

Feature folders follow: `domain/` (entities + repository contracts), `data/` (`sources/*_api.dart`, repository impls), `presentation/` (bloc/cubit state, widgets, pages).

## Related

- Backend & web: https://github.com/Hemil31/banker-trader-web