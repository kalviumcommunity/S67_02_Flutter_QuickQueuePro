import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await ApiService.instance.login(email, password);
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.authTokenKey, data['token'] as String);
      await prefs.setString(AppConfig.userIdKey, _user!.id);
      await prefs.setString(AppConfig.userRoleKey, _user!.role);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await ApiService.instance.register(
        name: name, email: email, password: password, role: role, phone: phone,
      );
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.authTokenKey, data['token'] as String);
      await prefs.setString(AppConfig.userIdKey, _user!.id);
      await prefs.setString(AppConfig.userRoleKey, _user!.role);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.authTokenKey);
    await prefs.remove(AppConfig.userIdKey);
    await prefs.remove(AppConfig.userRoleKey);
    notifyListeners();
  }
}
