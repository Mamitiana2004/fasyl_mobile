import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fasyl/core/config/constants.dart';
import 'package:fasyl/core/services/categorie_service.dart';
import 'package:fasyl/core/services/service.dart';
import 'package:fasyl/core/views/home/DetailService_screen.dart';
import 'package:fasyl/core/views/home/search_screen.dart';
import 'package:fasyl/widgets/CustomBottomNavigationBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CategorieService _categorieService = CategorieService();
  final Service _service = Service();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _popularServices = [];
  List<Map<String, dynamic>> _filteredServices = [];
  List<String> _searchHistory = [];
  
  int _currentPage = 1;
  final int _itemsPerPage = 5;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadSearchHistory();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _categorieService.getAllCategorie(),
        _service.getAllPopular(),
        _service.getAll(),
      ]);

      setState(() {
        _categories = List<Map<String, dynamic>>.from(results[0] ?? []);
        _popularServices = List<Map<String, dynamic>>.from(results[1] ?? []);
        _services = List<Map<String, dynamic>>.from(results[2] ?? []);
        _filteredServices = _services.take(_itemsPerPage).toList();
      });
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    if (_isLoadingMore || (_currentPage * _itemsPerPage) >= _services.length) return;
    
    setState(() => _isLoadingMore = true);
    
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _currentPage++;
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = startIndex + _itemsPerPage;
        _filteredServices.addAll(_services.sublist(
          startIndex,
          endIndex > _services.length ? _services.length : endIndex,
        ));
        _isLoadingMore = false;
      });
    });
  }

  void _performSearch(String query) async {
    if (query.isEmpty) return;

    if (!_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 5) _searchHistory.removeLast();
      });
      await _saveSearchHistory();
    }

    final results = _services.where((service) {
      final name = service['service_name']?.toString().toLowerCase() ?? '';
      final category = service['category']?.toString().toLowerCase() ?? '';
      final location = service['location']?['city']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase()) ||
          category.contains(query.toLowerCase()) ||
          location.contains(query.toLowerCase());
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          searchQuery: query,
          searchResults: results,
        ),
      ),
    );
  }

  void _filterByCategory(int index) {
    setState(() => _selectedCategoryIndex = index);
    
    if (index == 0) { // Tous
      setState(() {
        _filteredServices = _services.take(_itemsPerPage).toList();
        _currentPage = 1;
      });
    } else {
      final selectedCategory = _categories[index - 1];
      setState(() {
        _filteredServices = _services
            .where((s) => s['category'] == selectedCategory['name'])
            .take(_itemsPerPage)
            .toList();
        _currentPage = 1;
      });
    }
  }

  Widget _buildCategoryChip(Map<String, dynamic> category, int index) {
    final isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () => _filterByCategory(index),
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : AppColor.secondaryLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColor.primary : AppColor.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category['icon'] != null) ...[
              Icon(
                IconData(category['icon'], fontFamily: 'MaterialIcons'),
                color: isSelected ? Colors.white : AppColor.primary,
                size: 18,
              ),
              SizedBox(width: 8),
            ],
            Text(
              category['name'],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, {bool isPopular = false}) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColor.secondaryDark,
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailServiceScreen(serviceId: service['_id']),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: isPopular ? 140 : 160,
                color: AppColor.primaryLighter,
                child: service["photos"] != null && service["photos"].length > 0
                    ? Image.network(
                        service["photos"][0],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(
                      service['category'] ?? 'Catégorie',
                      style: TextStyle(fontSize: 12),
                    ),
                    backgroundColor: AppColor.primary,
                    labelPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  SizedBox(height: 8),
                  Text(
                    service["service_name"] ?? 'Service',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isPopular ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.white70),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${service["location"]?["address"] ?? ''}, ${service["location"]?["city"] ?? ''}',
                          style: TextStyle(color: Colors.white70),
                          maxLines: 1,
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
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(Icons.image_search, size: 50, color: Colors.white54),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondary,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColor.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColor.primary,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    backgroundColor: AppColor.secondary,
                    elevation: 0,
                    pinned: true,
                    expandedHeight: 120,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true, // Titre centré
                      title: Text(
                        'FASYL',
                        style: TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColor.secondary,
                              AppColor.secondaryDark,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.secondaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Rechercher un service...",
                            hintStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(Icons.search, color: Colors.white70),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          style: TextStyle(color: Colors.white),
                          onSubmitted: _performSearch,
                          onTap: () {
                            showSearch(
                              context: context,
                              delegate: CustomSearchDelegate(
                                searchHistory: _searchHistory,
                                allServices: _services,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildCategoryChip(
                                {'name': 'Tous', 'icon': Icons.all_inclusive.codePoint},
                                index,
                              );
                            }
                            return _buildCategoryChip(_categories[index - 1], index);
                          },
                        ),
                      ),
                    ),
                  ),
                  if (_popularServices.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Services populaires',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (_popularServices.isNotEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _popularServices.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 240,
                                child: _buildServiceCard(
                                  _popularServices[index],
                                  isPopular: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'Tous les services',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == _filteredServices.length) {
                            return _filteredServices.length < _services.length
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(color: AppColor.primary),
                                    ),
                                  )
                                : SizedBox();
                          }
                          return _buildServiceCard(_filteredServices[index]);
                        },
                        childCount: _filteredServices.length + 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<String> searchHistory;
  final List<Map<String, dynamic>> allServices;

  CustomSearchDelegate({
    required this.searchHistory,
    required this.allServices,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allServices.where((service) {
      final name = service['service_name']?.toString().toLowerCase() ?? '';
      final category = service['category']?.toString().toLowerCase() ?? '';
      final location = service['location']?['city']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase()) ||
          category.contains(query.toLowerCase()) ||
          location.contains(query.toLowerCase());
    }).toList();

    return SearchScreen(
      searchQuery: query,
      searchResults: results,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? searchHistory
        : allServices
            .where((service) {
              final name = service['service_name']?.toString().toLowerCase() ?? '';
              return name.contains(query.toLowerCase());
            })
            .map((service) => service['service_name'].toString())
            .toList();

    return Container(
      color: AppColor.secondary,
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: ListTile(
              leading: query.isEmpty 
                  ? Icon(Icons.history, color: Colors.white70)
                  : Icon(Icons.search, color: Colors.white70),
              title: Text(
                suggestion,
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                query = suggestion;
                showResults(context);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColor.secondary,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
    );
  }
}