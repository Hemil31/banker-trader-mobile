import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../sources/authentication_api.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  AuthenticationRepositoryImpl({
    required AuthenticationApi api,
    required TokenStorage tokenStorage,
  }) : _api = api,
       _tokenStorage = tokenStorage;

  final AuthenticationApi _api;
  final TokenStorage _tokenStorage;

  @override
  Future<(User, AuthTokens)> login(String identifier, String password) async {
    final dto = await _api.login(identifier: identifier, password: password);
    final tokens = AuthTokens(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
    );
    await _tokenStorage.save(tokens);
    return (User.fromJson(dto.user), tokens);
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    final dto = await _api.refresh(refreshToken);
    final tokens = AuthTokens(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
    );
    await _tokenStorage.save(tokens);
    return tokens;
  }

  @override
  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      await _tokenStorage.clear();
    }
  }

  @override
  Future<User> me() async {
    return User.fromJson(await _api.me());
  }
}
