import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hostelive_app/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class RoomDetailPage extends StatelessWidget {
  final Map<String, dynamic> room;
  final String? initialToken;

  const RoomDetailPage({super.key, required this.room, this.initialToken});

  @override
  Widget build(BuildContext context) {
    final images = room['images_detail'] as List<dynamic>? ?? [];
    final pageController = PageController();
    int currentPage = 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A365D),
        title: Text(
          'Room ${room['room_number'] ?? 'N/A'}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Carousel
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      images.isNotEmpty
                          ? StatefulBuilder(
                            builder: (context, setState) {
                              return PageView.builder(
                                controller: pageController,
                                itemCount: images.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    currentPage = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final image = images[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Image.network(
                                      image['image'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Center(
                                          child: Icon(
                                            Icons.room,
                                            size: 64,
                                            color: Color(0xFF1A365D),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          )
                          : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.room,
                                size: 64,
                                color: Color(0xFF1A365D),
                              ),
                            ),
                          ),
                      if (images.isNotEmpty)
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      currentPage == index
                                          ? const Color(0xFF1A365D)
                                          : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Room Details Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Room Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailItem(
                        icon: Icons.home_work,
                        label: 'Property',
                        value: room['property_title'] ?? 'N/A',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        icon: Icons.room,
                        label: 'Room Number',
                        value: room['room_number'] ?? 'N/A',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        icon: Icons.category,
                        label: 'Room Type',
                        value:
                            room['room_type']?.toUpperCase().substring(0, 1) +
                                room['room_type']?.substring(1) ??
                            'Standard',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        icon: Icons.people,
                        label: 'Capacity',
                        value: room['capacity']?.toString() ?? 'N/A',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        icon: Icons.attach_money,
                        label: 'Rent per Month',
                        value: '${room['rent_per_month'] ?? 'N/A'}/month',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        icon: Icons.check_circle,
                        label: 'Availability',
                        value:
                            room['is_available'] == true
                                ? 'Available'
                                : 'Occupied',
                        valueColor:
                            room['is_available'] == true
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        icon: Icons.calendar_today,
                        label: 'Created At',
                        value: room['created_at'] ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Facilities Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Facilities',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                      const SizedBox(height: 16),
                      (room['facilities_detail'] as List<dynamic>?)?.isEmpty ??
                              true
                          ? Text(
                            'No facilities available',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          )
                          : Column(
                            children:
                                (room['facilities_detail'] as List<dynamic>)
                                    .map(
                                      (facility) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              facility['name'] ?? 'Facility',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF1A365D), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: valueColor ?? const Color(0xFF1A365D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Map<String, dynamic> _userData = {};
  bool _isLoadingUserData = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<String?> _loadToken() async {
    final token = await _storage.read(key: 'access_token');
    print('📦 ProfilePage - Using access_token: $token');
    return token;
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoadingUserData = true;
      _errorMessage = '';
    });

    try {
      final token = await _loadToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _userData = data;
          _isLoadingUserData = false;
        });
        print('✅ User profile loaded: ${data['username']}');
      } else {
        throw Exception(
          'Failed to load user profile: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading user profile: $e';
        _isLoadingUserData = false;
      });
      print('❌ Error loading user profile: $e');
    }
  }

  Future<void> _updateUserProfile(String username, String email) async {
    setState(() {
      _isLoadingUserData = true;
      _errorMessage = '';
    });

    try {
      final token = await _loadToken();
      if (token == null) {
        throw Exception('No access token available');
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/api/auth/me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'username': username, 'email': email}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        await _storage.write(key: 'username', value: username);
        setState(() {
          _userData = data;
          _isLoadingUserData = false;
        });
        print('✅ User profile updated: ${data['username']}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF1A365D),
          ),
        );
      } else {
        throw Exception(
          'Failed to update profile: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating profile: $e';
        _isLoadingUserData = false;
      });
      print('❌ Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _showEditProfileDialog() {
    final usernameController = TextEditingController(
      text: _userData['username'] ?? '',
    );
    final emailController = TextEditingController(
      text: _userData['email'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _updateUserProfile(
                          usernameController.text,
                          emailController.text,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A365D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A365D),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body:
          _isLoadingUserData
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A365D)),
                ),
              )
              : _errorMessage.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchUserProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A365D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _userData.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off_outlined,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No user data available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(
                          0xFF1A365D,
                        ).withOpacity(0.2),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Profile Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A365D),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildProfileItem(
                              icon: Icons.person,
                              label: 'Username',
                              value: _userData['username'] ?? 'N/A',
                            ),
                            const SizedBox(height: 12),
                            _buildProfileItem(
                              icon: Icons.email,
                              label: 'Email',
                              value: _userData['email'] ?? 'N/A',
                            ),
                            const SizedBox(height: 12),
                            _buildProfileItem(
                              icon: Icons.admin_panel_settings,
                              label: 'Role',
                              value:
                                  _userData['role']?.toUpperCase().substring(
                                        0,
                                        1,
                                      ) +
                                      _userData['role']?.substring(1) ??
                                  'N/A',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF1A365D), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A365D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
