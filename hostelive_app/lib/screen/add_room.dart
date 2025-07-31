// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // import 'package:hostelive_app/constant.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:image_picker/image_picker.dart';

// // class AddRoomPage extends StatefulWidget {
// //   final int propertyId;
// //   final String propertyName;

// //   const AddRoomPage({
// //     super.key,
// //     required this.propertyId,
// //     required this.propertyName,
// //   });

// //   @override
// //   _AddRoomPageState createState() => _AddRoomPageState();
// // }

// // class _AddRoomPageState extends State<AddRoomPage> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _roomNumberController = TextEditingController();
// //   final _roomTypeController = TextEditingController();
// //   final _capacityController = TextEditingController();
// //   final _rentController = TextEditingController();
// //   final _newFacilityController = TextEditingController();

// //   bool _isAvailable = true;
// //   bool _isLoading = false;
// //   String? _errorMessage;
// //   File? _selectedImage;

// //   List<Map<String, dynamic>> _facilityOptions = [];
// //   List<int> _selectedFacilityIds = [];

// //   final _storage = const FlutterSecureStorage();
// //   final String _baseUrl = '$baseUrl';
// //   final ImagePicker _picker = ImagePicker();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchRoomFacilities();
// //   }

// //   Future<String?> _getToken() async {
// //     return await _storage.read(key: 'access_token');
// //   }

// //   Future<void> _pickImageFromGallery() async {
// //     try {
// //       final XFile? image = await _picker.pickImage(
// //         source: ImageSource.gallery,
// //         maxWidth: 1024,
// //         maxHeight: 1024,
// //         imageQuality: 85,
// //       );

// //       if (image != null) {
// //         setState(() {
// //           _selectedImage = File(image.path);
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _errorMessage = 'Failed to pick image: ${e.toString()}';
// //       });
// //     }
// //   }

// //   void _removeSelectedImage() {
// //     setState(() {
// //       _selectedImage = null;
// //     });
// //   }

// //   Future<void> _fetchRoomFacilities() async {
// //     try {
// //       String? token = await _getToken();
// //       if (token == null) {
// //         setState(() {
// //           _errorMessage = 'Not authenticated. Please log in.';
// //         });
// //         return;
// //       }

// //       final response = await http.get(
// //         Uri.parse('$_baseUrl/api/listings/room-facilities/'),
// //         headers: {
// //           'Authorization': 'Bearer $token',
// //           'Content-Type': 'application/json',
// //         },
// //       );
// //       if (response.statusCode == 200) {
// //         final List<dynamic> data = jsonDecode(response.body);
// //         setState(() {
// //           _facilityOptions = List<Map<String, dynamic>>.from(
// //             data.map(
// //               (x) => {'id': x['id'], 'name': x['name'], 'selected': false},
// //             ),
// //           );
// //         });
// //       } else if (response.statusCode == 401) {
// //         Navigator.pushReplacementNamed(context, '/login');
// //       } else {
// //         setState(() {
// //           _errorMessage =
// //               'Failed to fetch room facilities: ${response.statusCode}';
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _errorMessage = 'Failed to fetch room facilities: ${e.toString()}';
// //       });
// //     }
// //   }

// //   Future<void> _addNewFacility() async {
// //     if (_newFacilityController.text.isEmpty) {
// //       setState(() {
// //         _errorMessage = 'Please enter a facility name.';
// //       });
// //       return;
// //     }

// //     try {
// //       String? token = await _getToken();
// //       if (token == null) {
// //         setState(() {
// //           _errorMessage = 'Not authenticated. Please log in.';
// //         });
// //         return;
// //       }

// //       final response = await http.post(
// //         Uri.parse('$_baseUrl/api/listings/room-facilities/'),
// //         headers: {
// //           'Authorization': 'Bearer $token',
// //           'Content-Type': 'application/json',
// //         },
// //         body: jsonEncode({'name': _newFacilityController.text}),
// //       );
// //       if (response.statusCode == 201) {
// //         final Map<String, dynamic> newFacility = jsonDecode(response.body);
// //         _newFacilityController.clear();

// //         // Add the new facility to the list and select it
// //         setState(() {
// //           _facilityOptions.add({
// //             'id': newFacility['id'],
// //             'name': newFacility['name'],
// //             'selected': true,
// //           });
// //           _selectedFacilityIds.add(newFacility['id']);
// //         });

// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('Facility added successfully!'),
// //             backgroundColor: Color(0xFFE6C871),
// //           ),
// //         );
// //       } else if (response.statusCode == 401) {
// //         Navigator.pushReplacementNamed(context, '/login');
// //       } else {
// //         setState(() {
// //           _errorMessage = 'Failed to add facility: ${response.statusCode}';
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _errorMessage = 'Network error: ${e.toString()}';
// //       });
// //     }
// //   }

// //   Future<void> _saveRoom() async {
// //     if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
// //       return;
// //     }

// //     setState(() {
// //       _isLoading = true;
// //       _errorMessage = null;
// //     });

// //     try {
// //       String? token = await _getToken();
// //       if (token == null) {
// //         throw Exception('Not authenticated');
// //       }

// //       var request = http.MultipartRequest(
// //         'POST',
// //         Uri.parse('$_baseUrl/api/listings/rooms/'),
// //       );

// //       request.headers['Authorization'] = 'Bearer $token';

// //       request.fields['property'] = widget.propertyId.toString();
// //       request.fields['room_number'] = _roomNumberController.text;
// //       request.fields['room_type'] = _roomTypeController.text;
// //       request.fields['capacity'] = _capacityController.text;
// //       request.fields['rent_per_month'] = _rentController.text;
// //       request.fields['is_available'] = _isAvailable.toString();

// //       for (int i = 0; i < _selectedFacilityIds.length; i++) {
// //         request.fields['facilities[$i]'] = _selectedFacilityIds[i].toString();
// //       }

// //       if (_selectedImage != null) {
// //         String fileName = _selectedImage!.path.split('/').last;
// //         var multipartFile = await http.MultipartFile.fromPath(
// //           'thumbnail',
// //           _selectedImage!.path,
// //           filename: fileName,
// //         );
// //         request.files.add(multipartFile);
// //       }

// //       var streamedResponse = await request.send();
// //       var response = await http.Response.fromStream(streamedResponse);

// //       if (response.statusCode == 201) {
// //         if (!mounted) return;
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('Room added successfully!'),
// //             backgroundColor: Color(0xFFE6C871),
// //           ),
// //         );
// //         Navigator.pop(context);
// //       } else if (response.statusCode == 400) {
// //         final Map<String, dynamic> responseData = jsonDecode(response.body);
// //         setState(() {
// //           _errorMessage = 'Please fix the following errors:';
// //           for (var entry in responseData.entries) {
// //             if (entry.value is List) {
// //               _errorMessage =
// //                   '$_errorMessage\n• ${entry.key}: ${entry.value.join(', ')}';
// //             } else {
// //               _errorMessage = '$_errorMessage\n• ${entry.key}: ${entry.value}';
// //             }
// //           }
// //         });
// //       } else if (response.statusCode == 401) {
// //         if (!mounted) return;
// //         Navigator.pushReplacementNamed(context, '/login');
// //       } else {
// //         setState(() {
// //           _errorMessage = 'Failed to add room. Please try again later.';
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _errorMessage = 'Network error: ${e.toString()}';
// //       });
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   void _showFacilitiesDropdown() async {
// //     final List<int> tempSelectedIds = List.from(_selectedFacilityIds);

// //     await showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (context) {
// //         return StatefulBuilder(
// //           builder: (BuildContext context, StateSetter setModalState) {
// //             return Container(
// //               padding: const EdgeInsets.all(20),
// //               height: MediaQuery.of(context).size.height * 0.7,
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Text(
// //                         'Select Facilities',
// //                         style: TextStyle(
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.bold,
// //                           color: Color(0xFF3B5A7A),
// //                         ),
// //                       ),
// //                       TextButton(
// //                         onPressed: () {
// //                           setState(() {
// //                             _selectedFacilityIds = tempSelectedIds;
// //                           });
// //                           Navigator.pop(context);
// //                         },
// //                         child: Text(
// //                           'Done',
// //                           style: TextStyle(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                             color: Color(0xFFE6C871),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 10),
// //                   Text(
// //                     'Selected: ${_facilityOptions.where((f) => tempSelectedIds.contains(f['id'])).map((f) => f['name']).join(", ")}',
// //                     style: TextStyle(fontSize: 14, color: Colors.grey[600]),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   Divider(),
// //                   Expanded(
// //                     child: ListView.builder(
// //                       itemCount: _facilityOptions.length,
// //                       itemBuilder: (context, index) {
// //                         final facility = _facilityOptions[index];
// //                         final isSelected = tempSelectedIds.contains(
// //                           facility['id'],
// //                         );

// //                         return CheckboxListTile(
// //                           title: Text(facility['name']),
// //                           value: isSelected,
// //                           activeColor: Color(0xFFE6C871),
// //                           onChanged: (bool? value) {
// //                             setModalState(() {
// //                               if (value == true) {
// //                                 tempSelectedIds.add(facility['id']);
// //                               } else {
// //                                 tempSelectedIds.remove(facility['id']);
// //                               }
// //                             });
// //                           },
// //                         );
// //                       },
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );

// //     setState(() {
// //       _selectedFacilityIds = tempSelectedIds;
// //     });
// //   }

// //   String getSelectedFacilitiesText() {
// //     if (_selectedFacilityIds.isEmpty) {
// //       return 'No facilities selected';
// //     }

// //     List<String> names =
// //         _facilityOptions
// //             .where((facility) => _selectedFacilityIds.contains(facility['id']))
// //             .map((facility) => facility['name'] as String)
// //             .toList();

// //     if (names.length <= 2) {
// //       return names.join(', ');
// //     } else {
// //       return '${names.length} facilities selected';
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Add Room'),
// //         backgroundColor: Color(0xFF3B5A7A),
// //       ),
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Form(
// //             key: _formKey,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // Property info card
// //                 Container(
// //                   width: double.infinity,
// //                   padding: const EdgeInsets.all(16),
// //                   decoration: BoxDecoration(
// //                     gradient: LinearGradient(
// //                       colors: [
// //                         Color(0xFF3B5A7A).withOpacity(0.7),
// //                         Color(0xFF3B5A7A),
// //                       ],
// //                       begin: Alignment.topLeft,
// //                       end: Alignment.bottomRight,
// //                     ),
// //                     borderRadius: BorderRadius.circular(16),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Color(0xFF3B5A7A).withOpacity(0.3),
// //                         blurRadius: 10,
// //                         offset: const Offset(0, 4),
// //                       ),
// //                     ],
// //                   ),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       const Text(
// //                         'Adding Room To',
// //                         style: TextStyle(color: Colors.white70, fontSize: 14),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text(
// //                         widget.propertyName,
// //                         style: const TextStyle(
// //                           color: Colors.white,
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text(
// //                         'Property ID: ${widget.propertyId}',
// //                         style: const TextStyle(
// //                           color: Colors.white70,
// //                           fontSize: 12,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 24),

// //                 const Text(
// //                   'Room Details',
// //                   style: TextStyle(
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.bold,
// //                     color: Color(0xFF3B5A7A),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 20),

// //                 // Room Image Section
// //                 const Text(
// //                   'Room Image',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 16,
// //                     color: Color(0xFF3B5A7A),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Container(
// //                   width: double.infinity,
// //                   height: 200,
// //                   decoration: BoxDecoration(
// //                     color: Color(0xFF3B5A7A).withOpacity(0.1),
// //                     borderRadius: BorderRadius.circular(18),
// //                     border: Border.all(
// //                       color: Color(0xFF3B5A7A).withOpacity(0.3),
// //                       width: 2,
// //                       style: BorderStyle.solid,
// //                     ),
// //                   ),
// //                   child:
// //                       _selectedImage != null
// //                           ? Stack(
// //                             children: [
// //                               ClipRRect(
// //                                 borderRadius: BorderRadius.circular(16),
// //                                 child: Image.file(
// //                                   _selectedImage!,
// //                                   width: double.infinity,
// //                                   height: double.infinity,
// //                                   fit: BoxFit.cover,
// //                                 ),
// //                               ),
// //                               Positioned(
// //                                 top: 8,
// //                                 right: 8,
// //                                 child: GestureDetector(
// //                                   onTap: _removeSelectedImage,
// //                                   child: Container(
// //                                     padding: const EdgeInsets.all(4),
// //                                     decoration: const BoxDecoration(
// //                                       color: Color(0xFFE6C871),
// //                                       shape: BoxShape.circle,
// //                                     ),
// //                                     child: const Icon(
// //                                       Icons.close,
// //                                       color: Color(0xFF3B5A7A),
// //                                       size: 20,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           )
// //                           : InkWell(
// //                             onTap: _pickImageFromGallery,
// //                             child: const Column(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Icon(
// //                                   Icons.add_photo_alternate,
// //                                   size: 50,
// //                                   color: Color(0xFF3B5A7A),
// //                                 ),
// //                                 SizedBox(height: 8),
// //                                 Text(
// //                                   'Tap to select room image from gallery',
// //                                   style: TextStyle(
// //                                     color: Color(0xFF3B5A7A),
// //                                     fontSize: 16,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                 ),
// //                 const SizedBox(height: 20),

// //                 // Room Number
// //                 TextFormField(
// //                   controller: _roomNumberController,
// //                   decoration: InputDecoration(
// //                     labelText: 'Room Number',
// //                     hintText: 'e.g. A101, B202',
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(18),
// //                       borderSide: BorderSide.none,
// //                     ),
// //                     fillColor: Color(0xFF3B5A7A).withOpacity(0.1),
// //                     filled: true,
// //                     prefixIcon: const Icon(
// //                       Icons.meeting_room,
// //                       color: Color(0xFF3B5A7A),
// //                     ),
// //                   ),
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Please enter a room number';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // Room Type
// //                 TextFormField(
// //                   controller: _roomTypeController,
// //                   decoration: InputDecoration(
// //                     labelText: 'Room Type',
// //                     hintText: 'e.g. Single, Double, Deluxe',
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(18),
// //                       borderSide: BorderSide.none,
// //                     ),
// //                     fillColor: Color(0xFF3B5A7A).withOpacity(0.1),
// //                     filled: true,
// //                     prefixIcon: const Icon(
// //                       Icons.category,
// //                       color: Color(0xFF3B5A7A),
// //                     ),
// //                   ),
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Please enter a room type';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // Capacity
// //                 TextFormField(
// //                   controller: _capacityController,
// //                   decoration: InputDecoration(
// //                     labelText: 'Capacity',
// //                     hintText: 'Number of people',
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(18),
// //                       borderSide: BorderSide.none,
// //                     ),
// //                     fillColor: Color(0xFF3B5A7A).withOpacity(0.1),
// //                     filled: true,
// //                     prefixIcon: const Icon(
// //                       Icons.people,
// //                       color: Color(0xFF3B5A7A),
// //                     ),
// //                   ),
// //                   keyboardType: TextInputType.number,
// //                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Please enter the capacity';
// //                     }
// //                     if (int.tryParse(value) == null || int.parse(value) <= 0) {
// //                       return 'Please enter a valid number';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // Rent per month
// //                 TextFormField(
// //                   controller: _rentController,
// //                   decoration: InputDecoration(
// //                     labelText: 'Rent per Month',
// //                     hintText: 'Enter rent amount',
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(18),
// //                       borderSide: BorderSide.none,
// //                     ),
// //                     fillColor: Color(0xFF3B5A7A).withOpacity(0.1),
// //                     filled: true,
// //                     prefixIcon: const Icon(
// //                       Icons.attach_money,
// //                       color: Color(0xFF3B5A7A),
// //                     ),
// //                   ),
// //                   keyboardType: const TextInputType.numberWithOptions(
// //                     decimal: true,
// //                   ),
// //                   inputFormatters: [
// //                     FilteringTextInputFormatter.allow(
// //                       RegExp(r'^\d+\.?\d{0,2}'),
// //                     ),
// //                   ],
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Please enter the rent amount';
// //                     }
// //                     if (double.tryParse(value) == null ||
// //                         double.parse(value) <= 0) {
// //                       return 'Please enter a valid amount';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 24),

// //                 // Facilities Dropdown
// //                 const Text(
// //                   'Room Facilities',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 16,
// //                     color: Color(0xFF3B5A7A),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 InkWell(
// //                   onTap: _showFacilitiesDropdown,
// //                   child: Container(
// //                     padding: const EdgeInsets.all(16),
// //                     decoration: BoxDecoration(
// //                       color: Color(0xFF3B5A7A).withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(18),
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         const Icon(
// //                           Icons.home_repair_service_outlined,
// //                           color: Color(0xFF3B5A7A),
// //                         ),
// //                         const SizedBox(width: 12),
// //                         Expanded(
// //                           child: Text(
// //                             getSelectedFacilitiesText(),
// //                             style: TextStyle(
// //                               color:
// //                                   _selectedFacilityIds.isEmpty
// //                                       ? Colors.grey[600]
// //                                       : Colors.black87,
// //                               fontSize: 16,
// //                             ),
// //                           ),
// //                         ),
// //                         const Icon(
// //                           Icons.arrow_drop_down,
// //                           color: Color(0xFF3B5A7A),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // Add New Facility
// //                 const Text(
// //                   'Add New Facility',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 16,
// //                     color: Color(0xFF3B5A7A),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: TextFormField(
// //                         controller: _newFacilityController,
// //                         decoration: InputDecoration(
// //                           labelText: 'New Facility',
// //                           hintText: 'Enter new facility',
// //                           border: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(18),
// //                             borderSide: BorderSide.none,
// //                           ),
// //                           fillColor: Color(0xFF3B5A7A).withOpacity(0.1),
// //                           filled: true,
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     ElevatedButton(
// //                       onPressed: _addNewFacility,
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Color(0xFFE6C871),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(18),
// //                         ),
// //                         padding: const EdgeInsets.symmetric(vertical: 14),
// //                       ),
// //                       child: const Text(
// //                         'Add',
// //                         style: TextStyle(color: Color(0xFF3B5A7A)),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // Availability Switch
// //                 SwitchListTile(
// //                   title: const Text(
// //                     'Room Status',
// //                     style: TextStyle(color: Color(0xFF3B5A7A)),
// //                   ),
// //                   subtitle: Text(
// //                     _isAvailable ? 'Available' : 'Not Available',
// //                     style: TextStyle(color: Color(0xFF3B5A7A)),
// //                   ),
// //                   value: _isAvailable,
// //                   activeColor: Color(0xFFE6C871),
// //                   onChanged: (bool value) {
// //                     setState(() {
// //                       _isAvailable = value;
// //                     });
// //                   },
// //                 ),

// //                 // Error message display
// //                 if (_errorMessage != null)
// //                   Container(
// //                     margin: const EdgeInsets.only(top: 16),
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Color(0xFFE6C871).withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(8),
// //                       border: Border.all(
// //                         color: Color(0xFFE6C871).withOpacity(0.3),
// //                       ),
// //                     ),
// //                     child: Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Icon(Icons.error_outline, color: Color(0xFFE6C871)),
// //                         const SizedBox(width: 12),
// //                         Expanded(
// //                           child: Text(
// //                             _errorMessage!,
// //                             style: TextStyle(color: Color(0xFFE6C871)),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),

// //                 const SizedBox(height: 24),

// //                 // Save button
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: ElevatedButton(
// //                     onPressed: _isLoading ? null : _saveRoom,
// //                     style: ElevatedButton.styleFrom(
// //                       shape: const StadiumBorder(),
// //                       padding: const EdgeInsets.symmetric(vertical: 16),
// //                       backgroundColor: Color(0xFFE6C871),
// //                       disabledBackgroundColor: Color(
// //                         0xFFE6C871,
// //                       ).withOpacity(0.5),
// //                     ),
// //                     child:
// //                         _isLoading
// //                             ? const SizedBox(
// //                               height: 20,
// //                               width: 20,
// //                               child: CircularProgressIndicator(
// //                                 color: Color(0xFF3B5A7A),
// //                                 strokeWidth: 2,
// //                               ),
// //                             )
// //                             : const Text(
// //                               "Save Room",
// //                               style: TextStyle(
// //                                 fontSize: 18,
// //                                 color: Color(0xFF3B5A7A),
// //                               ),
// //                             ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _roomNumberController.dispose();
// //     _roomTypeController.dispose();
// //     _capacityController.dispose();
// //     _rentController.dispose();
// //     _newFacilityController.dispose();
// //     super.dispose();
// //   }
// // }
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:hostelive_app/constant.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// class AddRoomPage extends StatefulWidget {
//   final int propertyId;
//   final String propertyName;

//   const AddRoomPage({
//     super.key,
//     required this.propertyId,
//     required this.propertyName,
//   });

//   @override
//   _AddRoomPageState createState() => _AddRoomPageState();
// }

// class _AddRoomPageState extends State<AddRoomPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _roomNumberController = TextEditingController();
//   final _roomTypeController = TextEditingController();
//   final _capacityController = TextEditingController();
//   final _rentController = TextEditingController();
//   final _newFacilityController = TextEditingController();

//   bool _isAvailable = true;
//   bool _isLoading = false;
//   String? _errorMessage;
//   File? _selectedImage;

//   List<Map<String, dynamic>> _facilityOptions = [];
//   List<int> _selectedFacilityIds = [];

//   final _storage = const FlutterSecureStorage();
//   final String _baseUrl = '$baseUrl';
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _fetchRoomFacilities();
//   }

//   Future<String?> _getToken() async {
//     return await _storage.read(key: 'access_token');
//   }

//   Future<void> _pickImageFromGallery() async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );

//       if (image != null) {
//         setState(() {
//           _selectedImage = File(image.path);
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to pick image: ${e.toString()}';
//       });
//     }
//   }

//   void _removeSelectedImage() {
//     setState(() {
//       _selectedImage = null;
//     });
//   }

//   Future<void> _fetchRoomFacilities() async {
//     try {
//       String? token = await _getToken();
//       if (token == null) {
//         setState(() {
//           _errorMessage = 'Not authenticated. Please log in.';
//         });
//         return;
//       }

//       final response = await http.get(
//         Uri.parse('$_baseUrl/api/listings/room-facilities/'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           _facilityOptions = List<Map<String, dynamic>>.from(
//             data.map(
//               (x) => {'id': x['id'], 'name': x['name'], 'selected': false},
//             ),
//           );
//         });
//       } else if (response.statusCode == 401) {
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         setState(() {
//           _errorMessage =
//               'Failed to fetch room facilities: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to fetch room facilities: ${e.toString()}';
//       });
//     }
//   }

//   Future<void> _addNewFacility() async {
//     if (_newFacilityController.text.isEmpty) {
//       setState(() {
//         _errorMessage = 'Please enter a facility name.';
//       });
//       return;
//     }

//     try {
//       String? token = await _getToken();
//       if (token == null) {
//         setState(() {
//           _errorMessage = 'Not authenticated. Please log in.';
//         });
//         return;
//       }

//       final response = await http.post(
//         Uri.parse('$_baseUrl/api/listings/room-facilities/'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'name': _newFacilityController.text}),
//       );
//       if (response.statusCode == 201) {
//         final Map<String, dynamic> newFacility = jsonDecode(response.body);
//         _newFacilityController.clear();

//         // Add the new facility to the list and select it
//         setState(() {
//           _facilityOptions.add({
//             'id': newFacility['id'],
//             'name': newFacility['name'],
//             'selected': true,
//           });
//           _selectedFacilityIds.add(newFacility['id']);
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Facility added successfully!'),
//             backgroundColor: Color(0xFF1A365D),
//           ),
//         );
//       } else if (response.statusCode == 401) {
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to add facility: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Network error: ${e.toString()}';
//       });
//     }
//   }

//   Future<void> _saveRoom() async {
//     if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       String? token = await _getToken();
//       if (token == null) {
//         throw Exception('Not authenticated');
//       }

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$_baseUrl/api/listings/rooms/'),
//       );

//       request.headers['Authorization'] = 'Bearer $token';

//       request.fields['property'] = widget.propertyId.toString();
//       request.fields['room_number'] = _roomNumberController.text;
//       request.fields['room_type'] = _roomTypeController.text;
//       request.fields['capacity'] = _capacityController.text;
//       request.fields['rent_per_month'] = _rentController.text;
//       request.fields['is_available'] = _isAvailable.toString();

//       for (int i = 0; i < _selectedFacilityIds.length; i++) {
//         request.fields['facilities[$i]'] = _selectedFacilityIds[i].toString();
//       }

//       if (_selectedImage != null) {
//         String fileName = _selectedImage!.path.split('/').last;
//         var multipartFile = await http.MultipartFile.fromPath(
//           'thumbnail',
//           _selectedImage!.path,
//           filename: fileName,
//         );
//         request.files.add(multipartFile);
//       }

//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 201) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Room added successfully!'),
//             backgroundColor: Color(0xFF1A365D),
//           ),
//         );
//         Navigator.pop(context);
//       } else if (response.statusCode == 400) {
//         final Map<String, dynamic> responseData = jsonDecode(response.body);
//         setState(() {
//           _errorMessage = 'Please fix the following errors:';
//           for (var entry in responseData.entries) {
//             if (entry.value is List) {
//               _errorMessage =
//                   '$_errorMessage\n• ${entry.key}: ${entry.value.join(', ')}';
//             } else {
//               _errorMessage = '$_errorMessage\n• ${entry.key}: ${entry.value}';
//             }
//           }
//         });
//       } else if (response.statusCode == 401) {
//         if (!mounted) return;
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to add room. Please try again later.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Network error: ${e.toString()}';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showFacilitiesDropdown() async {
//     final List<int> tempSelectedIds = List.from(_selectedFacilityIds);

//     await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setModalState) {
//             return Container(
//               padding: const EdgeInsets.all(20),
//               height: MediaQuery.of(context).size.height * 0.7,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Select Facilities',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1A365D),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           setState(() {
//                             _selectedFacilityIds = tempSelectedIds;
//                           });
//                           Navigator.pop(context);
//                         },
//                         child: const Text(
//                           'Done',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF1A365D),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     'Selected: ${_facilityOptions.where((f) => tempSelectedIds.contains(f['id'])).map((f) => f['name']).join(", ")}',
//                     style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                   ),
//                   const SizedBox(height: 16),
//                   const Divider(),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: _facilityOptions.length,
//                       itemBuilder: (context, index) {
//                         final facility = _facilityOptions[index];
//                         final isSelected = tempSelectedIds.contains(
//                           facility['id'],
//                         );

//                         return CheckboxListTile(
//                           title: Text(facility['name']),
//                           value: isSelected,
//                           activeColor: const Color(0xFF1A365D),
//                           onChanged: (bool? value) {
//                             setModalState(() {
//                               if (value == true) {
//                                 tempSelectedIds.add(facility['id']);
//                               } else {
//                                 tempSelectedIds.remove(facility['id']);
//                               }
//                             });
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );

//     setState(() {
//       _selectedFacilityIds = tempSelectedIds;
//     });
//   }

//   String getSelectedFacilitiesText() {
//     if (_selectedFacilityIds.isEmpty) {
//       return 'No facilities selected';
//     }

//     List<String> names =
//         _facilityOptions
//             .where((facility) => _selectedFacilityIds.contains(facility['id']))
//             .map((facility) => facility['name'] as String)
//             .toList();

//     if (names.length <= 2) {
//       return names.join(', ');
//     } else {
//       return '${names.length} facilities selected';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Room'),
//         backgroundColor: const Color(0xFF1A365D),
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Property info card
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         const Color(0xFF1A365D).withOpacity(0.7),
//                         const Color(0xFF1A365D),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF1A365D).withOpacity(0.3),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Adding Room To',
//                         style: TextStyle(color: Colors.white70, fontSize: 14),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         widget.propertyName,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Property ID: ${widget.propertyId}',
//                         style: const TextStyle(
//                           color: Colors.white70,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 const Text(
//                   'Room Details',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1A365D),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Room Image Section
//                 const Text(
//                   'Room Image',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Color(0xFF1A365D),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   width: double.infinity,
//                   height: 200,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: const Color(0xFF1A365D).withOpacity(0.3),
//                       width: 2,
//                       style: BorderStyle.solid,
//                     ),
//                   ),
//                   child:
//                       _selectedImage != null
//                           ? Stack(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(10),
//                                 child: Image.file(
//                                   _selectedImage!,
//                                   width: double.infinity,
//                                   height: double.infinity,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 8,
//                                 right: 8,
//                                 child: GestureDetector(
//                                   onTap: _removeSelectedImage,
//                                   child: Container(
//                                     padding: const EdgeInsets.all(4),
//                                     decoration: const BoxDecoration(
//                                       color: Color(0xFF1A365D),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Icon(
//                                       Icons.close,
//                                       color: Colors.white,
//                                       size: 20,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           )
//                           : InkWell(
//                             onTap: _pickImageFromGallery,
//                             child: const Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.add_photo_alternate,
//                                   size: 50,
//                                   color: Color(0xFF1A365D),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   'Tap to select room image from gallery',
//                                   style: TextStyle(
//                                     color: Color(0xFF1A365D),
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Room Number
//                 TextFormField(
//                   controller: _roomNumberController,
//                   decoration: InputDecoration(
//                     labelText: 'Room Number',
//                     hintText: 'e.g. A101, B202',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: Colors.grey.shade100,
//                     filled: true,
//                     prefixIcon: const Icon(
//                       Icons.meeting_room,
//                       color: Color(0xFF1A365D),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a room number';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Room Type
//                 TextFormField(
//                   controller: _roomTypeController,
//                   decoration: InputDecoration(
//                     labelText: 'Room Type',
//                     hintText: 'e.g. Single, Double, Deluxe',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: Colors.grey.shade100,
//                     filled: true,
//                     prefixIcon: const Icon(
//                       Icons.category,
//                       color: Color(0xFF1A365D),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a room type';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Capacity
//                 TextFormField(
//                   controller: _capacityController,
//                   decoration: InputDecoration(
//                     labelText: 'Capacity',
//                     hintText: 'Number of people',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: Colors.grey.shade100,
//                     filled: true,
//                     prefixIcon: const Icon(
//                       Icons.people,
//                       color: Color(0xFF1A365D),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter the capacity';
//                     }
//                     if (int.tryParse(value) == null || int.parse(value) <= 0) {
//                       return 'Please enter a valid number';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Rent per month
//                 TextFormField(
//                   controller: _rentController,
//                   decoration: InputDecoration(
//                     labelText: 'Rent per Month',
//                     hintText: 'Enter rent amount',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: Colors.grey.shade100,
//                     filled: true,
//                     prefixIcon: const Icon(
//                       Icons.attach_money,
//                       color: Color(0xFF1A365D),
//                     ),
//                   ),
//                   keyboardType: const TextInputType.numberWithOptions(
//                     decimal: true,
//                   ),
//                   inputFormatters: [
//                     FilteringTextInputFormatter.allow(
//                       RegExp(r'^\d+\.?\d{0,2}'),
//                     ),
//                   ],
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter the rent amount';
//                     }
//                     if (double.tryParse(value) == null ||
//                         double.parse(value) <= 0) {
//                       return 'Please enter a valid amount';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),

//                 // Facilities Dropdown
//                 const Text(
//                   'Room Facilities',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Color(0xFF1A365D),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 InkWell(
//                   onTap: _showFacilitiesDropdown,
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(
//                           Icons.home_repair_service_outlined,
//                           color: Color(0xFF1A365D),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             getSelectedFacilitiesText(),
//                             style: TextStyle(
//                               color:
//                                   _selectedFacilityIds.isEmpty
//                                       ? Colors.grey[600]
//                                       : Colors.black87,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                         const Icon(
//                           Icons.arrow_drop_down,
//                           color: Color(0xFF1A365D),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Add New Facility
//                 const Text(
//                   'Add New Facility',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Color(0xFF1A365D),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _newFacilityController,
//                         decoration: InputDecoration(
//                           labelText: 'New Facility',
//                           hintText: 'Enter new facility',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           fillColor: Colors.grey.shade100,
//                           filled: true,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: _addNewFacility,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF1A365D),
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                       ),
//                       child: const Text('Add'),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Availability Switch
//                 SwitchListTile(
//                   title: const Text(
//                     'Room Status',
//                     style: TextStyle(color: Color(0xFF1A365D)),
//                   ),
//                   subtitle: Text(
//                     _isAvailable ? 'Available' : 'Not Available',
//                     style: const TextStyle(color: Color(0xFF1A365D)),
//                   ),
//                   value: _isAvailable,
//                   activeColor: const Color(0xFF1A365D),
//                   onChanged: (bool value) {
//                     setState(() {
//                       _isAvailable = value;
//                     });
//                   },
//                 ),

//                 // Error message display
//                 if (_errorMessage != null)
//                   Container(
//                     margin: const EdgeInsets.only(top: 16),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.red.shade200),
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Icon(Icons.error_outline, color: Colors.red.shade700),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             _errorMessage!,
//                             style: TextStyle(color: Colors.red.shade700),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 const SizedBox(height: 24),

//                 // Save button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _saveRoom,
//                     style: ElevatedButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       backgroundColor: const Color(0xFF1A365D),
//                       disabledBackgroundColor: const Color(
//                         0xFF1A365D,
//                       ).withOpacity(0.5),
//                     ),
//                     child:
//                         _isLoading
//                             ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                             : const Text(
//                               "Save Room",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.white,
//                               ),
//                             ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _roomNumberController.dispose();
//     _roomTypeController.dispose();
//     _capacityController.dispose();
//     _rentController.dispose();
//     _newFacilityController.dispose();
//     super.dispose();
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hostelive_app/constant.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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
  List<File> _selectedImages = [];

  List<Map<String, dynamic>> _facilityOptions = [];
  List<int> _selectedFacilityIds = [];

  final _storage = const FlutterSecureStorage();
  final String _baseUrl = '$baseUrl';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchRoomFacilities();
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick images: ${e.toString()}';
      });
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
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
            backgroundColor: Color(0xFF1A365D),
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

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/listings/rooms/'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['property'] = widget.propertyId.toString();
      request.fields['room_number'] = _roomNumberController.text;
      request.fields['room_type'] = _roomTypeController.text;
      request.fields['capacity'] = _capacityController.text;
      request.fields['rent_per_month'] = _rentController.text;
      request.fields['is_available'] = _isAvailable.toString();

      for (int i = 0; i < _selectedFacilityIds.length; i++) {
        request.fields['facilities[$i]'] = _selectedFacilityIds[i].toString();
      }

      for (int i = 0; i < _selectedImages.length; i++) {
        String fileName = _selectedImages[i].path.split('/').last;
        var multipartFile = await http.MultipartFile.fromPath(
          'images[$i]',
          _selectedImages[i].path,
          filename: fileName,
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room added successfully!'),
            backgroundColor: Color(0xFF1A365D),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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
                      const Text(
                        'Select Facilities',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedFacilityIds = tempSelectedIds;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A365D),
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
                  const Divider(),
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
                          activeColor: const Color(0xFF1A365D),
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
        backgroundColor: const Color(0xFF1A365D),
        foregroundColor: Colors.white,
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
                      colors: [
                        const Color(0xFF1A365D).withOpacity(0.7),
                        const Color(0xFF1A365D),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A365D).withOpacity(0.3),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const SizedBox(height: 20),

                // Room Images Section
                const Text(
                  'Room Images',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const SizedBox(height: 8),
                _selectedImages.isEmpty
                    ? Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1A365D).withOpacity(0.3),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: InkWell(
                        onTap: _pickImagesFromGallery,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Color(0xFF1A365D),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to select room images from gallery',
                              style: TextStyle(
                                color: Color(0xFF1A365D),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _selectedImages.length) {
                                return GestureDetector(
                                  onTap: _pickImagesFromGallery,
                                  child: Container(
                                    width: 150,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF1A365D,
                                        ).withOpacity(0.3),
                                      ),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 40,
                                          color: Color(0xFF1A365D),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Add Image',
                                          style: TextStyle(
                                            color: Color(0xFF1A365D),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return Container(
                                width: 150,
                                margin: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        _selectedImages[index],
                                        width: 150,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap:
                                            () => _removeSelectedImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF1A365D),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_selectedImages.length} image${_selectedImages.length == 1 ? '' : 's'} selected',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                const SizedBox(height: 20),

                // Room Number
                TextFormField(
                  controller: _roomNumberController,
                  decoration: InputDecoration(
                    labelText: 'Room Number',
                    hintText: 'e.g. A101, B202',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    prefixIcon: const Icon(
                      Icons.meeting_room,
                      color: Color(0xFF1A365D),
                    ),
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
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    prefixIcon: const Icon(
                      Icons.category,
                      color: Color(0xFF1A365D),
                    ),
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
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    prefixIcon: const Icon(
                      Icons.people,
                      color: Color(0xFF1A365D),
                    ),
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
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: Color(0xFF1A365D),
                    ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _showFacilitiesDropdown,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.home_repair_service_outlined,
                          color: Color(0xFF1A365D),
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
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF1A365D),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Add New Facility
                const Text(
                  'Add New Facility',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A365D),
                  ),
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
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Colors.grey.shade100,
                          filled: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addNewFacility,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A365D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Availability Switch
                SwitchListTile(
                  title: const Text(
                    'Room Status',
                    style: TextStyle(color: Color(0xFF1A365D)),
                  ),
                  subtitle: Text(
                    _isAvailable ? 'Available' : 'Not Available',
                    style: const TextStyle(color: Color(0xFF1A365D)),
                  ),
                  value: _isAvailable,
                  activeColor: const Color(0xFF1A365D),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF1A365D),
                      disabledBackgroundColor: const Color(
                        0xFF1A365D,
                      ).withOpacity(0.5),
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
