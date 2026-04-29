import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------
  // 1. CADASTRO DE USUÁRIO (SIGN UP)
  // ---------------------------------------------------------
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

      String uid = userCredential.user!.uid;

      // Salva o perfil do usuário no Firestore (Nossa coleção 'usuarios')
      await _firestore.collection('usuarios').doc(uid).set({
        'uid': uid,
        'nome': name,
        'email': email,
        'telefone': '', // Será preenchido na verificação 2FA (Auditoria)
        'fcm_token': '', // Será preenchido para receber notificações de enchentes
        'is_verified': false, // Começa como falso, garantindo que não pode postar fake news
        'data_cadastro': FieldValue.serverTimestamp(),
      });

      return null; // Retorna nulo indicando que deu tudo certo!

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

  // ---------------------------------------------------------
  // 2. LOGIN (SIGN IN)
  // ---------------------------------------------------------
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null; // Sucesso!

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return "E-mail ou senha incorretos.";
      }
      return "Erro ao fazer login: ${e.message}";
    } catch (e) {
      return "Ocorreu um erro inesperado.";
    }
  }

  // ---------------------------------------------------------
  // 3. SAIR DA CONTA (SIGN OUT)
  // ---------------------------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }
}