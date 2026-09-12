import '../../domain/repositories/broker_repository.dart';

class ConnectKotakUseCase {
  ConnectKotakUseCase({required BrokerRepository repository})
    : _repository = repository;

  final BrokerRepository _repository;

  Future<void> call(
    String tradingAccountId, {
    required String mobileNumber,
    required String ucc,
    required String totp,
    required String mpin,
  }) => _repository.connectKotak(
    tradingAccountId,
    mobileNumber: mobileNumber,
    ucc: ucc,
    totp: totp,
    mpin: mpin,
  );
}
