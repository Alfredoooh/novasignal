// providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    // Escuta mudanças no estado de autenticação
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        // Busca dados completos do usuário no Firestore
        await _loadUserData(firebaseUser.uid);
      } else {
        _user = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  // Carrega dados do usuário do Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      _user = await _authService.getUserData(uid);
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      _errorMessage = 'Erro ao carregar dados do usuário';
      notifyListeners();
    }
  }

  // Login
  Future<bool> signIn(String email, String password) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final userModel = await _authService.signIn(email, password);
      
      if (userModel != null) {
        _user = userModel;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _errorMessage = 'Falha ao fazer login';
      _isLoading = false;
      notifyListeners();
      return false;
      
    } catch (e) {
      _errorMessage = _parseErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Registro
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final userModel = await _authService.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      if (userModel != null) {
        _user = userModel;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Falha ao criar conta';
      _isLoading = false;
      notifyListeners();
      return false;
      
    } catch (e) {
      _errorMessage = _parseErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Recuperar senha
  Future<bool> resetPassword(String email) async {
    try {
      _errorMessage = null;
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = _parseErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  // Atualizar dados do usuário
  Future<bool> updateUser({
    String? name,
    String? phone,
  }) async {
    if (_user == null) return false;

    try {
      final updatedUser = _user!.copyWith(
        name: name ?? _user!.name,
        phone: phone ?? _user!.phone,
      );

      await _authService.updateUserData(updatedUser);
      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar perfil';
      notifyListeners();
      return false;
    }
  }

  // Recarregar dados do usuário
  Future<void> refreshUser() async {
    if (_user != null) {
      await _loadUserData(_user!.id);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Traduz erros do Firebase para mensagens amigáveis
  String _parseErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'Usuário não encontrado';
    } else if (error.contains('wrong-password')) {
      return 'Senha incorreta';
    } else if (error.contains('email-already-in-use')) {
      return 'Este email já está em uso';
    } else if (error.contains('weak-password')) {
      return 'Senha muito fraca';
    } else if (error.contains('invalid-email')) {
      return 'Email inválido';
    } else if (error.contains('network-request-failed')) {
      return 'Erro de conexão. Verifique sua internet';
    } else {
      return 'Erro ao processar solicitação';
    }
  }
}