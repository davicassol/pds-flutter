import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tcc_alagouai/features/report/services/report_service.dart';
import 'package:tcc_alagouai/features/routes/services/route_service.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class RouteHeader extends StatefulWidget {
  final Function(SafeRouteResult) onRouteCalculated;

  const RouteHeader({
    super.key,
    required this.onRouteCalculated,
  });

  @override
  State<RouteHeader> createState() => _RouteHeaderState();
}

class _RouteHeaderState extends State<RouteHeader> {
  final TextEditingController destinationController = TextEditingController();
  final String apiKey = dotenv.env['MAPS_API_KEY'] ?? "";

  bool _isLoading = false;

  List<dynamic> _placeList = [];
  Timer? _debounce;

  LatLng? _currentPositionForBias;

  @override
  void initState() {
    super.initState();
    _getUserLocationForBias();
  }

  Future<void> _getUserLocationForBias() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return;
        }
      } else if (permission == LocationPermission.deniedForever) {
        return;
      }

      //tenta pegar do cache
      Position? cachedPosition = await Geolocator.getLastKnownPosition();

      if (cachedPosition != null && mounted) {
        setState(() {
          _currentPositionForBias = LatLng(cachedPosition.latitude, cachedPosition.longitude);
        });
      } else {
        //se o cache estiver vazio injeta temporariamente localização mockada
        if (mounted) {
          setState(() {
            _currentPositionForBias = const LatLng(-29.3385, -49.7291);
          });
        }
      }

      //busca a posição real em segundo plano para confirmar/corrigir a temporária
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low).then((finalPosition) {
        if (mounted) {
          setState(() {
            _currentPositionForBias = LatLng(finalPosition.latitude, finalPosition.longitude);
          });
        }
      });

    } catch (e) {
      debugPrint("Erro ao obter GPS para o viés: $e");
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _getPlacesSuggestions(query);
      } else {
        setState(() { _placeList = []; });
      }
    });
  }

  Future<void> _getPlacesSuggestions(String input) async {
    if (apiKey.isEmpty) return;

    String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&language=pt-BR&components=country:br';

    //se achou no cache ou no GPS real, envia a busca para a região
    if (_currentPositionForBias != null) {
      double lat = _currentPositionForBias!.latitude;
      double lng = _currentPositionForBias!.longitude;
      url += '&location=$lat,$lng&radius=20000&strictbounds';
    }

    //uso para testes
    debugPrint("URL ENVIADA PARA O GOOGLE");
    debugPrint(url);

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            _placeList = data['predictions'];
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar sugestões: $e");
    }
  }

  void _onPlaceSelected(String placeDescription) {
    destinationController.text = placeDescription;
    setState(() { _placeList = []; });
    FocusManager.instance.primaryFocus?.unfocus();
    _handleCalculateRoute();
  }

  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      debugPrint("Erro ao encontrar o endereço ($address): $e");
    }
    return null;
  }

  Future<void> _handleCalculateRoute() async {
    if (destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite para onde você quer ir!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    LatLng? originLatLng;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("GPS desativado");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception("Permissão negada");
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      originLatLng = LatLng(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ative o GPS para calcularmos a rota.")),
      );
      setState(() { _isLoading = false; });
      return;
    }

    LatLng? destinationLatLng = await _getCoordinatesFromAddress(destinationController.text);

    if (destinationLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não achamos as coordenadas desse local exato.")),
      );
      setState(() { _isLoading = false; });
      return;
    }

    try {
      final QuerySnapshot floodSnapshot = await ReportService().getActiveReports().first;

      List<Map<String, dynamic>> activeFloods = [];
      for (var doc in floodSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['lat'] != null && data['lng'] != null) {
          activeFloods.add(data);
        }
      }

      final result = await RouteService().getRoute(
        originLatLng,
        destinationLatLng,
        activeFloods,
      );

      if (result != null && result.points.isNotEmpty) {
        widget.onRouteCalculated(result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nenhuma rota segura encontrada.")),
        );
      }
    } catch (e) {
      debugPrint("Erro no cálculo: $e");
    }

    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    //Pega a foto do user logado
    final User? user = FirebaseAuth.instance.currentUser;
    final String? photoUrl = user?.photoURL;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min, //Impede que o header tome a tela toda
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //searchbar
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 10,
                    offset: Offset(0, 4)
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),

                //foto de user/botão
                GestureDetector(
                  onTap: () {
                    //Abre o CustomDrawer
                    Scaffold.of(context).openDrawer();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null
                          ? const Icon(Icons.person, size: 24, color: AppColors.primaryBlue)
                          : null,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                //campo de digitação
                Expanded(
                  child: TextField(
                    controller: destinationController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _handleCalculateRoute(),
                    decoration: InputDecoration(
                      hintText: "Para onde vamos?",
                      hintStyle: const TextStyle(color: AppColors.textGreyLight, fontSize: 16),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                //Botão Limpar (X)
                if (destinationController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.iconGrey, size: 20),
                    onPressed: () {
                      destinationController.clear();
                      setState(() { _placeList = []; });
                    },
                  ),

                Container(
                  height: 24,
                  width: 1,
                  color: AppColors.dividerGrey,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                ),

                //botão de calcular rota
                GestureDetector(
                  onTap: _isLoading ? null : _handleCalculateRoute,
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: AppColors.textWhite, strokeWidth: 2)
                    )
                        : const Icon(Icons.directions_rounded, color: AppColors.textWhite, size: 20),
                  ),
                ),
              ],
            ),
          ),

          //sugestões suspensas
          if (_placeList.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: Offset(0, 4))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _placeList.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.dividerGrey),
                  itemBuilder: (context, index) {
                    var place = _placeList[index];
                    String mainText = place['structured_formatting']?['main_text'] ?? place['description'];
                    String secondaryText = place['structured_formatting']?['secondary_text'] ?? "";

                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceGrey,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on_rounded, color: AppColors.iconGrey, size: 20),
                      ),
                      title: Text(mainText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: secondaryText.isNotEmpty
                          ? Text(secondaryText, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textGreyMedium, fontSize: 13))
                          : null,
                      onTap: () {
                        _onPlaceSelected(place['description']);
                      },
                    );
                  },
                ),
              ),
            )
        ],
      ),
    );
  }
}