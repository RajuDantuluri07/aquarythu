import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthNotifier extends ChangeNotifier {
  User? _user;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthNotifier() {
    _user = Supabase.instance.client.auth.currentUser;
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      debugPrint('Signup Error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    // Sign out of Google as well if on mobile
    if (!kIsWeb) {
      try {
        await GoogleSignIn().signOut();
      } catch (e) {
        // Ignore errors if google sign in wasn't used
      }
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // --- WEB FLOW ---
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'http://localhost:3000', // Replace with your production URL if needed
        );
        return true;
      } else {
        // --- MOBILE FLOW (Native) ---
        // NOTE: You must configure SHA-1 in Google Cloud Console for this to work.
        // The serverClientId is the "Web Client ID" from Google Cloud Console.
        const webClientId = '782759620106-nbsdbsaqab0hb58iuie1tardmvhhogb1.apps.googleusercontent.com';

        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: webClientId,
        );

        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) return false; // User canceled

        final googleAuth = await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        if (idToken == null) return false;

        await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
        return true;
      }
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      return false;
    }
  }
}