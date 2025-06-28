import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fasyl/core/config/constants.dart';
import 'package:fasyl/core/services/service.dart';
import 'package:fasyl/widgets/CustomBottomNavigationBar.dart';

class DetailServiceScreen extends StatefulWidget {
  final String serviceId;

  const DetailServiceScreen({super.key, required this.serviceId});

  @override
  _DetailServiceScreenState createState() => _DetailServiceScreenState();
}

class _DetailServiceScreenState extends State<DetailServiceScreen> {
  Map<String, dynamic>? serviceDetails;
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadServiceDetails();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadServiceDetails() async {
    try {
      final service = await Service().getById(widget.serviceId);
      if (service != null) {
        setState(() {
          serviceDetails = service;
          events = List<Map<String, dynamic>>.from(service["events"] ?? []);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showError("Service introuvable");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String? imageUrl, {double? width, double? height}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.secondaryDark, AppColor.secondary],
          ),
        ),
        child: Center(child: Icon(Icons.photo, color: Colors.white70)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.secondaryDark, AppColor.secondary],
              ),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColor.primary,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.secondaryDark, AppColor.secondary],
            ),
          ),
          child: Center(child: Icon(Icons.broken_image, color: Colors.white70)),
        ),
      ),
    );
  }

  void _openMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showError('Impossible d\'ouvrir Google Maps');
    }
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: AppColor.secondaryDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _buildImageWidget(
                          event["photo"],
                          height: 200,
                          width: double.infinity,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        event["event_name"] ?? "Événement",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColor.primary,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: AppColor.primary),
                                SizedBox(width: 8),
                                Text(
                                  event["event_date"] != null
                                      ? DateFormat('dd MMM yyyy').format(
                                          DateTime.parse(event["event_date"]))
                                      : "Date non spécifiée",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColor.primary,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 16, color: AppColor.primary),
                                SizedBox(width: 8),
                                Text(
                                  event["event_date"] != null
                                      ? DateFormat('HH:mm').format(
                                          DateTime.parse(event["event_date"]))
                                      : "Heure non spécifiée",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      if (event["description"] != null) ...[
                        _buildInfoSection(
                          "Description",
                          Icons.description,
                          event["description"],
                        ),
                        SizedBox(height: 20),
                      ],
                      SizedBox(height: 30),
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

  Widget _buildInfoSection(String title, IconData icon, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColor.primary, size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.secondaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return GestureDetector(
      onTap: () => _showEventDetails(event),
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColor.secondaryLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  _buildImageWidget(
                    event["photo"],
                    height: 120,
                    width: 200,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today,
                              size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            event["event_date"] != null
                                ? DateFormat('dd/MM')
                                    .format(DateTime.parse(event["event_date"]))
                                : "--/--",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event["event_name"] ?? "Événement",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: AppColor.primary),
                      SizedBox(width: 6),
                      Text(
                        event["event_date"] != null
                            ? DateFormat('HH:mm')
                                .format(DateTime.parse(event["event_date"]))
                            : "--:--",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColor.secondaryDark,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColor.primary,
          ),
        ),
      );
    }

    if (serviceDetails == null) {
      return Scaffold(
        backgroundColor: AppColor.secondaryDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white70, size: 50),
              SizedBox(height: 16),
              Text(
                'Aucune donnée disponible',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.secondaryDark,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            collapsedHeight: 80,
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageWidget(
                serviceDetails!["photos"]?.isNotEmpty == true
                    ? serviceDetails!["photos"][0]
                    : null,
                height: 280,
                width: double.infinity,
              ),
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                serviceDetails!["service_name"] ?? "Service",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            leading: Padding(
              padding: EdgeInsets.only(left: 10),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColor.primary,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          serviceDetails!["category_name"] ?? "Catégorie",
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 4),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    "À propos",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.secondaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          Icons.location_on,
                          serviceDetails!["location"]?["address"] ??
                              "Adresse non spécifiée",
                        ),
                        _buildInfoRow(
                          Icons.info_outline,
                          serviceDetails!["description"] ??
                              "Aucune description",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  if (events.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Événements à venir",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return _buildEventCard(events[index]);
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                  if (serviceDetails?["location"]?["geo"] != null) ...[
                    Text(
                      "Localisation",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            FlutterMap(
                              options: MapOptions(
                                center: LatLng(
                                  serviceDetails!["location"]["geo"]["lat"]
                                          ?.toDouble() ??
                                      0,
                                  serviceDetails!["location"]["geo"]["lng"]
                                          ?.toDouble() ??
                                      0,
                                ),
                                zoom: 15.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: ['a', 'b', 'c'],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      width: 50,
                                      height: 50,
                                      point: LatLng(
                                        serviceDetails!["location"]["geo"]
                                                    ["lat"]
                                                ?.toDouble() ??
                                            0,
                                        serviceDetails!["location"]["geo"]
                                                    ["lng"]
                                                ?.toDouble() ??
                                            0,
                                      ),
                                      builder: (ctx) => Container(
                                        child: Icon(
                                          Icons.location_pin,
                                          color: AppColor.primary,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: FloatingActionButton(
                                backgroundColor: AppColor.primary,
                                onPressed: () => _openMaps(
                                  serviceDetails!["location"]["geo"]["lat"]
                                      ?.toDouble(),
                                  serviceDetails!["location"]["geo"]["lng"]
                                      ?.toDouble(),
                                ),
                                child:
                                    Icon(Icons.navigation, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}
