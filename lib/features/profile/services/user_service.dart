import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> updateUserProfile({required String name, File? imageFile}) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return "Usuário não autenticado.";

      String? photoUrl = user.photoURL;

      //se o usuário escolheu uma foto nova, faz o upload pro Storage
      if (imageFile != null) {
        String fileName = 'perfil/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference ref = _storage.ref().child(fileName);
        UploadTask uploadTask = ref.putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;
        photoUrl = await snapshot.ref.getDownloadURL();
      }

      //atualiza o perfil no Firebase Auth
      await user.updateDisplayName(name);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      //atualiza também no Firestore
      await _firestore.collection('usuarios').doc(user.uid).set({
        'nome': name,
        'fotoUrl': photoUrl,
      }, SetOptions(merge: true));

      return null; //retorna nulo se deu tudo certo
    } catch (e) {
      return "Erro ao atualizar perfil: $e";
    }
  }
}