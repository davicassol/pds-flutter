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
      //cria a conta de no Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.updateDisplayName(name);

      //dispara o e-mail de verificação
      await userCredential.user!.sendEmailVerification();

      String uid = userCredential.user!.uid;

      //salva o perfil do usuário no Firestore
      await _firestore.collection('usuarios').doc(uid).set({
        'uid': uid,
        'nome': name,
        'email': email,
        'telefone': '', //mantido no banco para uso futuro
        'fcm_token': '', //será preenchido futuramente para receber notificações de enchentes
        'is_verified': false, //vira true ao confrimar email
        'data_cadastro': FieldValue.serverTimestamp(),
      });

      return null;

    } on FirebaseAuthException catch (e) {
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
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      //verifica se o e-mail foi confirmado
      if (!userCredential.user!.emailVerified) {
        await _auth.signOut(); //desloga o usuário imediatamente
        return "Verifique sua caixa de entrada e confirme seu e-mail antes de acessar.";
      }

      //passou da verificação, atualiza o status de auditoria no Firestore
      await _firestore.collection('usuarios').doc(userCredential.user!.uid).update({
        'is_verified': true,
      });

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

  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        return "E-mail inválido ou não cadastrado.";
      }
      return "Erro ao enviar o link de recuperação: ${e.message}";
    } catch (e) {
      return "Ocorreu um erro inesperado.";
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}