import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static const webClientId = '347726171121-05vv2sgttc1pi38k8dui4ka5hpn6o722.apps.googleusercontent.com';

  static bool _isInitialized = false;

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await GoogleSignIn.instance.initialize(serverClientId: webClientId);
      _isInitialized = true;
    }
  }

  static Future<AuthResponse?> signInWithGoogle() async {
    try {
      await _ensureInitialized();
      final googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) {
        return null; // User canceled the login
      }
      
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await GoogleSignIn.instance.signOut();
      await _supabase.auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  static User? get currentUser => _supabase.auth.currentUser;
  
  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}