// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuário atual
  User? get currentUser => _auth.currentUser;

  // Login com email e senha
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Registro com email e senha
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Atualizar perfil
      await credential.user?.updateDisplayName(name);

      // Criar documento do usuário no Firestore
      await _firestore.collection('users').doc(credential.user?.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'photoUrl': null,
        'derivConnected': false,
      });

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Login com Google (Web e Mobile)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      
      if (kIsWeb) {
        // Para Web: usar popup
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Para Mobile: usar o pacote google_sign_in
        // Nota: você precisaria adicionar google_sign_in e fazer import condicional
        throw 'Google Sign-In não disponível em mobile nesta versão';
      }

      // Criar ou atualizar documento do usuário
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': userCredential.user?.displayName,
        'email': userCredential.user?.email,
        'photoUrl': userCredential.user?.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
        'derivConnected': false,
      }, SetOptions(merge: true));

      return userCredential;
    } catch (e) {
      throw 'Erro ao fazer login com Google: $e';
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Redefinir senha
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Atualizar perfil
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    final user = _auth.currentUser;
    if (user == null) throw 'Usuário não autenticado';

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }

    await _firestore.collection('users').doc(user.uid).update({
      if (displayName != null) 'name': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });
  }

  // Deletar conta
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw 'Usuário não autenticado';

    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }

  // Handler de exceções
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Email já está em uso';
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'operation-not-allowed':
        return 'Operação não permitida';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente mais tarde';
      default:
        return 'Erro: ${e.message}';
    }
  }
}