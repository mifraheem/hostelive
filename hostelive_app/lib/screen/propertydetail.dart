import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hostelive_app/constant.dart';
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
  List<Map<String, dynamic>> _feedbacks = [];
  bool _isLoading = true;
  bool _isFeedbackLoading = false;
  String? _errorMessage;
  final _storage = const FlutterSecureStorage();
  // final String _baseUrl = 'http://10.0.2.2:8000';
  final GlobalKey<RoomsListWidgetState> _roomsListKey =
      GlobalKey<RoomsListWidgetState>();
  Map<int, String> _propertyTypes = {};

  // Feedback form controllers
  final _feedbackFormKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _fetchPropertyTypes();
    _fetchPropertyDetails();
    _fetchFeedbacks();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> _fetchPropertyTypes() async {
    try {
      String? token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/api/listings/types/'),
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
        Uri.parse('$baseUrl/api/listings/properties/${widget.propertyId}/'),
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

  Future<void> _fetchFeedbacks() async {
    setState(() {
      _isFeedbackLoading = true;
    });

    try {
      String? token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/listings/feedbacks/property/${widget.propertyId}/',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _feedbacks = data.map((e) => e as Map<String, dynamic>).toList();
          _isFeedbackLoading = false;
        });
      } else {
        setState(() {
          _feedbacks = [];
          _isFeedbackLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching feedbacks: $e');
      setState(() {
        _feedbacks = [];
        _isFeedbackLoading = false;
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (!_feedbackFormKey.currentState!.validate()) return;

    try {
      String? token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/api/listings/feedbacks/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'property': widget.propertyId,
          'rating': _selectedRating,
          'comment': _commentController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        _commentController.clear();
        _selectedRating = 5;
        _fetchFeedbacks(); // Refresh feedbacks
        Navigator.pop(context); // Close the dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Feedback submitted successfully!'),
            backgroundColor: Color(0xFFE6C871),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        throw Exception('Failed to submit feedback: ${response.statusCode}');
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

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Add Feedback',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B5A7A),
                ),
              ),
              content: Form(
                key: _feedbackFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rating',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              _selectedRating = index + 1;
                            });
                          },
                          child: Icon(
                            Icons.star,
                            color:
                                index < _selectedRating
                                    ? Color(0xFFE6C871)
                                    : Colors.grey[300],
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: 'Comment (Optional)',
                        hintText: 'Share your experience...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF3B5A7A)),
                        ),
                      ),
                      maxLines: 3,
                      maxLength: 500,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE6C871),
                    foregroundColor: Color(0xFF3B5A7A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _togglePropertyStatus(bool currentStatus) async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.patch(
        Uri.parse('$baseUrl/api/listings/properties/${widget.propertyId}/'),
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
            backgroundColor: Color(0xFFE6C871),
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
            backgroundColor: Color(0xFFE6C871),
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
          backgroundColor: Color(0xFFE6C871),
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
        if (_roomsListKey.currentState != null) {
          _roomsListKey.currentState!.refreshRooms();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Updated to 3 tabs
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            _property != null
                ? _property!['title'] ?? 'Property Details'
                : 'Property Details',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: Color(0xFF3B5A7A),
          foregroundColor: Colors.white,
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFFE6C871)),
              onPressed: () {
                _fetchPropertyDetails();
                _fetchFeedbacks();
              },
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            indicatorColor: Color(0xFFE6C871),
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Rooms'),
              Tab(text: 'Feedback'),
            ],
          ),
        ),
        body:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3B5A7A),
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
                          color: Color(0xFFE6C871),
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
                          onPressed: () {
                            _fetchPropertyDetails();
                            _fetchFeedbacks();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE6C871),
                            foregroundColor: Color(0xFF3B5A7A),
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
                    _buildFeedbackTab(),
                  ],
                ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddRoom,
          backgroundColor: Color(0xFFE6C871),
          child: const Icon(Icons.add, color: Color(0xFF3B5A7A)),
          tooltip: 'Add Room',
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }

  Widget _buildFeedbackTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showFeedbackDialog,
              icon: const Icon(Icons.rate_review),
              label: const Text('Add Feedback'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE6C871),
                foregroundColor: Color(0xFF3B5A7A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child:
              _isFeedbackLoading
                  ? Center(
                    child: CircularProgressIndicator(color: Color(0xFF3B5A7A)),
                  )
                  : _feedbacks.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.feedback_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No feedback yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to leave a review!',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh: _fetchFeedbacks,
                    color: Color(0xFF3B5A7A),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _feedbacks.length,
                      itemBuilder: (context, index) {
                        final feedback = _feedbacks[index];
                        return _buildFeedbackCard(feedback);
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    final rating = feedback['rating'] ?? 0;
    final comment = feedback['comment'] ?? '';
    final userName = feedback['user_name'] ?? 'Anonymous';
    final createdAt = feedback['created_at'] ?? '';
    final sentiment = feedback['sentiment'] ?? 'neutral';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF3B5A7A),
                  radius: 20,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (createdAt.isNotEmpty)
                        Text(
                          _formatDate(createdAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      size: 18,
                      color:
                          index < rating ? Color(0xFFE6C871) : Colors.grey[300],
                    );
                  }),
                ),
              ],
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                comment,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
            if (sentiment != 'neutral') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSentimentColor(sentiment).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sentiment.toUpperCase(),
                  style: TextStyle(
                    color: _getSentimentColor(sentiment),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildDetailsTab() {
    print('Property type: ${_property!['type']}');
    print('Property type runtime type: ${_property!['type'].runtimeType}');

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
                  colors: [
                    Color(0xFF3B5A7A).withOpacity(0.7),
                    Color(0xFF3B5A7A),
                  ],
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
                        color: Color(0xFFE6C871),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _property!['is_active'] == true ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: Color(0xFFE6C871),
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
                color: Color(0xFF3B5A7A),
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
                    backgroundColor: Color(0xFF3B5A7A).withOpacity(0.1),
                    side: BorderSide(color: Color(0xFF3B5A7A).withOpacity(0.3)),
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
                color: Color(0xFFE6C871),
              ),
              label: Text(
                _property!['is_active'] == true
                    ? 'Mark Inactive'
                    : 'Mark Active',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE6C871),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFFE6C871)),
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
            Icon(icon, color: Color(0xFF3B5A7A), size: 24),
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
                      color: Color(0xFF3B5A7A),
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
