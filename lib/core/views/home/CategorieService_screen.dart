import 'package:flutter/material.dart';
import 'package:fasyl/core/config/constants.dart';
import 'package:fasyl/core/services/service.dart';
import 'package:fasyl/core/views/home/DetailService_screen.dart';

class CategorieServiceScreen extends StatefulWidget {
  final String categoryId;

  const CategorieServiceScreen({super.key, required this.categoryId});

  @override
  _CategorieServiceScreenState createState() => _CategorieServiceScreenState();
}

class _CategorieServiceScreenState extends State<CategorieServiceScreen> {
  final Service _service = Service();
  final List<Map<String, dynamic>> _services = [];
  final bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    // try {
    //   final services = await _service.getByCategory(widget.categoryId);
    //   setState(() {
    //     _services = List<Map<String, dynamic>>.from(services ?? []);
    //     _isLoading = false;
    //   });
    // } catch (e) {
    //   print('Error loading services: $e');
    //   setState(() => _isLoading = false);
    // }
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: AppColor.secondaryDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailServiceScreen(serviceId: service['_id']),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: AppColor.primaryLighter,
                  child:
                      service["photos"] != null && service["photos"].isNotEmpty
                          ? Image.network(
                              service["photos"][0],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.image, color: Colors.white),
                            )
                          : Icon(Icons.image, color: Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['service_name'] ?? 'Service',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColor.primary, size: 16),
                        SizedBox(width: 4),
                        Text(
                          service['rating']?.toStringAsFixed(1) ?? '0.0',
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.attach_money,
                            color: AppColor.primary, size: 16),
                        SizedBox(width: 4),
                        Text(
                          service['price']?.toString() ?? '0',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.white70),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${service["location"]?["address"] ?? ''} ${service["location"]?["city"] ?? ''}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondary,
      appBar: AppBar(
        backgroundColor: AppColor.secondary,
        elevation: 0,
        title: Text("Name Categorie", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColor.primary))
          : RefreshIndicator(
              onRefresh: _loadServices,
              color: AppColor.primary,
              child: _services.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun service dans cette catégorie',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        Text(
                          '${_services.length} services disponibles',
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 16),
                        ..._services.map(_buildServiceItem),
                      ],
                    ),
            ),
    );
  }
}
