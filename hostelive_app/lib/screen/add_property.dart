// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:hostelive_app/constant.dart';
// import 'package:http/http.dart' as http;
// import 'package:multi_select_flutter/multi_select_flutter.dart';
// import 'package:image_picker/image_picker.dart';

// class AddPropertyPage extends StatefulWidget {
//   const AddPropertyPage({super.key});

//   @override
//   _AddPropertyPageState createState() => _AddPropertyPageState();
// }

// class _AddPropertyPageState extends State<AddPropertyPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _newTypeController = TextEditingController();
//   final _newFacilityController = TextEditingController();

//   int? _propertyType;
//   bool _isActive = true;
//   bool _isLoading = false;
//   String? _errorMessage;
//   File? _selectedImage;

//   List<Map<String, dynamic>> _propertyTypes = [];
//   List<Map<String, dynamic>> _facilityOptions = [];

//   final _storage = const FlutterSecureStorage();
//   final String _baseUrl = '$baseUrl';
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _fetchPropertyTypes();
//     _fetchFacilities();
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

//   Future<void> _fetchPropertyTypes() async {
//     try {
//       String? token = await _getToken();
//       if (token == null) {
//         setState(() {
//           _errorMessage = 'Not authenticated. Please log in.';
//         });
//         return;
//       }

//       final response = await http.get(
//         Uri.parse('$_baseUrl/api/listings/types/'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           _propertyTypes = List<Map<String, dynamic>>.from(
//             data.map((x) => {'id': x['id'], 'name': x['name']}),
//           );
//           if (_propertyTypes.isNotEmpty && _propertyType == null) {
//             _propertyType = _propertyTypes.first['id'];
//           }
//         });
//       } else if (response.statusCode == 401) {
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         setState(() {
//           _errorMessage =
//               'Failed to fetch property types: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to fetch property types: ${e.toString()}';
//       });
//     }
//   }

//   Future<void> _fetchFacilities() async {
//     try {
//       String? token = await _getToken();
//       if (token == null) {
//         setState(() {
//           _errorMessage = 'Not authenticated. Please log in.';
//         });
//         return;
//       }

//       final response = await http.get(
//         Uri.parse('$_baseUrl/api/listings/shared-facilities/'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           _facilityOptions = List<Map<String, dynamic>>.from(
//             data.map((x) => {'id': x['id'], 'name': x['name']}),
//           );
//         });
//       } else if (response.statusCode == 401) {
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to fetch facilities: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to fetch facilities: ${e.toString()}';
//       });
//     }
//   }

//   Future<void> _addNewType() async {
//     if (_newTypeController.text.isEmpty) {
//       setState(() {
//         _errorMessage = 'Please enter a property type name.';
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
//         Uri.parse('$_baseUrl/api/listings/types/'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'name': _newTypeController.text}),
//       );
//       if (response.statusCode == 201) {
//         _newTypeController.clear();
//         _fetchPropertyTypes();
//       } else if (response.statusCode == 401) {
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to add property type: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Network error: ${e.toString()}';
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
//         Uri.parse('$_baseUrl/api/listings/shared-facilities/'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'name': _newFacilityController.text}),
//       );
//       if (response.statusCode == 201) {
//         _newFacilityController.clear();
//         _fetchFacilities();
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

//   Future<void> _saveProperty() async {
//     if (_formKey.currentState == null ||
//         !_formKey.currentState!.validate() ||
//         _propertyType == null) {
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

//       List<int> selectedFacilities =
//           _facilityOptions
//               .where((facility) => facility['selected'] == true)
//               .map((facility) => facility['id'] as int)
//               .toList();

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$_baseUrl/api/listings/properties/'),
//       );

//       request.headers['Authorization'] = 'Bearer $token';

//       request.fields['type'] = _propertyType.toString();
//       request.fields['title'] = _titleController.text;
//       request.fields['address'] = _addressController.text;
//       request.fields['city'] = _cityController.text;
//       request.fields['description'] = _descriptionController.text;
//       request.fields['is_active'] = _isActive.toString();

//       for (int i = 0; i < selectedFacilities.length; i++) {
//         request.fields['shared_facilities[$i]'] =
//             selectedFacilities[i].toString();
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
//             content: Text('Property added successfully!'),
//             backgroundColor: Color(0xFFE6C871),
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
//           _errorMessage = 'Failed to add property. Please try again later.';
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Property'),
//         backgroundColor: const Color(0xFF3B5A7A),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Property Details',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF3B5A7A),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Property Image Section
//                 const Text(
//                   'Property Image',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Color(0xFF3B5A7A),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   width: double.infinity,
//                   height: 200,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF3B5A7A).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(18),
//                     border: Border.all(
//                       color: const Color(0xFF3B5A7A).withOpacity(0.3),
//                       width: 2,
//                       style: BorderStyle.solid,
//                     ),
//                   ),
//                   child:
//                       _selectedImage != null
//                           ? Stack(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(16),
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
//                                       color: Color(0xFFE6C871),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Icon(
//                                       Icons.close,
//                                       color: Color(0xFF3B5A7A),
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
//                                   color: Color(0xFF3B5A7A),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   'Tap to select image from gallery',
//                                   style: TextStyle(
//                                     color: Color(0xFF3B5A7A),
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Property Type
//                 const Text(
//                   'Property Type',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF3B5A7A),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 DropdownButtonFormField<int>(
//                   value: _propertyType,
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: const Color(0xFF3B5A7A).withOpacity(0.1),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(18),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 14,
//                     ),
//                   ),
//                   items:
//                       _propertyTypes.map((type) {
//                         return DropdownMenuItem<int>(
//                           value: type['id'],
//                           child: Text(type['name']),
//                         );
//                       }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _propertyType = value;
//                     });
//                   },
//                   validator:
//                       (value) =>
//                           value == null
//                               ? 'Please select a property type'
//                               : null,
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _newTypeController,
//                         decoration: InputDecoration(
//                           labelText: 'New Property Type',
//                           hintText: 'Enter new type',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(18),
//                             borderSide: BorderSide.none,
//                           ),
//                           fillColor: const Color(0xFF3B5A7A).withOpacity(0.1),
//                           filled: true,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: _addNewType,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFE6C871),
//                       ),
//                       child: const Text(
//                         'Add',
//                         style: TextStyle(color: Color(0xFF3B5A7A)),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),

//                 // Title
//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Property Title',
//                     hintText: 'Enter property name',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(18),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: const Color(0xFF3B5A7A).withOpacity(0.1),
//                     filled: true,
//                     prefixIcon: const Icon(
//                       Icons.title,
//                       color: Color(0xFF3B5A7A),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a title';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Address
//                 TextFormField(
//                   controller: _addressController,
//                   decoration: InputDecoration(
//                     labelText: 'Address',
//                     hintText: 'Enter property address',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(18),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: const Color(0xFF3B5A7A).withOpacity(0.1),
//                     filled: true,
//                     prefixIcon: const Icon(
//                       Icons.location_on,
//                       color: Color(0xFF3B5A7A),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter an address';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // City
//                 TextFormField(
//                   controller: _cityController,
//                   decoration: InputDecoration(
//                     labelText: 'City',
//                     hintText: 'Enter city name',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(18),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: const Color(0xFF3B5A7A).withOpacity(0.1),
//                     filled: true,
//                     prefixIcon: const Icon(
//                       Icons.location_city,
//                       color: Color(0xFF3B5A7A),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a city';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),

//                 // Facilities
//                 const Text(
//                   'Facilities',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Color(0xFF3B5A7A),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 MultiSelectDialogField(
//                   items:
//                       _facilityOptions
//                           .map(
//                             (facility) => MultiSelectItem<Map<String, dynamic>>(
//                               facility,
//                               facility['name'],
//                             ),
//                           )
//                           .toList(),
//                   title: const Text('Select Facilities'),
//                   selectedColor: const Color(0xFF3B5A7A),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF3B5A7A).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                   buttonText: const Text(
//                     'Select Facilities',
//                     style: TextStyle(color: Color(0xFF3B5A7A)),
//                   ),
//                   buttonIcon: const Icon(
//                     Icons.arrow_drop_down,
//                     color: Color(0xFF3B5A7A),
//                   ),
//                   onConfirm: (selected) {
//                     setState(() {
//                       for (var facility in _facilityOptions) {
//                         facility['selected'] = false;
//                       }
//                       for (var selectedFacility
//                           in selected.cast<Map<String, dynamic>>()) {
//                         var facility = _facilityOptions.firstWhere(
//                           (f) => f['id'] == selectedFacility['id'],
//                         );
//                         facility['selected'] = true;
//                       }
//                     });
//                   },
//                   chipDisplay: MultiSelectChipDisplay(
//                     chipColor: const Color(0xFF3B5A7A).withOpacity(0.2),
//                     textStyle: const TextStyle(color: Color(0xFF3B5A7A)),
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
//                             borderRadius: BorderRadius.circular(18),
//                             borderSide: BorderSide.none,
//                           ),
//                           fillColor: const Color(0xFF3B5A7A).withOpacity(0.1),
//                           filled: true,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: _addNewFacility,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFE6C871),
//                       ),
//                       child: const Text(
//                         'Add',
//                         style: TextStyle(color: Color(0xFF3B5A7A)),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Description
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     hintText: 'Enter property description',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(18),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: const Color(0xFF3B5A7A).withOpacity(0.1),
//                     filled: true,
//                     alignLabelWithHint: true,
//                   ),
//                   maxLines: 5,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a description';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Status Switch
//                 SwitchListTile(
//                   title: const Text(
//                     'Property Status',
//                     style: TextStyle(color: Color(0xFF3B5A7A)),
//                   ),
//                   subtitle: Text(
//                     _isActive ? 'Active' : 'Inactive',
//                     style: TextStyle(color: Color(0xFF3B5A7A)),
//                   ),
//                   value: _isActive,
//                   activeColor: const Color(0xFFE6C871),
//                   onChanged: (bool value) {
//                     setState(() {
//                       _isActive = value;
//                     });
//                   },
//                 ),

//                 // Error message display
//                 if (_errorMessage != null)
//                   Container(
//                     margin: const EdgeInsets.only(top: 16),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFE6C871).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: const Color(0xFFE6C871).withOpacity(0.3),
//                       ),
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Icon(
//                           Icons.error_outline,
//                           color: const Color(0xFFE6C871),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             _errorMessage!,
//                             style: const TextStyle(color: Color(0xFFE6C871)),
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
//                     onPressed: _isLoading ? null : _saveProperty,
//                     style: ElevatedButton.styleFrom(
//                       shape: const StadiumBorder(),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       backgroundColor: const Color(0xFFE6C871),
//                       disabledBackgroundColor: const Color(
//                         0xFFE6C871,
//                       ).withOpacity(0.5),
//                     ),
//                     child:
//                         _isLoading
//                             ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 color: Color(0xFF3B5A7A),
//                                 strokeWidth: 2,
//                               ),
//                             )
//                             : const Text(
//                               "Save Property",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Color(0xFF3B5A7A),
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
//     _titleController.dispose();
//     _addressController.dispose();
//     _cityController.dispose();
//     _descriptionController.dispose();
//     _newTypeController.dispose();
//     _newFacilityController.dispose();
//     super.dispose();
//   }
// }

// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:hostelive_app/constant.dart';
// import 'package:http/http.dart' as http;
// import 'package:multi_select_flutter/multi_select_flutter.dart';
// import 'package:image_picker/image_picker.dart';

// class AddPropertyPage extends StatefulWidget {
//   const AddPropertyPage({super.key});

//   @override
//   _AddPropertyPageState createState() => _AddPropertyPageState();
// }

// class _AddPropertyPageState extends State<AddPropertyPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _newTypeController = TextEditingController();
//   final _newFacilityController = TextEditingController();

//   int? _propertyType;
//   bool _isActive = true;
//   bool _isLoading = false;
//   String? _errorMessage;
//   File? _selectedImage;

//   List<Map<String, dynamic>> _propertyTypes = [];
//   List<Map<String, dynamic>> _facilityOptions = [];

//   final _storage = const FlutterSecureStorage();
//   final String _baseUrl = '$baseUrl';
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _fetchPropertyTypes();
//     _fetchFacilities();
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

//   Future<void> _fetchPropertyTypes() async {
//     try {
//       String? token = await _getToken();
//       if (token == null) {
//         setState(() {
//           _errorMessage = 'Not authenticated. Please log in.';
//         });
//         return;
//       }

//       final response = await http.get(
//         Uri.parse('$_baseUrl/api/listings/types/'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           _propertyTypes = List<Map<String, dynamic>>.from(
//             data.map((x) => {'id': x['id'], 'name': x['name']}),
//           );
//           if (_propertyTypes.isNotEmpty && _propertyType == null) {
//             _propertyType = _propertyTypes.first['id'];
//           }
//         });
//       } else if (response.statusCode == 401) {
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         setState(() {
//           _errorMessage =
//               'Failed to fetch property types: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to fetch property types: ${e.toString()}';
//       });
//     }
//   }

//   Future<void> _fetchFacilities() async {
//     try {
//       String? token = await _getToken();
//       if (token == null) {
//         setState(() {
//           _errorMessage = 'Not authenticated. Please log in.';
//         });
//         return;
//       }

//       final response = await http.get(
//         Uri.parse('$_baseUrl/api/listings/shared-facilities/'),
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
//           _errorMessage = 'Failed to fetch facilities: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to fetch facilities: ${e.toString()}';
//       });
//     }
//   }

//   Future<void> _addNewType() async {
//     if (_newTypeController.text.isEmpty) {
//       setState(() {
//         _errorMessage = 'Please enter a property type name.';
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
//         Uri.parse('$_baseUrl/api/listings/types/'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'name': _newTypeController.text}),
//       );
//       if (response.statusCode == 201) {
//         _newTypeController.clear();
//         _fetchPropertyTypes();
//       } else if (response.statusCode == 401) {
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to add property type: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Network error: ${e.toString()}';
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
//         Uri.parse('$_baseUrl/api/listings/shared-facilities/'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'name': _newFacilityController.text}),
//       );
//       if (response.statusCode == 201) {
//         _newFacilityController.clear();
//         _fetchFacilities();
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

//   Future<void> _saveProperty() async {
//     if (_formKey.currentState == null ||
//         !_formKey.currentState!.validate() ||
//         _propertyType == null) {
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

//       List<int> selectedFacilities =
//           _facilityOptions
//               .where((facility) => facility['selected'] == true)
//               .map((facility) => facility['id'] as int)
//               .toList();

//       print('Selected Facilities: $selectedFacilities');

//       // Create form data manually to handle multiple values for same key
//       String boundary =
//           'dart-http-boundary-${DateTime.now().millisecondsSinceEpoch}';
//       List<int> body = [];

//       // Helper function to add form field
//       void addFormField(String name, String value) {
//         body.addAll(utf8.encode('--$boundary\r\n'));
//         body.addAll(
//           utf8.encode('Content-Disposition: form-data; name="$name"\r\n\r\n'),
//         );
//         body.addAll(utf8.encode('$value\r\n'));
//       }

//       // Add basic fields
//       addFormField('type', _propertyType.toString());
//       addFormField('title', _titleController.text);
//       addFormField('address', _addressController.text);
//       addFormField('city', _cityController.text);
//       addFormField('description', _descriptionController.text);
//       addFormField('is_active', _isActive.toString());

//       // Add each facility as separate form field with same name
//       for (int facility in selectedFacilities) {
//         addFormField('shared_facilities', facility.toString());
//       }

//       // Add image if selected
//       if (_selectedImage != null) {
//         String fileName = _selectedImage!.path.split('/').last;
//         List<int> imageBytes = await _selectedImage!.readAsBytes();

//         body.addAll(utf8.encode('--$boundary\r\n'));
//         body.addAll(
//           utf8.encode(
//             'Content-Disposition: form-data; name="thumbnail"; filename="$fileName"\r\n',
//           ),
//         );
//         body.addAll(utf8.encode('Content-Type: image/jpeg\r\n\r\n'));
//         body.addAll(imageBytes);
//         body.addAll(utf8.encode('\r\n'));
//       }

//       // Add final boundary
//       body.addAll(utf8.encode('--$boundary--\r\n'));

//       // Create the request
//       var request = http.Request(
//         'POST',
//         Uri.parse('$_baseUrl/api/listings/properties/'),
//       );
//       request.headers['Authorization'] = 'Bearer $token';
//       request.headers['Content-Type'] =
//           'multipart/form-data; boundary=$boundary';
//       request.bodyBytes = body;

//       print('Sending request with ${selectedFacilities.length} facilities');

//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 201) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Property added successfully!'),
//             backgroundColor: Color(0xFFE6C871),
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
//         print('Response Body: ${response.body}');
//       } else if (response.statusCode == 401) {
//         if (!mounted) return;
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to add property: ${response.statusCode}';
//         });
//         print('Response Body: ${response.body}');
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Network error: ${e.toString()}';
//       });
//       print('Error: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Property'),
//         backgroundColor: const Color(0xFF3B5A7A),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Property Details',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF3B5A7A),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Property Image Section
//                 const Text(
//                   'Property Image',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Color(0xFF3B5A7A),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   width: double.infinity,
//                   height: 200,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF3B5A7A).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(18),
//                     border: Border.all(
//                       color: const Color(0xFF3B5A7A).withOpacity(0.3),
//                       width: 2,
//                       style: BorderStyle.solid,
//                     ),
//                   ),
//                   child:
//                       _selectedImage != null
//                           ? Stack(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(16),
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
//                                       color: Color(0xFFE6C871),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Icon(
//                                       Icons.close,
//                                       color: Color(0xFF3B5A7A),
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
//                                   color: Color(0xFF3B5A7A),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   'Tap to select image from gallery',
//                                   style: TextStyle(
//                                     color: Color(0xFF3B5A7A),
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Property Type
//                 const Text(
//                   'Property Type',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF3B5A7A),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 DropdownButtonFormField<int>(
//                   value: _propertyType,
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: const Color(0xFF3B5A7A).withOpacity(0.1),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(18),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 14,
//                     ),
//                   ),
//                   items:
//                       _propertyTypes.map((type) {
//                         return DropdownMenuItem<int>(
//                           value: type['id'],
//                           child: Text(type['name']),
//                         );
//                       }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _propertyType = value;
//                     });
//                   },
//                   validator:
//                       (value) =>
//                           value == null
//                               ? 'Please select a property type'
//                               : null,
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _newTypeController,
//                         decoration: InputDecoration(
//                           labelText: 'New Property Type',
//                           hintText: 'Enter new type',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(18),
//                             borderSide: BorderSide.none,
//                           ),
//                           fillColor: const Color(0xFF3B5A7A).withOpacity(0.1),
//                           filled: true,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: _addNewType,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFE6C871),
//                       ),
//                       child: const Text(
//                         'Add',
//                         style: TextStyle(color: Color(0xFF3B5A7A)),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),

//                 // Title
//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Property Title',
//                     hintText: 'Enter property name',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(18),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: const Color(0xFF3B5A7A).withOpacity(0.1),
//                     filled: true,
//                     prefixIcon: const Icon(
//                       Icons.title,
//                       color: Color(0xFF3B5A7A),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a title';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Address
//                 TextFormField(
//                   controller: _addressController,
//                   decoration: InputDecoration(
//                     labelText: 'Address',
//                     hintText: 'Enter property address',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(18),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: const Color(0xFF3B5A7A).withOpacity(0.1),
//                     filled: true,
//                     prefixIcon: const Icon(
//                       Icons.location_on,
//                       color: Color(0xFF3B5A7A),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter an address';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // City
//                 TextFormField(
//                   controller: _cityController,
//                   decoration: InputDecoration(
//                     labelText: 'City',
//                     hintText: 'Enter city name',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(18),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: const Color(0xFF3B5A7A).withOpacity(0.1),
//                     filled: true,
//                     prefixIcon: const Icon(
//                       Icons.location_city,
//                       color: Color(0xFF3B5A7A),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a city';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),

//                 // Facilities
//                 const Text(
//                   'Facilities',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Color(0xFF3B5A7A),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 MultiSelectDialogField(
//                   items:
//                       _facilityOptions
//                           .map(
//                             (facility) => MultiSelectItem<Map<String, dynamic>>(
//                               facility,
//                               facility['name'],
//                             ),
//                           )
//                           .toList(),
//                   title: const Text('Select Facilities'),
//                   selectedColor: const Color(0xFF3B5A7A),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF3B5A7A).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                   buttonText: const Text(
//                     'Select Facilities',
//                     style: TextStyle(color: Color(0xFF3B5A7A)),
//                   ),
//                   buttonIcon: const Icon(
//                     Icons.arrow_drop_down,
//                     color: Color(0xFF3B5A7A),
//                   ),
//                   onConfirm: (selected) {
//                     setState(() {
//                       for (var facility in _facilityOptions) {
//                         facility['selected'] = false;
//                       }
//                       for (var selectedFacility
//                           in selected.cast<Map<String, dynamic>>()) {
//                         var facility = _facilityOptions.firstWhere(
//                           (f) => f['id'] == selectedFacility['id'],
//                         );
//                         facility['selected'] = true;
//                       }
//                     });
//                   },
//                   chipDisplay: MultiSelectChipDisplay(
//                     chipColor: const Color(0xFF3B5A7A).withOpacity(0.2),
//                     textStyle: const TextStyle(color: Color(0xFF3B5A7A)),
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
//                             borderRadius: BorderRadius.circular(18),
//                             borderSide: BorderSide.none,
//                           ),
//                           fillColor: const Color(0xFF3B5A7A).withOpacity(0.1),
//                           filled: true,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: _addNewFacility,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFE6C871),
//                       ),
//                       child: const Text(
//                         'Add',
//                         style: TextStyle(color: Color(0xFF3B5A7A)),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Description
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     hintText: 'Enter property description',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(18),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: const Color(0xFF3B5A7A).withOpacity(0.1),
//                     filled: true,
//                     alignLabelWithHint: true,
//                   ),
//                   maxLines: 5,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a description';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Status Switch
//                 SwitchListTile(
//                   title: const Text(
//                     'Property Status',
//                     style: TextStyle(color: Color(0xFF3B5A7A)),
//                   ),
//                   subtitle: Text(
//                     _isActive ? 'Active' : 'Inactive',
//                     style: TextStyle(color: Color(0xFF3B5A7A)),
//                   ),
//                   value: _isActive,
//                   activeColor: const Color(0xFFE6C871),
//                   onChanged: (bool value) {
//                     setState(() {
//                       _isActive = value;
//                     });
//                   },
//                 ),

//                 // Error message display
//                 if (_errorMessage != null)
//                   Container(
//                     margin: const EdgeInsets.only(top: 16),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFE6C871).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: const Color(0xFFE6C871).withOpacity(0.3),
//                       ),
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Icon(
//                           Icons.error_outline,
//                           color: const Color(0xFFE6C871),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             _errorMessage!,
//                             style: const TextStyle(color: Color(0xFFE6C871)),
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
//                     onPressed: _isLoading ? null : _saveProperty,
//                     style: ElevatedButton.styleFrom(
//                       shape: const StadiumBorder(),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       backgroundColor: const Color(0xFFE6C871),
//                       disabledBackgroundColor: const Color(
//                         0xFFE6C871,
//                       ).withOpacity(0.5),
//                     ),
//                     child:
//                         _isLoading
//                             ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 color: Color(0xFF3B5A7A),
//                                 strokeWidth: 2,
//                               ),
//                             )
//                             : const Text(
//                               "Save Property",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Color(0xFF3B5A7A),
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
//     _titleController.dispose();
//     _addressController.dispose();
//     _cityController.dispose();
//     _descriptionController.dispose();
//     _newTypeController.dispose();
//     _newFacilityController.dispose();
//     super.dispose();
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hostelive_app/constant.dart';
import 'package:http/http.dart' as http;
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  _AddPropertyPageState createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _newTypeController = TextEditingController();
  final _newFacilityController = TextEditingController();

  int? _propertyType;
  bool _isActive = true;
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImage;

  List<Map<String, dynamic>> _propertyTypes = [];
  List<Map<String, dynamic>> _facilityOptions = [];

  final _storage = const FlutterSecureStorage();
  final String _baseUrl = '$baseUrl';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchPropertyTypes();
    _fetchFacilities();
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: ${e.toString()}';
      });
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _fetchPropertyTypes() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Not authenticated. Please log in.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/listings/types/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _propertyTypes = List<Map<String, dynamic>>.from(
            data.map((x) => {'id': x['id'], 'name': x['name']}),
          );
          if (_propertyTypes.isNotEmpty && _propertyType == null) {
            _propertyType = _propertyTypes.first['id'];
          }
        });
      } else if (response.statusCode == 401) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _errorMessage =
              'Failed to fetch property types: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch property types: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchFacilities() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Not authenticated. Please log in.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/listings/shared-facilities/'),
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
          _errorMessage = 'Failed to fetch facilities: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch facilities: ${e.toString()}';
      });
    }
  }

  Future<void> _addNewType() async {
    if (_newTypeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a property type name.';
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
        Uri.parse('$_baseUrl/api/listings/types/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': _newTypeController.text}),
      );
      if (response.statusCode == 201) {
        _newTypeController.clear();
        _fetchPropertyTypes();
      } else if (response.statusCode == 401) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _errorMessage = 'Failed to add property type: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
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
        Uri.parse('$_baseUrl/api/listings/shared-facilities/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': _newFacilityController.text}),
      );
      if (response.statusCode == 201) {
        _newFacilityController.clear();
        _fetchFacilities();
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

  Future<void> _saveProperty() async {
    if (_formKey.currentState == null ||
        !_formKey.currentState!.validate() ||
        _propertyType == null) {
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

      List<int> selectedFacilities =
          _facilityOptions
              .where((facility) => facility['selected'] == true)
              .map((facility) => facility['id'] as int)
              .toList();

      print('Selected Facilities: $selectedFacilities');

      String boundary =
          'dart-http-boundary-${DateTime.now().millisecondsSinceEpoch}';
      List<int> body = [];

      void addFormField(String name, String value) {
        body.addAll(utf8.encode('--$boundary\r\n'));
        body.addAll(
          utf8.encode('Content-Disposition: form-data; name="$name"\r\n\r\n'),
        );
        body.addAll(utf8.encode('$value\r\n'));
      }

      addFormField('type', _propertyType.toString());
      addFormField('title', _titleController.text);
      addFormField('address', _addressController.text);
      addFormField('city', _cityController.text);
      addFormField('description', _descriptionController.text);
      addFormField('is_active', _isActive.toString());

      for (int facility in selectedFacilities) {
        addFormField('shared_facilities', facility.toString());
      }

      if (_selectedImage != null) {
        String fileName = _selectedImage!.path.split('/').last;
        List<int> imageBytes = await _selectedImage!.readAsBytes();

        body.addAll(utf8.encode('--$boundary\r\n'));
        body.addAll(
          utf8.encode(
            'Content-Disposition: form-data; name="thumbnail"; filename="$fileName"\r\n',
          ),
        );
        body.addAll(utf8.encode('Content-Type: image/jpeg\r\n\r\n'));
        body.addAll(imageBytes);
        body.addAll(utf8.encode('\r\n'));
      }

      body.addAll(utf8.encode('--$boundary--\r\n'));

      var request = http.Request(
        'POST',
        Uri.parse('$_baseUrl/api/listings/properties/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] =
          'multipart/form-data; boundary=$boundary';
      request.bodyBytes = body;

      print('Sending request with ${selectedFacilities.length} facilities');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property added successfully!'),
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
        print('Response Body: ${response.body}');
      } else if (response.statusCode == 401) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _errorMessage = 'Failed to add property: ${response.statusCode}';
        });
        print('Response Body: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
      });
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Property'),
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
                const Text(
                  'Property Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const SizedBox(height: 20),

                // Property Image Section
                const Text(
                  'Property Image',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
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
                  child:
                      _selectedImage != null
                          ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _selectedImage!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: _removeSelectedImage,
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
                          )
                          : InkWell(
                            onTap: _pickImageFromGallery,
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
                                  'Tap to select image from gallery',
                                  style: TextStyle(
                                    color: Color(0xFF1A365D),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
                const SizedBox(height: 20),

                // Property Type
                const Text(
                  'Property Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _propertyType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  items:
                      _propertyTypes.map((type) {
                        return DropdownMenuItem<int>(
                          value: type['id'],
                          child: Text(type['name']),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _propertyType = value;
                    });
                  },
                  validator:
                      (value) =>
                          value == null
                              ? 'Please select a property type'
                              : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _newTypeController,
                        decoration: InputDecoration(
                          labelText: 'New Property Type',
                          hintText: 'Enter new type',
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
                      onPressed: _addNewType,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A365D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Property Title',
                    hintText: 'Enter property name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    prefixIcon: const Icon(
                      Icons.title,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter property address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // City
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    hintText: 'Enter city name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    prefixIcon: const Icon(
                      Icons.location_city,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Facilities
                const Text(
                  'Facilities',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const SizedBox(height: 8),
                MultiSelectDialogField(
                  items:
                      _facilityOptions
                          .map(
                            (facility) => MultiSelectItem<Map<String, dynamic>>(
                              facility,
                              facility['name'],
                            ),
                          )
                          .toList(),
                  title: const Text('Select Facilities'),
                  selectedColor: const Color(0xFF1A365D),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  buttonText: const Text(
                    'Select Facilities',
                    style: TextStyle(color: Color(0xFF1A365D)),
                  ),
                  buttonIcon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF1A365D),
                  ),
                  onConfirm: (selected) {
                    setState(() {
                      for (var facility in _facilityOptions) {
                        facility['selected'] = false;
                      }
                      for (var selectedFacility
                          in selected.cast<Map<String, dynamic>>()) {
                        var facility = _facilityOptions.firstWhere(
                          (f) => f['id'] == selectedFacility['id'],
                        );
                        facility['selected'] = true;
                      }
                    });
                  },
                  chipDisplay: MultiSelectChipDisplay(
                    chipColor: const Color(0xFF1A365D).withOpacity(0.2),
                    textStyle: const TextStyle(color: Color(0xFF1A365D)),
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
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter property description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Status Switch
                SwitchListTile(
                  title: const Text(
                    'Property Status',
                    style: TextStyle(color: Color(0xFF1A365D)),
                  ),
                  subtitle: Text(
                    _isActive ? 'Active' : 'Inactive',
                    style: TextStyle(color: Color(0xFF1A365D)),
                  ),
                  value: _isActive,
                  activeColor: const Color(0xFF1A365D),
                  onChanged: (bool value) {
                    setState(() {
                      _isActive = value;
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
                    onPressed: _isLoading ? null : _saveProperty,
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
                              "Save Property",
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
    _titleController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _newTypeController.dispose();
    _newFacilityController.dispose();
    super.dispose();
  }
}
