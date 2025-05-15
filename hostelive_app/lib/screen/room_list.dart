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
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update room availability: ${response.statusCode}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
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
                child: CircularProgressIndicator(color: Colors.purple),
              )
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading rooms',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _fetchRooms,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
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
                        child: Icon(
                          Icons.meeting_room,
                          color: Colors.purple,
                          size: 30,
                        ),
                      ),
                      title: Text(
                        'Room ${room['room_number'] ?? 'Unknown'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Type: ${room['room_type'] ?? 'Unknown'}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Capacity: ${room['capacity'] ?? 'Unknown'}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rent: \$${room['rent_per_month'] ?? 'Unknown'}/month',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                room['is_available'] == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 16,
                                color:
                                    room['is_available'] == true
                                        ? Colors.green
                                        : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                room['is_available'] == true
                                    ? 'Available'
                                    : 'Unavailable',
                                style: TextStyle(
                                  color:
                                      room['is_available'] == true
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          room['is_available'] == true
                              ? Icons.no_accounts
                              : Icons.check_circle_outline,
                          color:
                              room['is_available'] == true
                                  ? Colors.red
                                  : Colors.green,
                        ),
                        onPressed: () {
                          _toggleRoomAvailability(
                            room['id'],
                            room['is_available'] == true,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
