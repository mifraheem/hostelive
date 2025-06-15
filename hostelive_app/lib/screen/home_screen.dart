import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hostelive_app/constant.dart';
import 'package:hostelive_app/screen/add_property.dart';
import 'package:hostelive_app/screen/propertydetail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = 'Unknown User';
  String? errorMessage;
  String _errorMessage = '';
  bool isLoading = true;
  final _storage = const FlutterSecureStorage();
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _properties = [];
  List<Map<String, dynamic>> _feedbacks = [];
  bool _isLoadingProperties = false;
  bool _isLoadingFeedbacks = false;
  int _totalFeedbackCount = 0; // Store total feedback count separately

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _fetchProperties();
  }

  Future<String?> _loadToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> _fetchUsername() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      String? storedUsername = await _storage.read(key: 'username');
      if (storedUsername != null) {
        setState(() {
          username = storedUsername;
          isLoading = false;
        });
      } else {
        String? token = await _storage.read(key: 'access_token');
        if (token != null) {
          try {
            final response = await http.get(
              Uri.parse('$baseUrl/api/auth/user/'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            );
            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              setState(() {
                username = data['username'] ?? 'Unknown User';
                isLoading = false;
              });
              await _storage.write(key: 'username', value: username);
            } else if (response.statusCode == 401) {
              await _logout();
            } else {
              setState(() {
                errorMessage = 'Unable to fetch user data. Please try again.';
                isLoading = false;
              });
            }
          } catch (e) {
            setState(() {
              errorMessage = 'Network error. Please check your connection.';
              isLoading = false;
            });
          }
        } else {
          await _logout();
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Something went wrong. Please try logging in again.';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchProperties() async {
    setState(() {
      _isLoadingProperties = true;
    });

    try {
      String? token = await _storage.read(key: 'access_token');
      if (token != null) {
        final response = await http.get(
          Uri.parse('$baseUrl/api/listings/properties/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          setState(() {
            _properties = List<Map<String, dynamic>>.from(data);
            _isLoadingProperties = false;
          });

          // Debug: Print properties to check if they have IDs
          print('Properties loaded: ${_properties.length}');
          for (var property in _properties) {
            print(
              'Property ID: ${property['id']}, Name: ${property['name'] ?? property['title']}',
            );
          }

          // After properties are loaded, fetch total feedbacks count
          _fetchTotalFeedbacksCount();
        } else if (response.statusCode == 401) {
          await _logout();
        } else {
          setState(() {
            _isLoadingProperties = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to load properties: ${response.statusCode}',
              ),
              backgroundColor: const Color(0xFFE6C871),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingProperties = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: const Color(0xFFE6C871),
        ),
      );
    }
  }

  // Updated method to fetch total feedbacks count with better error handling
  Future<void> _fetchTotalFeedbacksCount() async {
    if (_properties.isEmpty) {
      setState(() {
        _totalFeedbackCount = 0;
      });
      return;
    }

    setState(() {
      _isLoadingFeedbacks = true;
      _errorMessage = '';
    });

    try {
      final token = await _loadToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      int totalCount = 0;

      // Try different API endpoints to find the correct one
      for (var property in _properties) {
        final propertyId = property['id'];
        if (propertyId == null) continue;

        try {
          // Try the property-specific endpoint first
          var response = await http.get(
            Uri.parse('$baseUrl/api/listings/feedbacks/property/$propertyId/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          print(
            'Feedback API Response for property $propertyId: ${response.statusCode}',
          );
          print('Response body: ${response.body}');

          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            totalCount += data.length;
            print('Found ${data.length} feedbacks for property $propertyId');
          } else if (response.statusCode == 404) {
            // If property-specific endpoint doesn't exist, try general endpoint
            print(
              'Property-specific endpoint not found, trying general endpoint',
            );
            response = await http.get(
              Uri.parse(
                '$baseUrl/api/listings/feedbacks/?property_id=$propertyId',
              ),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            );

            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              if (data is List) {
                totalCount += data.length;
              } else if (data is Map && data['results'] != null) {
                totalCount += (data['results'] as List).length;
              }
            }
          } else {
            print(
              'Failed to fetch feedbacks for property $propertyId: ${response.statusCode}',
            );
          }
        } catch (e) {
          print('Error fetching feedbacks for property $propertyId: $e');
        }
      }

      setState(() {
        _totalFeedbackCount = totalCount;
        _isLoadingFeedbacks = false;
      });

      print('Total feedbacks count: $totalCount');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading feedbacks: $e';
        _isLoadingFeedbacks = false;
        _totalFeedbackCount = 0;
      });
      print('Error in _fetchTotalFeedbacksCount: $e');
    }
  }

  // Alternative method to fetch all feedbacks at once (if API supports it)
  Future<void> _fetchAllFeedbacks() async {
    setState(() {
      _isLoadingFeedbacks = true;
      _errorMessage = '';
    });

    try {
      final token = await _loadToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      // Try to fetch all feedbacks for the user
      final response = await http.get(
        Uri.parse('$baseUrl/api/listings/feedbacks/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('All feedbacks API Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> feedbacksList = [];

        if (data is List) {
          feedbacksList = data;
        } else if (data is Map && data['results'] != null) {
          feedbacksList = data['results'];
        }

        setState(() {
          _feedbacks = List<Map<String, dynamic>>.from(feedbacksList);
          _totalFeedbackCount = _feedbacks.length;
          _isLoadingFeedbacks = false;
        });

        print('Total feedbacks loaded: ${_feedbacks.length}');
      } else {
        throw Exception(
          'Failed to load feedbacks: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading feedbacks: $e';
        _isLoadingFeedbacks = false;
        _totalFeedbackCount = 0;
      });
      print('Error in _fetchAllFeedbacks: $e');
    }
  }

  Future<void> _logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'username');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Hostelive',
              style: TextStyle(
                color: Color(0xFFE6C871),
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF3B5A7A),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFE6C871)),
            onPressed: () {
              _fetchUsername();
              _fetchProperties();
              // Try alternative method if the first one doesn't work
              _fetchAllFeedbacks();
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B5A7A)),
              )
              : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_home_work),
            label: 'My Properties',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF3B5A7A),
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
      floatingActionButton:
          _selectedIndex == 1
              ? FloatingActionButton(
                backgroundColor: const Color(0xFFE6C871),
                child: const Icon(Icons.add, color: Color(0xFF3B5A7A)),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => AddPropertyPage(),
                        ),
                      )
                      .then((_) => _fetchProperties());
                },
              )
              : null,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildPropertiesTab();
      case 2:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, $username!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B5A7A),
              ),
            ),
            const SizedBox(height: 20),
            if (errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6C871).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE6C871).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: const Color(0xFFE6C871),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Color(0xFFE6C871)),
                      ),
                    ),
                  ],
                ),
              ),

            // Debug info (remove in production)
            if (_errorMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  'Debug: $_errorMessage',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            const SizedBox(height: 20),
            Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  'Properties',
                  _properties.length.toString(),
                  Icons.home,
                  const Color(0xFF3B5A7A),
                ),
                _buildStatCard(
                  'Active',
                  _properties
                      .where((p) => p['is_active'] == true)
                      .length
                      .toString(),
                  Icons.check_circle,
                  const Color(0xFF3B5A7A),
                ),
                _buildStatCard(
                  'Inactive',
                  _properties
                      .where(
                        (p) =>
                            p['is_active'] == false || p['not_active'] == true,
                      )
                      .length
                      .toString(),
                  Icons.cancel,
                  const Color(0xFF3B5A7A),
                ),
                _buildStatCard(
                  'Total Feedback',
                  _isLoadingFeedbacks ? '...' : _totalFeedbackCount.toString(),
                  Icons.feedback,
                  const Color(0xFF3B5A7A),
                  onTap: () {
                    _showFeedbacksDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showFeedbacksDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Feedbacks Overview'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Feedbacks: $_totalFeedbackCount'),
              const SizedBox(height: 10),
              const Text(
                'Navigate to individual property details to see specific feedbacks.',
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Error: $_errorMessage',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Retry fetching feedbacks
                _fetchTotalFeedbacksCount();
                _fetchAllFeedbacks();
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesTab() {
    if (_isLoadingProperties) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3B5A7A)),
      );
    }

    if (_properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No properties found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first property',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      itemCount: _properties.length,
      itemBuilder: (context, index) {
        final property = _properties[index];
        final screenWidth = MediaQuery.of(context).size.width;
        final thumbnailSize = screenWidth * 0.12 > 80 ? 80 : screenWidth * 0.12;
        final padding = screenWidth > 600 ? 24.0 : 20.0;
        final fontSizeTitle = screenWidth > 600 ? 22.0 : 20.0;
        final fontSizeSubtitle = screenWidth > 600 ? 16.0 : 14.0;

        return TweenAnimationBuilder(
          duration: const Duration(milliseconds: 400),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeOut,
          builder: (context, opacity, child) {
            return Opacity(
              opacity: opacity,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              PropertyDetailsPage(propertyId: property['id']),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  transform: Matrix4.identity()..scale(opacity),
                  transformAlignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: padding * 0.4,
                      horizontal: padding * 0.2,
                    ),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                      shadowColor: Colors.grey[300]!.withOpacity(0.3),
                      child: Padding(
                        padding: EdgeInsets.all(padding * 0.8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: thumbnailSize.toDouble(),
                                height: thumbnailSize.toDouble(),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 0.5,
                                  ),
                                ),
                                child:
                                    property['thumbnail'] != null &&
                                            property['thumbnail'].isNotEmpty
                                        ? Image.network(
                                          property['thumbnail'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Center(
                                              child: Icon(
                                                Icons.home_work,
                                                size: thumbnailSize * 0.5,
                                                color: Colors.grey[500],
                                              ),
                                            );
                                          },
                                        )
                                        : Center(
                                          child: Icon(
                                            Icons.home_work,
                                            size: thumbnailSize * 0.5,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                              ),
                            ),
                            SizedBox(width: padding * 0.8),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    property['title'] ?? 'Unnamed Property',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: fontSizeTitle,
                                      color: const Color(0xFF2A3F5F),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: padding * 0.3),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: fontSizeSubtitle * 0.9,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: padding * 0.3),
                                      Expanded(
                                        child: Text(
                                          '${property['address'] ?? 'No address'}, ${property['city'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: fontSizeSubtitle * 0.95,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: padding * 0.3),
                                  Text(
                                    property['description'] ??
                                        'No description available',
                                    style: TextStyle(
                                      fontSize: fontSizeSubtitle * 0.9,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Trailing Arrow
                            Padding(
                              padding: EdgeInsets.only(left: padding * 0.5),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: fontSizeSubtitle,
                                color: const Color(0xFFE6C871),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF3B5A7A).withOpacity(0.1),
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B5A7A),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B5A7A),
              ),
            ),
            const SizedBox(height: 40),
            _buildProfileMenuItem(Icons.settings, 'Settings'),
            _buildProfileMenuItem(Icons.help, 'Help & Support'),
            _buildProfileMenuItem(Icons.privacy_tip, 'Privacy Policy'),
            _buildProfileMenuItem(Icons.info, 'About'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE6C871),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Color(0xFF3B5A7A)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3B5A7A)),
      title: Text(title, style: const TextStyle(color: Color(0xFF3B5A7A))),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFFE6C871),
      ),
      onTap: () {
        // Handle menu item tap
      },
    );
  }
}
