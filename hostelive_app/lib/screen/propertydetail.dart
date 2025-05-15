import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hostelive_app/screen/add_room.dart';
import 'package:hostelive_app/screen/room_list.dart';
import 'package:http/http.dart' as http;

class PropertyDetailsPage extends StatefulWidget {
  final int propertyId;

  const PropertyDetailsPage({super.key, required this.propertyId});

  @override
  _PropertyDetailsPageState createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  Map<String, dynamic>? _property;
  bool _isLoading = true;
  String? _errorMessage;
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = 'http://10.0.2.2:8000';
  final GlobalKey<RoomsListWidgetState> _roomsListKey =
      GlobalKey<RoomsListWidgetState>();
  Map<int, String> _propertyTypes = {};

  @override
  void initState() {
    super.initState();
    _fetchPropertyTypes();
    _fetchPropertyDetails();
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> _fetchPropertyTypes() async {
    try {
      String? token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$_baseUrl/api/listings/types/'), // Correct endpoint
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _propertyTypes = {
            for (var type in data) type['id'] as int: type['name'] as String,
          };
        });
      } else {
        throw Exception(
          'Failed to load property types: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching property types: $e');
      // You can keep a fallback if needed
      setState(() {
        _propertyTypes = {1: 'Hostel', 2: 'VGV', 3: 'HGJHGJ'};
      });
    }
  }

  Future<void> _fetchPropertyDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$_baseUrl/api/listings/properties/${widget.propertyId}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _property = data;
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _errorMessage =
              'Failed to load property details: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePropertyStatus(bool currentStatus) async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.patch(
        Uri.parse('$_baseUrl/api/listings/properties/${widget.propertyId}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'is_active': !currentStatus}),
      );

      if (response.statusCode == 200) {
        _fetchPropertyDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Property status updated to ${!currentStatus ? 'Active' : 'Inactive'}',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update property status: ${response.statusCode}',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _navigateToAddRoom() {
    if (_property != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => AddRoomPage(
                propertyId: widget.propertyId,
                propertyName: _property!['title'] ?? 'Unknown Property',
              ),
        ),
      ).then((_) {
        // Refresh the rooms list when returning from add room
        if (_roomsListKey.currentState != null) {
          _roomsListKey.currentState!.refreshRooms();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            _property != null
                ? _property!['title'] ?? 'Property Details'
                : 'Property Details',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchPropertyDetails,
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: const [Tab(text: 'Details'), Tab(text: 'Rooms')],
          ),
        ),
        body:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.purple,
                    strokeWidth: 3,
                  ),
                )
                : _errorMessage != null
                ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading property',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _fetchPropertyDetails,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : TabBarView(
                  children: [
                    _buildDetailsTab(),
                    RoomsListWidget(
                      key: _roomsListKey,
                      propertyId: widget.propertyId,
                      propertyName: _property!['title'] ?? 'Unknown Property',
                    ),
                  ],
                ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddRoom,
          backgroundColor: Colors.purple,
          child: const Icon(Icons.add),
          tooltip: 'Add Room',
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }

  Widget _buildDetailsTab() {
    // Debug print to inspect the property type data
    print('Property type: ${_property!['type']}');
    print('Property type runtime type: ${_property!['type'].runtimeType}');

    // Extract property type name
    String propertyTypeName = 'Unknown';
    if (_property!['type'] != null) {
      if (_property!['type'] is Map<String, dynamic>) {
        propertyTypeName =
            (_property!['type'] as Map<String, dynamic>)['name'] ?? 'Unknown';
      } else if (_property!['type'] is int) {
        propertyTypeName = _propertyTypes[_property!['type']] ?? 'Unknown';
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade300, Colors.purple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _property!['title'] ?? 'Unnamed Property',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 20, color: Colors.white70),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_property!['address'] ?? 'No address'}, ${_property!['city'] ?? ''}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        _property!['is_active'] == true
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 20,
                        color:
                            _property!['is_active'] == true
                                ? Colors.green
                                : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _property!['is_active'] == true ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color:
                              _property!['is_active'] == true
                                  ? Colors.green
                                  : Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoTile(
            icon: Icons.category,
            title: 'Property Type',
            value: propertyTypeName,
          ),
          _buildInfoTile(
            icon: Icons.description,
            title: 'Description',
            value: _property!['description'] ?? 'No description provided',
          ),
          if ((_property!['shared_facilities'] as List?)?.isNotEmpty ??
              false) ...[
            Text(
              'Facilities',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var facility in (_property!['shared_facilities'] as List))
                  Chip(
                    label: Text(
                      facility['name'],
                      style: const TextStyle(fontSize: 14),
                    ),
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    side: BorderSide(color: Colors.purple.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  () => _togglePropertyStatus(_property!['is_active'] ?? false),
              icon: Icon(
                _property!['is_active'] == true
                    ? Icons.no_accounts
                    : Icons.check_circle_outline,
              ),
              label: Text(
                _property!['is_active'] == true
                    ? 'Mark Inactive'
                    : 'Mark Active',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    _property!['is_active'] == true ? Colors.red : Colors.green,
                side: BorderSide(
                  color:
                      _property!['is_active'] == true
                          ? Colors.red
                          : Colors.green,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.purple, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
