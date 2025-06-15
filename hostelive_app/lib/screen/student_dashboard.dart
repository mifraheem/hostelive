import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hostelive_app/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final FlutterSecureStorage _storage = const FlutterSecureStorage();

Future<String?> getAccessToken() async {
  final token = await _storage.read(key: 'access_token');
  print('🔐 [Token] Loaded access_token: $token');
  return token;
}

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  String _username = 'Student';
  late TabController _tabController;

  List<dynamic> _properties = [];
  List<dynamic> _rooms = [];
  bool _isLoadingProperties = false;
  bool _isLoadingRooms = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _fetchProperties();
    _fetchRooms();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final username = await _storage.read(key: 'username');
    setState(() {
      _username = username ?? 'Student';
    });
    print('StudentDashboard _loadUserData - username: $username');
  }

  Future<String?> _loadToken() async {
    final token = await _storage.read(key: 'access_token');
    print('📦 StudentDashboard - Using access_token: $token');
    return token;
  }

  Future<void> _fetchProperties() async {
    setState(() {
      _isLoadingProperties = true;
      _errorMessage = '';
    });

    try {
      final token = await _loadToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/listings/properties/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _properties = data;
          _isLoadingProperties = false;
        });
      } else {
        throw Exception(
          'Failed to load properties: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading properties: $e';
        _isLoadingProperties = false;
      });
    }
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoadingRooms = true;
      _errorMessage = '';
    });

    try {
      final token = await _loadToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/listings/rooms/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _rooms = data;
          _isLoadingRooms = false;
        });
      } else {
        throw Exception(
          'Failed to load rooms: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading rooms: $e';
        _isLoadingRooms = false;
      });
    }
  }

  Future<void> _logout() async {
    await _storage.deleteAll();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B5A7A),
        title: const Text(
          'Student Dashboard',
          style: TextStyle(
            color: Color(0xFFE6C871),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Color(0xFFE6C871)),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(color: Color(0xFF3B5A7A)),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home_work), text: 'Properties'),
            Tab(icon: Icon(Icons.room), text: 'Rooms'),
          ],
          labelColor: const Color(0xFFE6C871),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFFE6C871),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildPropertiesTab(), _buildRoomsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesTab() {
    if (_isLoadingProperties) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE6C871)),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchProperties,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE6C871),
                foregroundColor: const Color(0xFF3B5A7A),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work_outlined, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No properties available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _properties.length,
      itemBuilder: (context, index) {
        final property = _properties[index];
        return GestureDetector(
          onTap: () async {
            final token = await _loadToken();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PropertyDetailPage(
                      property: property,
                      initialToken: token, // pass the actual access_token
                    ),
              ),
            );
          },

          child: _buildPropertyCard(property),
        );
      },
    );
  }

  Widget _buildRoomsTab() {
    if (_isLoadingRooms) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE6C871)),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRooms,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE6C871),
                foregroundColor: const Color(0xFF3B5A7A),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.room_outlined, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No rooms available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        final room = _rooms[index];
        return _buildRoomCard(room);
      },
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B5A7A).withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 180,
              width: double.infinity,
              color: const Color(0xFFE6C871).withOpacity(0.3),
              child:
                  property['thumbnail'] != null &&
                          property['thumbnail'].isNotEmpty
                      ? Image.network(
                        property['thumbnail'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.home_work,
                              size: 64,
                              color: Color(0xFFE6C871),
                            ),
                          );
                        },
                      )
                      : const Center(
                        child: Icon(
                          Icons.home_work,
                          size: 64,
                          color: Color(0xFFE6C871),
                        ),
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      property['title'] ?? 'Property',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B5A7A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            property['is_active'] == true
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        property['is_active'] == true ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:
                              property['is_active'] == true
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${property['address'] ?? ''}, ${property['city'] ?? ''}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.description, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property['description'] ?? 'No description available',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
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
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B5A7A).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Container(
              height: 180,
              width: double.infinity,
              color: const Color(0xFFE6C871).withOpacity(0.3),
              child:
                  room['thumbnail'] != null && room['thumbnail'].isNotEmpty
                      ? Image.network(
                        room['thumbnail'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.room,
                              size: 64,
                              color: Color(0xFFE6C871),
                            ),
                          );
                        },
                      )
                      : const Center(
                        child: Icon(
                          Icons.room,
                          size: 64,
                          color: Color(0xFFE6C871),
                        ),
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Room ${room['room_number'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B5A7A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            room['is_available'] == true
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        room['is_available'] == true ? 'Available' : 'Occupied',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:
                              room['is_available'] == true
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.category, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      room['room_type'] ?? 'Standard',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Capacity: ${room['capacity'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    Text(
                      '${room['rent_per_month'] ?? 'N/A'}/month',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B5A7A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PropertyDetailPage extends StatefulWidget {
  final Map<String, dynamic> property;
  final String? initialToken;

  const PropertyDetailPage({
    super.key,
    required this.property,
    this.initialToken,
  });

  @override
  _PropertyDetailPageState createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _rooms = [];
  List<dynamic> _feedbacks = [];
  bool _isLoadingRooms = false;
  bool _isLoadingFeedbacks = false;
  String _errorMessage = '';
  final _ratingController = TextEditingController();
  final _commentController = TextEditingController();
  String? _token; // Store the token, either from storage or navigation

  @override
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _token = widget.initialToken;
    print('🏠 PropertyDetailPage - Received access_token: $_token');
    _fetchRooms();
    _fetchFeedbacks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ratingController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<String?> _loadToken() async {
    final storedToken = await _storage.read(key: 'token');
    print(
      'PropertyDetailPage _loadToken - stored token: $storedToken, using: $_token',
    );
    return _token ??
        storedToken; // Fallback to stored token if navigation token is null
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoadingRooms = true;
      _errorMessage = '';
    });

    try {
      final token = await _loadToken();
      print('PropertyDetailPage _fetchRooms - token: $token');
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/listings/rooms/property/${widget.property['id']}/',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _rooms = data;
          _isLoadingRooms = false;
        });
      } else {
        throw Exception(
          'Failed to load rooms: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading rooms: $e';
        _isLoadingRooms = false;
      });
    }
  }

  Future<void> _fetchFeedbacks() async {
    setState(() {
      _isLoadingFeedbacks = true;
      _errorMessage = '';
    });

    try {
      final token = await _loadToken();
      print('PropertyDetailPage _fetchFeedbacks - token: $token');
      if (token == null) {
        throw Exception('No authentication token available');
      }
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/listings/feedbacks/property/${widget.property['id']}/',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _feedbacks = data;
          _isLoadingFeedbacks = false;
        });
      } else {
        throw Exception(
          'Failed to load feedbacks: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading feedbacks: $e';
        _isLoadingFeedbacks = false;
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (_token == null) {
      _token = await _storage.read(
        key: 'access_token',
      ); // fallback just in case
    }
    final token = _token;
    print('📝 Submitting Feedback - Using access_token: $token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit feedback.')),
      );
      return;
    }
    final username = await _storage.read(key: 'username') ?? 'Anonymous';
    final rating = int.tryParse(_ratingController.text) ?? 0;
    final comment = _commentController.text;

    print('PropertyDetailPage _submitFeedback - token: $token');

    if (rating < 1 || rating > 5 || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a rating (1-5) and a comment.'),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/listings/feedbacks/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'property': widget.property['id'],
          'rating': rating,
          'comment': comment,
          'user_name': username,
        }),
      );

      print(
        'PropertyDetailPage _submitFeedback - Response status: ${response.statusCode}',
      );

      if (response.statusCode == 201) {
        _ratingController.clear();
        _commentController.clear();
        _fetchFeedbacks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully!')),
        );
      } else {
        throw Exception(
          'Failed to submit feedback: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting feedback: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B5A7A),
        title: Text(
          widget.property['title'] ?? 'Property Details',
          style: const TextStyle(
            color: Color(0xFFE6C871),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE6C871)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.room), text: 'Rooms'),
            Tab(icon: Icon(Icons.feedback), text: 'Feedback'),
          ],
          labelColor: const Color(0xFFE6C871),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFFE6C871),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildRoomsTab(), _buildFeedbackTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomsTab() {
    if (_isLoadingRooms) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE6C871)),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRooms,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE6C871),
                foregroundColor: const Color(0xFF3B5A7A),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.room_outlined, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No rooms available for this property',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        final room = _rooms[index];
        return _buildRoomCard(room);
      },
    );
  }

  Widget _buildFeedbackTab() {
    if (_isLoadingFeedbacks) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE6C871)),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchFeedbacks,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE6C871),
                foregroundColor: const Color(0xFF3B5A7A),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Your Feedback',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B5A7A),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ratingController,
            decoration: InputDecoration(
              labelText: 'Rating (1-5)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              labelText: 'Comment',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitFeedback,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE6C871),
              foregroundColor: const Color(0xFF3B5A7A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Submit Feedback'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                _feedbacks.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.feedback_outlined,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No feedback available for this property',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _feedbacks.length,
                      itemBuilder: (context, index) {
                        final feedback = _feedbacks[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFE6C871),
                              child: Text(
                                feedback['user_name'][0],
                                style: const TextStyle(
                                  color: Color(0xFF3B5A7A),
                                ),
                              ),
                            ),
                            title: Text(
                              feedback['user_name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3B5A7A),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: List.generate(
                                    5,
                                    (starIndex) => Icon(
                                      Icons.star,
                                      size: 16,
                                      color:
                                          starIndex < feedback['rating']
                                              ? const Color(0xFFE6C871)
                                              : Colors.grey[300],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  feedback['comment'],
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sentiment: ${feedback['sentiment']} (Score: ${feedback['sentiment_score']})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                Text(
                                  'Date: ${feedback['created_at']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
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
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B5A7A).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Container(
              height: 180,
              width: double.infinity,
              color: const Color(0xFFE6C871).withOpacity(0.3),
              child:
                  room['thumbnail'] != null && room['thumbnail'].isNotEmpty
                      ? Image.network(
                        room['thumbnail'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.room,
                              size: 64,
                              color: Color(0xFFE6C871),
                            ),
                          );
                        },
                      )
                      : const Center(
                        child: Icon(
                          Icons.room,
                          size: 64,
                          color: Color(0xFFE6C871),
                        ),
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Room ${room['room_number'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B5A7A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            room['is_available'] == true
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        room['is_available'] == true ? 'Available' : 'Occupied',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:
                              room['is_available'] == true
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.category, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      room['room_type'] ?? 'Standard',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Capacity: ${room['capacity'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    Text(
                      '${room['rent_per_month'] ?? 'N/A'}/month',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B5A7A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
