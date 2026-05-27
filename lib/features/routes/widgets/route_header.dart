import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:tcc_alagouai/features/report/services/report_service.dart';
import 'package:tcc_alagouai/features/routes/services/route_service.dart';

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

  // variável para guardar o GPS e usar como viés na pesquisa
  LatLng? _currentPositionForBias;

  @override
  void initState() {
    super.initState();
    _getUserLocationForBias();
  }

  Future<void> _getUserLocationForBias() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setFallbackBias();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setFallbackBias();
          return;
        }
      }

      Position? cachedPosition = await Geolocator.getLastKnownPosition();
      Position finalPosition = cachedPosition ?? await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);

      if (mounted) {
        setState(() {
          _currentPositionForBias = LatLng(finalPosition.latitude, finalPosition.longitude);
        });
      }
    } catch (e) {
      debugPrint("Erro ao obter GPS para o viés: $e");
      _setFallbackBias();
    }
  }

  void _setFallbackBias() {
    if (mounted) {
      setState(() {
        _currentPositionForBias = const LatLng(-29.3385, -49.7291); // Coordenadas de Torres RS
      });
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

    // FORÇANDO O DART A ENTENDER QUE NÃO É NULO
    if (_currentPositionForBias != null) {
      double lat = _currentPositionForBias!.latitude;
      double lng = _currentPositionForBias!.longitude;
      url += '&location=$lat,$lng&radius=20000';
    }

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
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          )
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Para onde vamos?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: destinationController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "Buscar destino",
                        prefixIcon: const Icon(Icons.search, color: Colors.blue),
                        suffixIcon: destinationController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            destinationController.clear();
                            setState(() { _placeList = []; });
                          },
                        )
                            : null,
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none
                        ),
                      ),
                      onSubmitted: (_) => _handleCalculateRoute(),
                    ),
                  ),
                  const SizedBox(width: 12),

                  GestureDetector(
                    onTap: _isLoading ? null : _handleCalculateRoute,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.directions, color: Colors.white),
                    ),
                  )
                ],
              ),

              if (_placeList.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _placeList.length,
                    itemBuilder: (context, index) {
                      var place = _placeList[index];
                      String mainText = place['structured_formatting']?['main_text'] ?? place['description'];
                      String secondaryText = place['structured_formatting']?['secondary_text'] ?? "";

                      return ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.grey),
                        title: Text(mainText, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: secondaryText.isNotEmpty ? Text(secondaryText) : null,
                        onTap: () {
                          _onPlaceSelected(place['description']);
                        },
                      );
                    },
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}