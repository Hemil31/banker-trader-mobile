import '../../domain/entities/broker.dart';
import '../../domain/entities/broker_account.dart';

sealed class BrokerState {
  const BrokerState();
}

class BrokerInitial extends BrokerState {
  const BrokerInitial();
}

class BrokerLoading extends BrokerState {
  const BrokerLoading();
}

class BrokerLoaded extends BrokerState {
  const BrokerLoaded({
    required this.brokers,
    required this.accounts,
    this.message,
  });

  final List<Broker> brokers;
  final List<BrokerAccount> accounts;
  final String? message;

  BrokerLoaded copyWith({
    List<Broker>? brokers,
    List<BrokerAccount>? accounts,
    String? message,
    bool clearMessage = false,
  }) => BrokerLoaded(
    brokers: brokers ?? this.brokers,
    accounts: accounts ?? this.accounts,
    message: clearMessage ? null : (message ?? this.message),
  );
}

class BrokerError extends BrokerState {
  const BrokerError(this.message);

  final String message;
}