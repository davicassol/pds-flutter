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

  Future<String?> _uploadImage(File imageFile) async {
    try {
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
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return "Usuário não autenticado.";

      bool isAdmin = false;
      try {
        DocumentSnapshot userDoc = await _firestore.collection('usuarios').doc(currentUserId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>?;
          if (userData != null && userData['isAdmin'] == true) {
            isAdmin = true;
          }
        }
      } catch (e) {
        print("Erro ao verificar status de administrador: $e");
      }

      //aplica as regras se não for adm (regra de 3 reportes por dia)
      if (!isAdmin) {
        DateTime now = DateTime.now();
        DateTime startOfToday = DateTime(now.year, now.month, now.day);

        QuerySnapshot todayReports = await _firestore
            .collection('reportes')
            .where('userId', isEqualTo: currentUserId)
            .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
            .get();

        if (todayReports.docs.length >= 3) {
          return "Você atingiu o limite máximo de 3 reportes para o dia de hoje.";
        }

        //regra de distância máxima de 100 metros
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
      }

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
      }

      //traduz as cord para cidade e rua
      List<Placemark> placemarks = await placemarkFromCoordinates(selectedLat, selectedLng);

      String realStreetName = "Localização Selecionada";
      String rawCityName = "Desconhecida";

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        realStreetName = place.street ?? "Rua Desconhecida";
        //pega o nome da cidade
        rawCityName = place.subAdministrativeArea ?? place.locality ?? "Desconhecida";
      }
      String cityName = rawCityName.toLowerCase();

      await _firestore.collection('reportes').add({
        'userId': currentUserId,
        'userName': _auth.currentUser?.displayName ?? "Anônimo",
        'streetName': realStreetName,
        'floodLevel': floodLevel,
        'lat': selectedLat,
        'lng': selectedLng,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'city': cityName,
      });

      return null; //retorna null se for sucesso
    } catch (e) {
      return "Erro ao enviar reporte: $e";
    }
  }

  //busca todos os reportes ativos no mapa (última 1 hora)
  Stream<QuerySnapshot> getActiveReports() {
    DateTime oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    return _firestore
        .collection('reportes')
        .where('timestamp', isGreaterThan: oneHourAgo)
        .snapshots();
  }

  // busca reportes do usuário logado
  Stream<QuerySnapshot> getUserReports() {
    String? currentUserId = _auth.currentUser?.uid;
    return _firestore
        .collection('reportes')
        .where('userId', isEqualTo: currentUserId)
        .snapshots();
  }

  //deleta o reporte do Firestore
  Future<void> deleteReport(String reportId, String? imageUrl) async {
    try {
      await _firestore.collection('reportes').doc(reportId).delete();
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _storage.refFromURL(imageUrl).delete();
      }
    } catch (e) {
      print("Erro ao deletar reporte: $e");
    }
  }
}