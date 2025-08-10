import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../constants/firebase_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // Create user document in Firestore
        final AppUser appUser = AppUser(
          id: user.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(user.uid)
            .set(appUser.toMap());

        // Update display name
        await user.updateDisplayName(name);
      }

      return user;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Get user data from Firestore
  Future<AppUser?> getUserData(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Update user data
  Future<void> updateUserData(AppUser user) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.id)
          .update(user.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw Exception('Failed to update user data: ${e.toString()}');
    }
  }
}
