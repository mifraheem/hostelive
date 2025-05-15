import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hostelive_app/constant.dart';
import 'package:http/http.dart' as http;

class AddRoomPage extends StatefulWidget {
  final int propertyId;
  final String propertyName;

  const AddRoomPage({
    super.key,
    required this.propertyId,
    required this.propertyName,
  });

  @override
  _AddRoomPageState createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberController = TextEditingController();
  final _roomTypeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _rentController = TextEditingController();
  final _newFacilityController = TextEditingController();

  bool _isAvailable = true;
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _facilityOptions = [];
  List<int> _selectedFacilityIds = [];

  final _storage = const FlutterSecureStorage();
  final String _baseUrl = '$baseUrl';

  @override
  void initState() {
    super.initState();
    _fetchRoomFacilities();
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> _fetchRoomFacilities() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Not authenticated. Please log in.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/listings/room-facilities/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _facilityOptions = List<Map<String, dynamic>>.from(
            data.map(
              (x) => {'id': x['id'], 'name': x['name'], 'selected': false},
            ),
          );
        });
      } else if (response.statusCode == 401) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _errorMessage =
              'Failed to fetch room facilities: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch room facilities: ${e.toString()}';
      });
    }
  }

  Future<void> _addNewFacility() async {
    if (_newFacilityController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a facility name.';
      });
      return;
    }

    try {
      String? token = await _getToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Not authenticated. Please log in.';
        });
        return;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/listings/room-facilities/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': _newFacilityController.text}),
      );
      if (response.statusCode == 201) {
        final Map<String, dynamic> newFacility = jsonDecode(response.body);
        _newFacilityController.clear();

        // Add the new facility to the list and select it
        setState(() {
          _facilityOptions.add({
            'id': newFacility['id'],
            'name': newFacility['name'],
            'selected': true,
          });
          _selectedFacilityIds.add(newFacility['id']);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Facility added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.statusCode == 401) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _errorMessage = 'Failed to add facility: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
      });
    }
  }

  Future<void> _saveRoom() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/listings/rooms/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'property': widget.propertyId,
          'room_number': _roomNumberController.text,
          'room_type': _roomTypeController.text,
          'capacity': int.parse(_capacityController.text),
          'rent_per_month': double.parse(_rentController.text),
          'is_available': _isAvailable,
          'facilities': _selectedFacilityIds,
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _errorMessage = 'Please fix the following errors:';
          for (var entry in responseData.entries) {
            if (entry.value is List) {
              _errorMessage =
                  '$_errorMessage\n• ${entry.key}: ${entry.value.join(', ')}';
            } else {
              _errorMessage = '$_errorMessage\n• ${entry.key}: ${entry.value}';
            }
          }
        });
      } else if (response.statusCode == 401) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _errorMessage = 'Failed to add room. Please try again later.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFacilitiesDropdown() async {
    final List<int> tempSelectedIds = List.from(_selectedFacilityIds);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Facilities',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedFacilityIds = tempSelectedIds;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Selected: ${_facilityOptions.where((f) => tempSelectedIds.contains(f['id'])).map((f) => f['name']).join(", ")}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _facilityOptions.length,
                      itemBuilder: (context, index) {
                        final facility = _facilityOptions[index];
                        final isSelected = tempSelectedIds.contains(
                          facility['id'],
                        );

                        return CheckboxListTile(
                          title: Text(facility['name']),
                          value: isSelected,
                          activeColor: Colors.purple,
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                tempSelectedIds.add(facility['id']);
                              } else {
                                tempSelectedIds.remove(facility['id']);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // Update the main state after modal is closed
    setState(() {
      _selectedFacilityIds = tempSelectedIds;
    });
  }

  String getSelectedFacilitiesText() {
    if (_selectedFacilityIds.isEmpty) {
      return 'No facilities selected';
    }

    List<String> names =
        _facilityOptions
            .where((facility) => _selectedFacilityIds.contains(facility['id']))
            .map((facility) => facility['name'] as String)
            .toList();

    if (names.length <= 2) {
      return names.join(', ');
    } else {
      return '${names.length} facilities selected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Room'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade300, Colors.purple.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adding Room To',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.propertyName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Property ID: ${widget.propertyId}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Room Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Room Number
                TextFormField(
                  controller: _roomNumberController,
                  decoration: InputDecoration(
                    labelText: 'Room Number',
                    hintText: 'e.g. A101, B202',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.purple.withOpacity(0.1),
                    filled: true,
                    prefixIcon: const Icon(Icons.meeting_room),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a room number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Room Type
                TextFormField(
                  controller: _roomTypeController,
                  decoration: InputDecoration(
                    labelText: 'Room Type',
                    hintText: 'e.g. Single, Double, Deluxe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.purple.withOpacity(0.1),
                    filled: true,
                    prefixIcon: const Icon(Icons.category),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a room type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Capacity
                TextFormField(
                  controller: _capacityController,
                  decoration: InputDecoration(
                    labelText: 'Capacity',
                    hintText: 'Number of people',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.purple.withOpacity(0.1),
                    filled: true,
                    prefixIcon: const Icon(Icons.people),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the capacity';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Rent per month
                TextFormField(
                  controller: _rentController,
                  decoration: InputDecoration(
                    labelText: 'Rent per Month',
                    hintText: 'Enter rent amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.purple.withOpacity(0.1),
                    filled: true,
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the rent amount';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Facilities Dropdown
                const Text(
                  'Room Facilities',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _showFacilitiesDropdown,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.home_repair_service_outlined,
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            getSelectedFacilitiesText(),
                            style: TextStyle(
                              color:
                                  _selectedFacilityIds.isEmpty
                                      ? Colors.grey[600]
                                      : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.purple),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Add New Facility
                const Text(
                  'Add New Facility',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _newFacilityController,
                        decoration: InputDecoration(
                          labelText: 'New Facility',
                          hintText: 'Enter new facility',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Colors.purple.withOpacity(0.1),
                          filled: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addNewFacility,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Availability Switch
                SwitchListTile(
                  title: const Text('Room Status'),
                  subtitle: Text(_isAvailable ? 'Available' : 'Not Available'),
                  value: _isAvailable,
                  activeColor: Colors.purple,
                  onChanged: (bool value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                ),

                // Error message display
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveRoom,
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.purple,
                      disabledBackgroundColor: Colors.purple.withOpacity(0.5),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              "Save Room",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
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
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _roomTypeController.dispose();
    _capacityController.dispose();
    _rentController.dispose();
    _newFacilityController.dispose();
    super.dispose();
  }
}
