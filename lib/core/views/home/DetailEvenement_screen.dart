import 'dart:convert';
import 'dart:typed_data';

import 'package:fasyl/core/config/constants.dart';
import 'package:fasyl/core/services/service.dart';
import 'package:fasyl/widgets/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';

class DetailEvenementScreen extends StatefulWidget {
  final String eventId;

  const DetailEvenementScreen({super.key, required this.eventId});

  @override
  _DetailEvenementState createState() => _DetailEvenementState();
}

class _DetailEvenementState extends State<DetailEvenementScreen> {
  Map<String, dynamic>? serviceDetails;
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServiceDetails();
  }

  Future<void> _loadServiceDetails() async {
    try {
      final service = await Service().getById(widget.eventId);
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
      SnackBar(content: Text(message)),
    );
  }

  bool isBase64Image(String imageString) {
    if (imageString.startsWith('http://') ||
        imageString.startsWith('https://')) {
      return false;
    }
    if (imageString.startsWith('data:image')) {
      return true;
    }
    final base64Regex = RegExp(r'^[a-zA-Z0-9+/]+={0,2}\$');
    return base64Regex.hasMatch(imageString) && imageString.length % 4 == 0;
  }

  Uint8List? decodeBase64ImageWithHeader(String base64WithHeader) {
    try {
      final commaIndex = base64WithHeader.indexOf(',');
      final pureBase64 = commaIndex == -1
          ? base64WithHeader
          : base64WithHeader.substring(commaIndex + 1);
      return base64Decode(pureBase64);
    } catch (e) {
      print('Erreur de décodage base64: $e');
      return null;
    }
  }

  Widget _buildImageWidget(String? imageUrl,
      {double width = 100, double height = 100}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return SizedBox.shrink();
    }

    if (isBase64Image(imageUrl)) {
      final decodedImage = decodeBase64ImageWithHeader(imageUrl);
      return decodedImage != null
          ? Image.memory(decodedImage,
              width: width, height: height, fit: BoxFit.cover)
          : Icon(Icons.broken_image, size: width);
    } else {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.broken_image, size: width),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColor.secondary,
        body: Center(child: CircularProgressIndicator()),
      );
    }


    return Scaffold(
      backgroundColor: AppColor.secondary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon:
                        Icon(Icons.chevron_left, size: 24, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(AppColor.secondary),
                      shape: WidgetStateProperty.all(CircleBorder(
                        side: BorderSide(color: Colors.black, width: 1),
                      )),
                    ),
                  ),
                  Spacer(),
                  Text(
                    "Détails",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}
