/* services/firebase/auth_service.dart
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
        case 'email-alre?ady-in-use':
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
*/

// services/firebase/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de mudanças de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuário atual do Firebase Auth
  User? get currentUser => _auth.currentUser;

  // Login com email e senha
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        return await getUserData(userCredential.user!.uid);
      }
      return null;
    } catch (e) {
      print('Erro no login: $e');
      rethrow;
    }
  }

  // Registro de novo usuário
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      // Criar usuário no Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;

        // Criar documento do usuário no Firestore
        final userData = {
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': null,
        };

        await _firestore.collection('users').doc(uid).set(userData);

        // Retornar UserModel com os dados criados
        return UserModel(
          id: uid,
          name: name,
          email: email,
          phone: phone,
          createdAt: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print('Erro no registro: $e');
      rethrow;
    }
  }

  // Buscar dados do usuário no Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
      return null;
    }
  }

  // Atualizar dados do usuário
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update({
        'name': user.name,
        'phone': user.phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      rethrow;
    }
  }

  // Recuperar senha
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Erro ao enviar email de recuperação: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Erro ao fazer logout: $e');
      rethrow;
    }
  }

  // Deletar conta
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Deletar documento do Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Deletar conta do Firebase Auth
        await user.delete();
      }
    } catch (e) {
      print('Erro ao deletar conta: $e');
      rethrow;
    }
  }
}