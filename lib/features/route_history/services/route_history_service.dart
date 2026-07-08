import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tcc_alagouai/features/routes/services/route_service.dart';

class RouteHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //retorna a stream do mapa para listar o histórico na tela do perfil
  Stream<List<Map<String, dynamic>>> getUserRouteHistory() {
    final String? uid = _auth.currentUser?.uid;

    if (uid == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('ROTAS_SALVAS')
        .where('usuario_id', isEqualTo: uid)
        .orderBy('data_criacao', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['doc_id'] = doc.id;
        return data;
      }).toList();
    });
  }

  //sava e puxa nome de ruas
  Future<void> saveCompletedRoute({
    required SafeRouteResult route,
  }) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null || route.points.isEmpty) return;

    String nomeOrigem = "Localização Atual";
    String nomeDestino = "Destino";

    //tradução de endereço
    try {
      List<Placemark> placemarksOrigem = await placemarkFromCoordinates(
        route.points.first.latitude,
        route.points.first.longitude,
      );
      if (placemarksOrigem.isNotEmpty) {
        Placemark place = placemarksOrigem.first;
        nomeOrigem = "${place.thoroughfare ?? 'Rua desconhecida'}, ${place.subLocality ?? ''}".trim();
        if (nomeOrigem.endsWith(',')) nomeOrigem = nomeOrigem.substring(0, nomeOrigem.length - 1);
      }

      List<Placemark> placemarksDestino = await placemarkFromCoordinates(
        route.points.last.latitude,
        route.points.last.longitude,
      );
      if (placemarksDestino.isNotEmpty) {
        Placemark place = placemarksDestino.first;
        nomeDestino = "${place.thoroughfare ?? 'Local desconhecido'}, ${place.subLocality ?? ''}".trim();
        if (nomeDestino.endsWith(',')) nomeDestino = nomeDestino.substring(0, nomeDestino.length - 1);
      }
    } catch (e) {
      debugPrint("Erro ao converter coordenadas em endereços: $e");
    }

    GeoPoint pontoInicio = GeoPoint(route.points.first.latitude, route.points.first.longitude);
    GeoPoint pontoFim = GeoPoint(route.points.last.latitude, route.points.last.longitude);

    String severidade = 'nenhum';
    if (route.floodsCrossed > 2) {
      severidade = 'alto';
    } else if (route.floodsCrossed > 0) {
      severidade = 'medio';
    }

    try {
      await _firestore.collection('ROTAS_SALVAS').add({
        'usuario_id': uid,
        'ponto_inicio': pontoInicio,
        'ponto_fim': pontoFim,
        'polyline_data': route.encodedPolyline,
        'data_criacao': FieldValue.serverTimestamp(),
        'endereco_inicio': nomeOrigem, //salva o nome traduzido
        'endereco_fim': nomeDestino,   //salva o nome traduzido
        'cruzou_alagamento': route.floodsCrossed > 0,
        'nivel_severidade': severidade,
      });
      debugPrint("Rota salva no Firebase com sucesso!");
    } catch (e) {
      debugPrint("Erro ao salvar rota: $e");
    }
  }
}