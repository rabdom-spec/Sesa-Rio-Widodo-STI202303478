import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../database/database_helper.dart';
import '../models/destination_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  List<Destination> destinations = [];
  Set<Marker> markers = {};
  bool isLoading = true;

  // Default location: Jakarta, Indonesia
  static const LatLng _defaultLocation = LatLng(-6.2088, 106.8456);

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.readAll();
    
    final Set<Marker> newMarkers = {};
    for (var dest in data) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(dest.id.toString()),
          position: LatLng(dest.latitude, dest.longitude),
          infoWindow: InfoWindow(
            title: dest.name,
            snippet: dest.description,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueCyan,
          ),
        ),
      );
    }

    setState(() {
      destinations = data;
      markers = newMarkers;
      isLoading = false;
    });

    // Move camera to first destination if available
    if (data.isNotEmpty && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(data.first.latitude, data.first.longitude),
          12,
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Destinasi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDestinations,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: _defaultLocation,
                zoom: 12,
              ),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: true,
              zoomControlsEnabled: true,
            ),
            if (isLoading)
              Container(
                color: Colors.white.withOpacity(0.8),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (destinations.isEmpty && !isLoading)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.teal[700]),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Belum ada destinasi di peta. Tambahkan destinasi terlebih dahulu.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.teal[700], size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${destinations.length} Destinasi',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: destinations.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                if (_mapController != null && destinations.isNotEmpty) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(
                        destinations.first.latitude,
                        destinations.first.longitude,
                      ),
                      12,
                    ),
                  );
                }
              },
              backgroundColor: Colors.teal,
              child: const Icon(Icons.my_location, color: Colors.white),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}