import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _authStateSubscription;
  User? _user;

  AuthNotifier() {
    _user = Supabase.instance.client.auth.currentUser;
    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  User? get user => _user;

  Future<bool> signIn(String email, String password) async {
    try {
      print("🔐 Attempting login with: $email");
      await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
      print("✅ Login successful!");
      return true;
    } on AuthException catch (e) {
      print("❌ Auth Error: ${e.message}");
      return false;
    } catch (e) {
      print("❌ Unexpected error: $e");
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      print("📝 Attempting signup with: $email");
      await Supabase.instance.client.auth
          .signUp(email: email, password: password);
      print("✅ Signup request sent. Please check your email for confirmation.");
      return true;
    } on AuthException catch (e) {
      print("❌ Auth Error: ${e.message}");
      return false;
    } catch (e) {
      print("❌ Unexpected error: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  Future<bool> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        print("🔐 Attempting Google login for web...");
        return await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          // For web, configure redirect URLs in your Supabase project settings.
        );
      } else {
        // Mobile-specific implementation
        print("🔐 Attempting Google login for mobile...");

        // IMPORTANT: Replace with your actual Google Cloud web client ID
        const webClientId = '782759620106-3uvpbdnvsog7fto0ckiht7p6evv3cgjs.apps.googleusercontent.com';

        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: webClientId,
        );

        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          print("Google sign-in was cancelled by user.");
          return false;
        }
        final googleAuth = await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        if (accessToken == null || idToken == null) {
          throw 'Google sign-in failed: Missing token.';
        }

        await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );

        print("✅ Google login successful!");
        return true;
      }
    } catch (e) {
      print("❌ Google Sign-In Error: $e");
      return false;
    }
  }

  bool get isAuthenticated => _user != null;
}
