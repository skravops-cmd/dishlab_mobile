import 'data/auth_api.dart';
import 'models/token_response.dart';

class AuthService {
  static Future<TokenResponse> login(String email, String password) {
    return AuthApi.login(email: email, password: password);
  }

  static Future<void> register(String email, String password) {
    return AuthApi.register(email: email, password: password);
  }
}
