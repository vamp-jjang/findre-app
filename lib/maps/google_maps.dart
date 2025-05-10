import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class GoogleMapsScreen extends StatefulWidget {
  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}
class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(9.814062304659195, 124.1764920905616),
    zoom: 14,

  );
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: _initialPosition,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }


}