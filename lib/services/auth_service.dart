import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
static Future<UserCredential> register({
  required String email,
  required String password,
}) async {
  return await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
}

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _getMessage(e);
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static String _getMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'Password must be at least 6 characters.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
        return 'Incorrect password.';

      case 'invalid-credential':
        return 'Invalid email or password.';

      default:
        return e.message ?? 'Something went wrong.';
    }
  }
}