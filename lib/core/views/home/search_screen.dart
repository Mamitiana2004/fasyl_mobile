import 'package:flutter/material.dart';
import 'package:fasyl/core/config/constants.dart';
import 'package:fasyl/core/views/home/DetailService_screen.dart';

class SearchScreen extends StatefulWidget {
  final String searchQuery;
  final List<Map<String, dynamic>> searchResults;

  const SearchScreen({
    required this.searchQuery,
    required this.searchResults,
    super.key,
  });

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondary,
      appBar: AppBar(
        backgroundColor: AppColor.secondary,
        elevation: 0,
        title: Text(
          'Résultats pour "${widget.searchQuery}"',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: widget.searchResults.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.white54),
                  SizedBox(height: 16),
                  Text(
                    'Aucun résultat trouvé',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: widget.searchResults.length,
              itemBuilder: (context, index) {
                final service = widget.searchResults[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailServiceScreen(serviceId: service['_id']),
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColor.secondaryDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColor.primaryLighter,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: service["photos"] != null &&
                                service["photos"].length > 0
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  service["photos"][0],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.broken_image,
                                          color: Colors.white),
                                ),
                              )
                            : Center(
                                child: Icon(Icons.image, color: Colors.white)),
                      ),
                      title: Text(
                        service["service_name"] ?? 'Service',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${service['price'] ?? 'N/A'} XOF',
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: Icon(Icons.chevron_right, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
    );
  }
}