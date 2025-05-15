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
  bool isLoading = true;
  final _storage = const FlutterSecureStorage();
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _properties = [];
  bool _isLoadingProperties = false;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _fetchProperties();
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
              backgroundColor: Colors.red,
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
          backgroundColor: Colors.red,
        ),
      );
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
        title: const Text(
          'Hostelive',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchUsername();
              _fetchProperties();
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.purple),
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
        selectedItemColor: Colors.purple,
        onTap: _onItemTapped,
      ),
      floatingActionButton:
          _selectedIndex == 1
              ? FloatingActionButton(
                backgroundColor: Colors.purple,
                child: const Icon(Icons.add),
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ),
                  ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  'Properties',
                  _properties.length.toString(),
                  Icons.home,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Active',
                  _properties
                      .where((p) => p['is_active'] == true)
                      .length
                      .toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
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
          Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPropertiesTab() {
    if (_isLoadingProperties) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.purple),
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
      padding: const EdgeInsets.all(12),
      itemCount: _properties.length,
      itemBuilder: (context, index) {
        final property = _properties[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.purple.shade50,
              radius: 25,
              child: Icon(Icons.home_work, color: Colors.purple, size: 30),
            ),
            title: Text(
              property['title'] ?? 'Unnamed Property',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${property['address'] ?? 'No address'}, ${property['city'] ?? ''}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      property['is_active'] == true
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 16,
                      color:
                          property['is_active'] == true
                              ? Colors.green
                              : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      property['is_active'] == true ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color:
                            property['is_active'] == true
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            PropertyDetailsPage(propertyId: property['id']),
                  ),
                );
              },
            ),
          ),
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
              backgroundColor: Colors.purple.shade100,
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                backgroundColor: Colors.red,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Handle menu item tap
      },
    );
  }
}
