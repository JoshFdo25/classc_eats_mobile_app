import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:googlemaps_flutter_webservices/directions.dart' as webservices;

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  ContactScreenState createState() => ContactScreenState();
}

class ContactScreenState extends State<ContactScreen> {
  late GoogleMapController mapController;
  final LatLng _restaurantLocation = const LatLng(6.939557747114729, 79.85575546661137);
  late Position _currentPosition;
  bool _isLocationReady = false;
  final Set<Polyline> _polylines = {};

  final webservices.GoogleMapsDirections _googleMapsDirections = webservices.GoogleMapsDirections(apiKey: 'YOUR_GOOGLE_API_KEY');

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get the current location of the user
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle location service disabled case
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return;
      }
    }

    // Get the current location
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _isLocationReady = true;
    });

    // Call the function to get the route after the location is ready
    if (_isLocationReady) {
      _getRoute();
    }
  }

  // Function to get route from current location to the restaurant
  Future<void> _getRoute() async {
    // Make an API call to get the directions
    webservices.DirectionsResponse response = await _googleMapsDirections.directions(
      webservices.Location(lat: _currentPosition.latitude, lng: _currentPosition.longitude),
      webservices.Location(lat: _restaurantLocation.latitude, lng: _restaurantLocation.longitude),
      travelMode: webservices.TravelMode.driving,
    );

    if (response.status == 'OK') {
      // Get the route polyline
      List<LatLng> polylineCoordinates = [];
      for (var step in response.routes.first.legs.first.steps) {
        polylineCoordinates.add(LatLng(step.startLocation.lat, step.startLocation.lng));
        polylineCoordinates.add(LatLng(step.endLocation.lat, step.endLocation.lng));
      }

      // Create a polyline on the map
      setState(() {
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phone:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '+1 123-456-7890',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            const Text(
              'Address:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '123 Main Street, San Francisco, CA 94103',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            const Text(
              'Email:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'info@classiceats.com',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            const Text(
              'Find Us Here:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Google Map
            Expanded(
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: _restaurantLocation,
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('restaurant'),
                    position: _restaurantLocation,
                    infoWindow: const InfoWindow(
                      title: 'Classic Eats',
                      snippet: '76/5 New Moor Street, Colombo 12',
                    ),
                  ),
                  if (_isLocationReady)
                    Marker(
                      markerId: const MarkerId('current_location'),
                      position: LatLng(_currentPosition.latitude, _currentPosition.longitude),
                      infoWindow: const InfoWindow(
                        title: 'Your Location',
                      ),
                    ),
                },
                polylines: _polylines,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
