/// Authentication service wrapping Firebase Auth.
///
/// Provides email/password sign-in, sign-up, sign-out,
/// and an auth state stream for reactive UI updates.
library;

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of auth state changes — used with StreamBuilder.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in user (null if signed out).
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password.
  ///
  /// Returns the [User] on success, throws [FirebaseAuthException] on failure.
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Create a new vendor account with email and password.
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Sign out the current vendor.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
