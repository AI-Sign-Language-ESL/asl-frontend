import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // ✅ ADD THIS LINE: This forces the token to match what your backend expects
    serverClientId:
        "954198035335-64fg39fu3vpksu4o44tki3c4bmec14jt.apps.googleusercontent.com",
  );

  static Future<String?> getIdToken() async {
    try {
      // Sign out first to force account picker (optional, helps testing)
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;

      // ✅ DEBUG PRINT: Check if we actually got a token
      print("Google ID Token: ${auth.idToken}");

      return auth.idToken;
    } catch (e) {
      print("Google Sign In Error: $e");
      return null;
    }
  }
}
