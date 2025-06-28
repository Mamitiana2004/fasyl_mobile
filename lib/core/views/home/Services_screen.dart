import 'package:flutter/material.dart';
import 'package:fasyl/core/config/constants.dart';
import 'package:fasyl/core/services/categorie_service.dart';
import 'package:fasyl/core/services/service.dart';
import 'package:fasyl/core/views/home/DetailService_screen.dart';
import 'package:fasyl/widgets/CustomBottomNavigationBar.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final CategorieService _categorieService = CategorieService();
  final Service _service = Service();

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _filteredServices = [];
  String _searchQuery = '';
  String? _selectedCategoryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _categorieService.getAllCategorie(),
        _service.getAll(),
      ]);

      setState(() {
        _categories = List<Map<String, dynamic>>.from(results[0] ?? []);
        _services = List<Map<String, dynamic>>.from(results[1] ?? []);
        _filteredServices = _services;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterServices() {
    setState(() {
      _filteredServices = _services.where((service) {
        final matchesSearch = service['service_name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        
        final matchesCategory = _selectedCategoryId == null || 
            service['category_id'] == _selectedCategoryId;
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Widget _buildCategoryChip(Map<String, dynamic> category) {
    final isSelected = _selectedCategoryId == category['_id'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = isSelected ? null : category['_id'];
          _filterServices();
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColor.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          category['name'],
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailServiceScreen(serviceId: service['_id']),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 100,
                  color: AppColor.primaryLighter.withOpacity(0.3),
                  child: service["photos"] != null && service["photos"].isNotEmpty
                      ? Image.network(
                          service["photos"][0],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(Icons.image_search, 
                              color: Colors.white.withOpacity(0.5)),
                          ),
                        )
                      : Center(
                          child: Icon(Icons.image_search, 
                            color: Colors.white.withOpacity(0.5)),
                ),
              ),),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fasyl',
                      style: TextStyle(
                        color: AppColor.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      service['service_name'] ?? 'Service',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, 
                          size: 16, 
                          color: Colors.white70),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${service["location"]?["city"] ?? 'Ville inconnue'}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(AppColor.primary),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    right: 16,
                    bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Services',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search, 
                          color: AppColor.primary, 
                          size: 28),
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: ServiceSearchDelegate(services: _services),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterServices();
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColor.secondaryLight,
                      hintText: 'Rechercher un service...',
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = null;
                            _filterServices();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            gradient: _selectedCategoryId == null
                                ? LinearGradient(
                                    colors: [AppColor.primary, AppColor.primaryLight],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: _selectedCategoryId == null
                                ? null
                                : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedCategoryId == null
                                  ? Colors.transparent
                                  : Colors.grey.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'Tous',
                            style: TextStyle(
                              color: _selectedCategoryId == null
                                  ? Colors.white
                                  : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      ..._categories.map(_buildCategoryChip),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppColor.primary,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: _filteredServices.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off,
                                    size: 60,
                                    color: Colors.white.withOpacity(0.3)),
                                  SizedBox(height: 16),
                                  Text(
                                    'Aucun service trouvé',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Essayez une autre recherche',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView(
                              children: [
                                Text(
                                  '${_filteredServices.length} services disponibles',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 12),
                                ..._filteredServices.map(_buildServiceCard),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}

class ServiceSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final List<Map<String, dynamic>> services;

  ServiceSearchDelegate({required this.services});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: AppColor.secondary,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColor.secondaryDark,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: Colors.white70),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white70),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = services.where((service) =>
        service['service_name'].toString().toLowerCase().contains(query.toLowerCase())).toList();

    return _buildSearchResults(results);
  }

  @override
Widget buildSuggestions(BuildContext context) {
  final List<Map<String, dynamic>> suggestions = query.isEmpty
      ? []
      : services.where((service) {
          return service['service_name'].toString().toLowerCase().contains(query.toLowerCase());
        }).toList();

  return _buildSearchResults(suggestions);
}

  Widget _buildSearchResults(List<Map<String, dynamic>> results) {
    return Container(
      color: AppColor.secondary,
      child: ListView.builder(
        padding: EdgeInsets.only(top: 16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final service = results[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.secondaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColor.primaryLighter.withOpacity(0.3),
                  ),
                  child: service["photos"] != null && service["photos"].isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            service["photos"][0],
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.image_search, 
                          color: Colors.white.withOpacity(0.5)),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fasyl',
                      style: TextStyle(
                        color: AppColor.primary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      service['service_name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  service['category_name'] ?? 'Catégorie inconnue',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.white70),
                onTap: () {
                  close(context, service);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}