import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hostelive_app/constant.dart';
import 'package:http/http.dart' as http;

class RoomsListWidget extends StatefulWidget {
  final int propertyId;
  final String propertyName;

  const RoomsListWidget({
    super.key,
    required this.propertyId,
    required this.propertyName,
  });

  @override
  RoomsListWidgetState createState() => RoomsListWidgetState();
}

class RoomsListWidgetState extends State<RoomsListWidget> {
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = true;
  String? _errorMessage;
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = '$baseUrl';

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> refreshRooms() async {
    await _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/api/listings/rooms/?property=${widget.propertyId}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _rooms = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _errorMessage = 'Failed to load rooms: ${response.statusCode}';
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

  Future<void> _toggleRoomAvailability(
    int roomId,
    bool currentAvailability,
  ) async {
    try {
      String? token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.patch(
        Uri.parse('$_baseUrl/api/listings/rooms/$roomId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'is_available': !currentAvailability}),
      );

      if (response.statusCode == 200) {
        await _fetchRooms();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Room availability updated'),
            backgroundColor: const Color(0xFFE6C871),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update room availability: ${response.statusCode}',
            ),
            backgroundColor: const Color(0xFFE6C871),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: const Color(0xFFE6C871),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchRooms,
      child:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B5A7A)),
              )
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: const Color(0xFFE6C871),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading rooms',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3B5A7A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: const Color(0xFF3B5A7A)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _fetchRooms,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6C871),
                        foregroundColor: const Color(0xFF3B5A7A),
                      ),
                    ),
                  ],
                ),
              )
              : _rooms.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.meeting_room, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No rooms found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add a room',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  final room = _rooms[index];
                  return TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, opacity, child) {
                      return Opacity(opacity: opacity, child: child);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        onTap: () {
                          // TODO: Navigate to room details (if needed)
                        },
                        borderRadius: BorderRadius.circular(15),
                        splashColor: const Color(0xFFE6C871).withOpacity(0.2),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: const Color(0xFFE6C871).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Thumbnail
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFE6C871,
                                          ).withOpacity(0.3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF3B5A7A,
                                              ).withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child:
                                            room['thumbnail'] != null &&
                                                    room['thumbnail'].isNotEmpty
                                                ? Image.network(
                                                  room['thumbnail'],
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Center(
                                                      child: Icon(
                                                        Icons.meeting_room,
                                                        size: 30,
                                                        color: Color(
                                                          0xFF3B5A7A,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                                : const Center(
                                                  child: Icon(
                                                    Icons.meeting_room,
                                                    size: 30,
                                                    color: Color(0xFF3B5A7A),
                                                  ),
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Room ${room['room_number'] ?? 'Unknown'}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 20,
                                              color: Color(0xFF3B5A7A),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Type: ${room['room_type'] ?? 'Unknown'}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Capacity: ${room['capacity'] ?? 'Unknown'}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Rent: \$${room['rent_per_month'] ?? 'Unknown'}/month',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Status Badge
                              Positioned(
                                top: 10,
                                right: 20,
                                child: Container(
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
                                    border: Border.all(
                                      color: const Color(
                                        0xFFE6C871,
                                      ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    room['is_available'] == true
                                        ? 'Available'
                                        : 'Unavailable',
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
                              ),
                              // Toggle Button
                              Positioned(
                                top: 0,
                                bottom: 0,
                                right: 20,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(
                                        0xFFE6C871,
                                      ).withOpacity(0.1),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        room['is_available'] == true
                                            ? Icons.no_accounts
                                            : Icons.check_circle_outline,
                                        size: 20,
                                        color: const Color(0xFFE6C871),
                                      ),
                                      onPressed: () {
                                        _toggleRoomAvailability(
                                          room['id'],
                                          room['is_available'] == true,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
