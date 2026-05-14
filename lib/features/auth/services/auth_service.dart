import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Cria a conta de acesso no Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.updateDisplayName(name);

      String uid = userCredential.user!.uid;

      // Salva o perfil do usuário no Firestore
      await _firestore.collection('usuarios').doc(uid).set({
        'uid': uid,
        'nome': name,
        'email': email,
        'telefone': '', // Será preenchido na verificação 2FA (Auditoria)
        'fcm_token': '', // Será preenchido para receber notificações de enchentes
        'is_verified': false, // Começa como falso, garantindo que não pode postar fake news
        'data_cadastro': FieldValue.serverTimestamp(),
      });

      return null;

    } on FirebaseAuthException catch (e) {
      // Tradução dos erros mais comuns para o usuário
      if (e.code == 'email-already-in-use') {
        return "Este e-mail já está cadastrado.";
      } else if (e.code == 'weak-password') {
        return "A senha deve ter pelo menos 6 caracteres.";
      } else if (e.code == 'invalid-email') {
        return "O formato do e-mail é inválido.";
      }
      return "Erro ao criar conta: ${e.message}";
    } catch (e) {
      return "Ocorreu um erro inesperado. Tente novamente.";
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return "E-mail ou senha incorretos.";
      }
      return "Erro ao fazer login: ${e.message}";
    } catch (e) {
      return "Ocorreu um erro inesperado.";
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}