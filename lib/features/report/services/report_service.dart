import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Função interna para subir a foto e pegar o link
  Future<String?> _uploadImage(File imageFile) async {
    try {
      // Cria um nome único usando a data e hora atual
      String fileName = 'reportes/${DateTime.now().millisecondsSinceEpoch}.jpg';

      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Erro no upload da imagem: $e");
      return null;
    }
  }

  Future<String?> addReport({
    required String floodLevel,
    required double selectedLat,
    required double selectedLng,
    File? imageFile,
  }) async {
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude, currentPosition.longitude,
        selectedLat, selectedLng,
      );

      if (distanceInMeters > 100) {
        return "Você está muito longe do local! Só é permitido reportar alagamentos num raio de 100 metros.";
      }

      // Se o usuário tirou foto, faz o upload primeiro
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(selectedLat, selectedLng);
      String realStreetName = placemarks.isNotEmpty
          ? (placemarks.first.street ?? "Rua Desconhecida")
          : "Localização Selecionada";

      await _firestore.collection('reportes').add({
        'userId': _auth.currentUser?.uid,
        'userName': _auth.currentUser?.displayName ?? "Anônimo",
        'streetName': realStreetName,
        'floodLevel': floodLevel,
        'lat': selectedLat,
        'lng': selectedLng,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return "Erro ao enviar reporte: $e";
    }
  }

  Stream<QuerySnapshot> getActiveReports() {
    DateTime oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    return _firestore
        .collection('reportes')
        .where('timestamp', isGreaterThan: oneHourAgo)
        .snapshots();
  }
}