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

      //aplica as regras se não for adm (regra de 5 reportes por dia)
      if (!isAdmin) {
        DateTime now = DateTime.now();
        DateTime startOfToday = DateTime(now.year, now.month, now.day);

        QuerySnapshot todayReports = await _firestore
            .collection('reportes')
            .where('userId', isEqualTo: currentUserId)
            .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
            .get();

        if (todayReports.docs.length >= 100) {
          return "Você atingiu o limite máximo de 5 reportes para o dia de hoje.";
        }

        //regra de distância máxima de 200 metros
        Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        double distanceInMeters = Geolocator.distanceBetween(
          currentPosition.latitude, currentPosition.longitude,
          selectedLat, selectedLng,
        );

        if (distanceInMeters > 1000) {
          return "Você está muito longe do local! Só é permitido reportar alagamentos num raio de 200 metros.";
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

      //calcula expiração de 1h
      DateTime agora = DateTime.now();
      DateTime expiracaoInicial = agora.add(const Duration(hours: 1));

      DocumentReference reportRef = await _firestore.collection('reportes').add({
        'userId': currentUserId,
        'userName': _auth.currentUser?.displayName ?? "Anônimo",
        'streetName': realStreetName,
        'floodLevel': floodLevel,
        'lat': selectedLat,
        'lng': selectedLng,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'city': cityName,
        'data_expiracao': expiracaoInicial,
        'ativo': true,
        'votos_ativos': 0,
        'votos_inativos': 0,
      });

      //registra o primeiro feedback sendo do criador e aplica a regra de tempo
      await _firestore.collection('feedbacks').doc('${reportRef.id}_$currentUserId').set({
        'alagamento_id': reportRef.id,
        'usuario_id': currentUserId,
        'ainda_alagado': true,
        'data_feedback': FieldValue.serverTimestamp(),
      });

      return null; //retorna null se for sucesso
    } catch (e) {
      return "Erro ao enviar reporte: $e";
    }
  }

  //voto comunidade
  Future<String?> submitFeedback({
    required String reportId,
    required bool aindaAlagado,
  }) async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return "Usuário não autenticado.";

    DocumentReference reportRef = _firestore.collection('reportes').doc(reportId);
    DocumentReference feedbackRef = _firestore.collection('feedbacks').doc('${reportId}_$currentUserId');

    try {
      return await _firestore.runTransaction((transaction) async {

        //cooldown
        DocumentSnapshot feedbackSnapshot = await transaction.get(feedbackRef);
        if (feedbackSnapshot.exists) {
          Map<String, dynamic> feedbackData = feedbackSnapshot.data() as Map<String, dynamic>;
          Timestamp? ultimoFeedback = feedbackData['data_feedback'] as Timestamp?;

          if (ultimoFeedback != null) {
            DateTime dataPermitida = ultimoFeedback.toDate().add(const Duration(minutes: 20));
            DateTime agora = DateTime.now();

            //se o tempo atual for antes do tempo permitido, bloqueia o voto
            if (agora.isBefore(dataPermitida)) {
              int minutosRestantes = dataPermitida.difference(agora).inMinutes;
              if (minutosRestantes <= 0) minutosRestantes = 1;

              return "Você já votou aqui. Aguarde mais $minutosRestantes min para atualizar o status.";
            }
          }
        }

        DocumentSnapshot reportSnapshot = await transaction.get(reportRef);
        if (!reportSnapshot.exists) return "Este reporte não existe mais.";

        Map<String, dynamic> data = reportSnapshot.data() as Map<String, dynamic>;
        if (data['ativo'] == false) return "Este alagamento já foi resolvido.";

        int votosAtivos = data['votos_ativos'] ?? 0;
        int votosInativos = data['votos_inativos'] ?? 0;
        Timestamp dataExpiracaoAtual = data['data_expiracao'] ?? Timestamp.now();

        //xomputa o voto atual
        if (aindaAlagado) {
          votosAtivos++;
        } else {
          votosInativos++;
        }

        bool novoAtivo = true;
        Timestamp novaDataExpiracao = dataExpiracaoAtual;
        int novosVotosAtivos = votosAtivos;
        int novosVotosInativos = votosInativos;

        //estende o alagamnento por +1h ou o encerra
        if (votosAtivos >= 3) {
          novaDataExpiracao = Timestamp.fromDate(dataExpiracaoAtual.toDate().add(const Duration(hours: 1)));
          novosVotosAtivos = 0;
          novosVotosInativos = 0;
        } else if (votosInativos >= 3) {
          novoAtivo = false;
        }

        //att alagamento
        transaction.update(reportRef, {
          'votos_ativos': novosVotosAtivos,
          'votos_inativos': novosVotosInativos,
          'data_expiracao': novaDataExpiracao,
          'ativo': novoAtivo,
        });

        transaction.set(feedbackRef, {
          'alagamento_id': reportId,
          'usuario_id': currentUserId,
          'ainda_alagado': aindaAlagado,
          'data_feedback': FieldValue.serverTimestamp(),
        });

        return null;
      });
    } catch (e) {
      print("Erro ao processar feedback: $e");
      return "Erro ao processar o seu voto.";
    }
  }

  //busca todos os reportes ativos que ainda não expiraram
  Stream<QuerySnapshot> getActiveReports() {
    return _firestore
        .collection('reportes')
        .where('ativo', isEqualTo: true)
        .where('data_expiracao', isGreaterThan: Timestamp.now())
        .snapshots();
  }

  //busca reportes do usuário logado
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