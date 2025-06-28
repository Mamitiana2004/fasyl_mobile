import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fasyl/core/config/constants.dart';
import 'package:fasyl/widgets/CustomBottomNavigationBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServiceModel {
  final String? id;
  final String? serviceName;
  final String? categoryName;
  final String? description;
  final List<String>? photos;
  final ServiceLocation? location;

  ServiceModel({
    this.id,
    this.serviceName,
    this.categoryName,
    this.description,
    this.photos,
    this.location,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'],
      serviceName: json['service_name'],
      categoryName: json['category_name'],
      description: json['description'],
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
      location: json['location'] != null
          ? ServiceLocation.fromJson(json['location'])
          : null,
    );
  }
}

class ServiceLocation {
  final String? address;
  final String? city;
  final GeoCoordinates? geo;

  ServiceLocation({this.address, this.city, this.geo});

  factory ServiceLocation.fromJson(Map<String, dynamic> json) {
    return ServiceLocation(
      address: json['address'],
      city: json['city'],
      geo: json['geo'] != null ? GeoCoordinates.fromJson(json['geo']) : null,
    );
  }
}

class GeoCoordinates {
  final double? lat;
  final double? lng;

  GeoCoordinates({this.lat, this.lng});

  factory GeoCoordinates.fromJson(Map<String, dynamic> json) {
    return GeoCoordinates(
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController mapController;
  LatLng? _currentPosition;
  bool _loading = true;
  final List<Marker> _markers = [];
  List<ServiceModel> _nearbyServices = [];
  bool _showNearbyServices = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchNearbyServices() async {
    if (_currentPosition == null) return;

    final token = await _getToken();
    if (token == null) return;

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse(
          'http://backend.groupe-syl.com/backend-preprod/api/service/near',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'longitude': _currentPosition!.longitude,
          'latitude': _currentPosition!.latitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _nearbyServices = List<ServiceModel>.from(
            data['data'].map((x) => ServiceModel.fromJson(x)),
          );
          _addServiceMarkers();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        _showError('Erreur de chargement des services');
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError('Erreur de connexion');
    }
  }

  void _addServiceMarkers() {
    _markers.removeWhere((marker) => marker.key != const Key('user_location'));

    for (var service in _nearbyServices) {
      if (service.location?.geo?.lat != null &&
          service.location?.geo?.lng != null) {
        _markers.add(
          Marker(
            width: 40.0,
            height: 40.0,
            point: LatLng(
              service.location!.geo!.lat!,
              service.location!.geo!.lng!,
            ),
            builder: (ctx) => GestureDetector(
              onTap: () => _showServiceInfo(ctx, service),
              child: Icon(
                Icons.location_pin,
                color: AppColor.primary,
                size: 40,
              ),
            ),
          ),
        );
      }
    }
  }

  void _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _loading = false);
      _showError('Activez la localisation pour continuer');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _loading = false);
        _showError('Permission de localisation refusée');
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          key: const Key('user_location'),
          width: 50.0,
          height: 50.0,
          point: _currentPosition!,
          builder: (ctx) => Container(
            child: Icon(
              Icons.person_pin_circle,
              color: AppColor.primary,
              size: 40,
            ),
          ),
        ),
      );
      _loading = false;
    });

    _fetchNearbyServices();
  }

  void _showServiceInfo(BuildContext context, ServiceModel service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: AppColor.secondaryDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.serviceName ?? "Service",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      if (service.categoryName != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColor.primary,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            service.categoryName!,
                            style: TextStyle(
                              color: AppColor.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      SizedBox(height: 15),
                      if (service.location?.address != null)
                        _buildInfoRow(
                          Icons.location_on,
                          service.location!.address!,
                        ),
                      if (service.description != null)
                        _buildInfoRow(Icons.info, service.description!),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigation vers le détail du service
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Voir les détails",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColor.primary, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildNearbyServicesPanel() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      bottom: _showNearbyServices ? 0 : -300,
      left: 0,
      right: 0,
      child: Container(
        height: 250,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.secondaryDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Services à proximité (${_nearbyServices.length})',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showNearbyServices
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: AppColor.primary,
                  ),
                  onPressed: () {
                    setState(() => _showNearbyServices = !_showNearbyServices);
                  },
                ),
              ],
            ),
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColor.primary),
                    )
                  : _nearbyServices.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun service à proximité',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _nearbyServices.length,
                      itemBuilder: (context, index) {
                        final service = _nearbyServices[index];
                        return GestureDetector(
                          onTap: () {
                            if (service.location?.geo?.lat != null &&
                                service.location?.geo?.lng != null) {
                              mapController.move(
                                LatLng(
                                  service.location!.geo!.lat!,
                                  service.location!.geo!.lng!,
                                ),
                                16.0,
                              );
                            }
                            _showServiceInfo(context, service);
                          },
                          child: Container(
                            width: 200,
                            margin: EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: AppColor.secondaryLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: service.photos?.isNotEmpty == true
                                        ? Image.network(
                                            service.photos!.first,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                  color: AppColor.primary
                                                      .withOpacity(0.1),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.image,
                                                      color: Colors.white30,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ),
                                          )
                                        : Container(
                                            color: AppColor.primary.withOpacity(
                                              0.1,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.image,
                                                color: Colors.white30,
                                                size: 40,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service.serviceName ?? 'Service',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        service.categoryName ?? 'Catégorie',
                                        style: TextStyle(
                                          color: AppColor.primary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      if (service.location?.address != null)
                                        Text(
                                          service.location!.address!,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryDark,
      body: Stack(
        children: [
          if (_loading && _currentPosition == null)
            Center(child: CircularProgressIndicator(color: AppColor.primary))
          else if (_currentPosition == null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 50, color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Localisation non disponible',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _getCurrentLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Réessayer',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          else
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: _currentPosition,
                zoom: 14.0,
                interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.fasyl',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: _markers),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _currentPosition!,
                      color: AppColor.primary.withOpacity(0.1),
                      borderColor: AppColor.primary,
                      borderStrokeWidth: 2,
                      radius: 500, // Rayon en mètres
                    ),
                  ],
                ),
              ],
            ),

          // Barre de recherche
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColor.secondaryDark,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un service...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: AppColor.primary),
                      ),
                      style: TextStyle(color: Colors.white),
                      onChanged: (value) {
                        // Filtrer les services
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.tune, color: AppColor.primary),
                    onPressed: () {
                      // Ouvrir les filtres
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bouton de localisation
          Positioned(
            bottom: _showNearbyServices ? 300 : 100,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: AppColor.primary,
              onPressed: () {
                if (_currentPosition != null) {
                  mapController.move(_currentPosition!, 16.0);
                }
              },
              child: Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // Bouton pour afficher les services à proximité
          Positioned(
            bottom: _showNearbyServices ? 300 : 100,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: AppColor.primary,
              onPressed: () {
                setState(() => _showNearbyServices = !_showNearbyServices);
              },
              child: Icon(
                _showNearbyServices ? Icons.map : Icons.list,
                color: Colors.white,
              ),
            ),
          ),

          // Panel des services à proximité
          _buildNearbyServicesPanel(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 2),
    );
  }
}
