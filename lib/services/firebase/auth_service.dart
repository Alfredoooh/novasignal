// services/firebase/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream do usuário autenticado
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuário atual
  User? get currentUser => _auth.currentUser;

  // Login
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        return await getUserData(credential.user!.uid);
      }
      return null;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Registro
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = UserModel(
          id: credential.user!.uid,
          name: name,
          email: email,
          phone: phone,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.id).set(user.toMap());
        return user;
      }
      return null;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Recuperar senha
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Buscar dados do usuário
  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Atualizar dados do usuário
  Future<void> updateUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  // Tratamento de erros
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuário não encontrado';
        case 'wrong-password':
          return 'Senha incorreta';
        case 'email-already-in-use':
          return 'Email já está em uso';
        case 'weak-password':
          return 'Senha muito fraca';
        case 'invalid-email':
          return 'Email inválido';
        default:
          return 'Erro ao autenticar: ${e.message}';
      }
    }
    return 'Erro desconhecido';
  }
}
