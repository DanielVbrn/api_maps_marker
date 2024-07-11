import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'src/locations.dart' as locations;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<String, Marker> _markers = {};
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(-5.08886, -42.81116),
    zoom: 10,
  );

  Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleOffices = await locations.getGoogleOffices();
    setState(() {
      _markers.clear();
      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
          ),
        );
        _markers[office.name] = marker;
      }
    });
  }

  void _onMapTapped(LatLng position) async {
    final String info = await _getInfoFromCoordinates(position);
    setState(() {
      final marker = Marker(
        markerId: const MarkerId("selected_marker"),
        position: position,
        infoWindow: InfoWindow(
          title: "Informações",
          snippet: info,
        ),
      );
      _markers["selected_marker"] = marker;
    });
  }

  Future<String> _getInfoFromCoordinates(LatLng position) async {
    // Implemente a lógica para obter informações baseadas nas coordenadas
    // Aqui estou retornando uma string de exemplo, mas você pode buscar de um serviço ou banco de dados
    return "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Google Office Locations'),
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: const Color.fromARGB(255, 0, 221, 66),
        ),
        body: GoogleMap(
          initialCameraPosition: _initialPosition,
          onMapCreated: (controller) {
            _mapController.complete(controller);
            _onMapCreated(controller);
          },
          markers: _markers.values.toSet(),
          onTap: _onMapTapped,
        ),
      ),
    );
  }
}
