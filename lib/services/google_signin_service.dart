import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInException implements Exception {
  final String userFriendlyMessage;
  const GoogleSignInException(this.userFriendlyMessage);

  @override
  String toString() => userFriendlyMessage;
}

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        "954198035335-64fg39fu3vpksu4o44tki3c4bmec14jt.apps.googleusercontent.com",
  );

  static Future<String?> getIdToken() async {
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const GoogleSignInException('Google sign-in was cancelled.');
      }
      final auth = await account.authentication;
      if (auth.idToken == null) {
        throw const GoogleSignInException('Unable to sign in with Google.');
      }
      return auth.idToken;
    } on GoogleSignInException {
      rethrow;
    } catch (e) {
      throw GoogleSignInException(_mapError(e));
    }
  }

  static String _mapError(Object error) {
    final s = error.toString().toLowerCase();
    if (s.contains('cancel')) return 'Google sign-in was cancelled.';
    if (s.contains('network') ||
        s.contains('connection') ||
        s.contains('timeout')) {
      return 'Network error. Please try again.';
    }
    return 'Unable to sign in with Google.';
  }
}
