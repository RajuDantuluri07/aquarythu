import 'package:flutter/foundation.dart';
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

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // --- WEB FLOW ---
        // Pass this via --dart-define=GOOGLE_REDIRECT_URL=https://your-app.com
        const redirectUrl = String.fromEnvironment('GOOGLE_REDIRECT_URL');
        if (redirectUrl.isEmpty) {
          // For local development, you can fall back to a default.
          // But for production builds, it should be provided.
          debugPrint('GOOGLE_REDIRECT_URL not set, using default for local dev.');
          const defaultUrl = 'http://localhost:3000'; // Or your specific local setup
          await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.google, redirectTo: defaultUrl);
          return {'success': true};
        }
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: redirectUrl,
        );
        return {'success': true};
      } else {
        // --- MOBILE FLOW (Native) ---
        // Pass this via --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_ID
        const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
        if (webClientId.isEmpty) {
          const errorMsg = 'Google Sign-in not configured on this build. Contact support.';
          debugPrint('[GOOGLE_SIGN_IN_ERROR] GOOGLE_WEB_CLIENT_ID not set');
          return {'success': false, 'error': errorMsg};
        }

        debugPrint('[GOOGLE_SIGN_IN] Starting sign-in with webClientId: $webClientId');
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: webClientId,
        );

        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          debugPrint('[GOOGLE_SIGN_IN] User canceled sign-in');
          return {'success': false, 'error': 'Sign-in canceled'}; // User canceled
        }

        debugPrint('[GOOGLE_SIGN_IN] Got Google user: ${googleUser.email}');
        final googleAuth = await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        if (idToken == null) {
          debugPrint('[GOOGLE_SIGN_IN_ERROR] ID token is null');
          return {'success': false, 'error': 'Failed to get ID token from Google'};
        }

        debugPrint('[GOOGLE_SIGN_IN] Signing into Supabase with Google credentials');
        debugPrint('[GOOGLE_SIGN_IN] ID Token (first 50 chars): ${idToken.substring(0, 50)}...');
        
        await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
        debugPrint('[GOOGLE_SIGN_IN] Successfully signed in to Supabase');
        return {'success': true};
      }
    } catch (e) {
      final errorMsg = e.toString();
      debugPrint('[GOOGLE_SIGN_IN_ERROR] Full error: $errorMsg');
      
      // Parse common errors
      String userFriendlyMsg = 'Google Sign-In failed';
      if (errorMsg.contains('invalid') || errorMsg.contains('401')) {
        userFriendlyMsg = 'Invalid Google credentials. Please check Supabase Google OAuth configuration.';
      } else if (errorMsg.contains('network') || errorMsg.contains('Network')) {
        userFriendlyMsg = 'Network error. Check your internet connection.';
      } else if (errorMsg.contains('provider') || errorMsg.contains('not found')) {
        userFriendlyMsg = 'Google provider not configured in Supabase. See GOOGLE_SIGNIN_SETUP.md';
      } else if (errorMsg.contains('redirect') || errorMsg.contains('callback')) {
        userFriendlyMsg = 'Redirect URI mismatch. Check Supabase Google OAuth settings.';
      }
      
      return {'success': false, 'error': userFriendlyMsg};
    }
  }
}