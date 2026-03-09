import 'package:flutter/material.dart';

class AppConfig {
  AppConfig._();

  static const String appName = 'QuickQueuePro';

  // API base URL – change to your deployed backend
  static const String baseUrl = 'http://localhost:5000/api';

  // Brand colours
  static const Color primaryColor = Color(0xFF4A90D9);
  static const Color accentColor  = Color(0xFF50C878);
  static const Color errorColor   = Color(0xFFD94A4A);
  static const Color backgroundColor = Color(0xFFF5F7FA);

  // Token storage keys
  static const String authTokenKey  = 'auth_token';
  static const String userIdKey     = 'user_id';
  static const String userRoleKey   = 'user_role';

  // Queue status labels
  static const String statusWaiting    = 'waiting';
  static const String statusServing    = 'serving';
  static const String statusCompleted  = 'completed';
  static const String statusCancelled  = 'cancelled';

  // Roles
  static const String roleCustomer = 'customer';
  static const String roleVendor   = 'vendor';
}
