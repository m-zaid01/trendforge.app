class AuthService {
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return email.isNotEmpty && password.length >= 6;
  }

  Future<bool> signup(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return email.contains('@') && password.length >= 6;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
