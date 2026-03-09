import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/queue_model.dart';
import '../models/user_model.dart';
import '../models/vendor_model.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.authTokenKey);
  }

  Map<String, String> _headers({String? token}) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // ── AUTH ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/auth/register'),
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        if (phone != null) 'phone': phone,
      }),
    );
    return _decode(res);
  }

  // ── VENDORS ───────────────────────────────────────────────
  Future<List<VendorModel>> getVendors() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/vendors'),
      headers: _headers(token: token),
    );
    final data = _decode(res);
    return (data['vendors'] as List)
        .map((v) => VendorModel.fromJson(v as Map<String, dynamic>))
        .toList();
  }

  // ── QUEUES ────────────────────────────────────────────────
  Future<QueueModel> joinQueue(String vendorId) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/queues/join'),
      headers: _headers(token: token),
      body: jsonEncode({'vendor_id': vendorId}),
    );
    final data = _decode(res);
    return QueueModel.fromJson(data['queue'] as Map<String, dynamic>);
  }

  Future<List<QueueModel>> getMyQueue() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/queues/my'),
      headers: _headers(token: token),
    );
    final data = _decode(res);
    return (data['queues'] as List)
        .map((q) => QueueModel.fromJson(q as Map<String, dynamic>))
        .toList();
  }

  Future<List<QueueModel>> getVendorQueue(String vendorId) async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/queues/vendor/$vendorId'),
      headers: _headers(token: token),
    );
    final data = _decode(res);
    return (data['queues'] as List)
        .map((q) => QueueModel.fromJson(q as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelQueue(String queueId) async {
    final token = await _getToken();
    final res = await http.patch(
      Uri.parse('${AppConfig.baseUrl}/queues/$queueId/cancel'),
      headers: _headers(token: token),
    );
    _decode(res);
  }

  Future<void> serveNext(String vendorId) async {
    final token = await _getToken();
    final res = await http.patch(
      Uri.parse('${AppConfig.baseUrl}/queues/vendor/$vendorId/serve-next'),
      headers: _headers(token: token),
    );
    _decode(res);
  }

  // ── HELPER ────────────────────────────────────────────────
  Map<String, dynamic> _decode(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw ApiException(
        statusCode: res.statusCode,
        message: body['message'] as String? ?? 'Unknown error',
      );
    }
    return body;
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
