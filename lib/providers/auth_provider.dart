import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  AppUser? _appUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await _loadUserData(user.uid);
    } else {
      _appUser = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserData(String userId) async {
    try {
      _appUser = await _authService.getUserData(userId);
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return user != null;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      
      return user != null;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      await _authService.signOut();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      _setLoading(true);
      _clearError();
      await _authService.resetPassword(email: email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserProfile(AppUser updatedUser) async {
    try {
      _setLoading(true);
      _clearError();
      await _authService.updateUserData(updatedUser);
      _appUser = updatedUser;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
