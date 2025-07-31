// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:hostelive_app/constant.dart';
// import 'package:hostelive_app/screen/student_property_detail.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// final FlutterSecureStorage _storage = const FlutterSecureStorage();

// Future<String?> getAccessToken() async {
//   final token = await _storage.read(key: 'access_token');
//   print('🔐 [Token] Loaded access_token: $token');
//   return token;
// }

// class StudentDashboard extends StatefulWidget {
//   const StudentDashboard({super.key});

//   @override
//   _StudentDashboardState createState() => _StudentDashboardState();
// }

// class _StudentDashboardState extends State<StudentDashboard>
//     with SingleTickerProviderStateMixin {
//   String _username = 'Student';
//   late TabController _tabController;

//   List<dynamic> _properties = [];
//   List<dynamic> _rooms = [];
//   List<dynamic> _sharedFacilities = [];
//   bool _isLoadingProperties = false;
//   bool _isLoadingRooms = false;
//   bool _isLoadingFacilities = false;
//   String _errorMessage = '';

//   // Property filter controllers
//   final _propertySearchCityController = TextEditingController();
//   List<String> _selectedPropertyFacilities = [];

//   // Room filter controllers
//   final _roomPriceController = TextEditingController();
//   final _roomCapacityController = TextEditingController();
//   String? _roomType;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadUserData();
//     _fetchSharedFacilities();
//     _fetchProperties();
//     _fetchRooms();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _propertySearchCityController.dispose();
//     _roomPriceController.dispose();
//     _roomCapacityController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadUserData() async {
//     final username = await _storage.read(key: 'username');
//     setState(() {
//       _username = username ?? 'Student';
//     });
//     print('StudentDashboard _loadUserData - username: $username');
//   }

//   Future<String?> _loadToken() async {
//     final token = await _storage.read(key: 'access_token');
//     print('📦 StudentDashboard - Using access_token: $token');
//     return token;
//   }

//   Future<void> _fetchSharedFacilities() async {
//     setState(() {
//       _isLoadingFacilities = true;
//       _errorMessage = '';
//     });

//     try {
//       final token = await _loadToken();
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/listings/shared-facilities/'),
//         headers: {
//           'Content-Type': 'application/json',
//           if (token != null) 'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           _sharedFacilities = data;
//           _isLoadingFacilities = false;
//         });
//         print('✅ Shared facilities loaded: ${data.length} items');
//       } else {
//         throw Exception(
//           'Failed to load shared facilities: ${response.statusCode} ${response.reasonPhrase}',
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error loading shared facilities: $e';
//         _isLoadingFacilities = false;
//       });
//       print('❌ Error loading shared facilities: $e');
//     }
//   }

//   Future<void> _fetchProperties() async {
//     setState(() {
//       _isLoadingProperties = true;
//       _errorMessage = '';
//     });

//     try {
//       final token = await _loadToken();
//       final queryParameters = <String, List<String>>{};
//       if (_propertySearchCityController.text.isNotEmpty) {
//         queryParameters['search_city'] = [_propertySearchCityController.text];
//       }
//       if (_selectedPropertyFacilities.isNotEmpty) {
//         queryParameters['shared_facilities'] = _selectedPropertyFacilities;
//       }

//       final uri = Uri.parse('$baseUrl/api/listings/properties/').replace(
//         queryParameters: queryParameters.map(
//           (key, value) => MapEntry(key, value),
//         ),
//       );

//       print('🔍 Fetching properties with URL: $uri');

//       final response = await http.get(
//         uri,
//         headers: {
//           'Content-Type': 'application/json',
//           if (token != null) 'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           _properties = data;
//           _isLoadingProperties = false;
//         });
//         print('✅ Properties loaded: ${data.length} items');
//       } else {
//         throw Exception(
//           'Failed to load properties: ${response.statusCode} ${response.reasonPhrase}',
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error loading properties: $e';
//         _isLoadingProperties = false;
//       });
//       print('❌ Error loading properties: $e');
//     }
//   }

//   Future<void> _fetchRooms() async {
//     setState(() {
//       _isLoadingRooms = true;
//       _errorMessage = '';
//     });

//     try {
//       final token = await _loadToken();
//       final queryParameters = <String, String>{};
//       if (_roomType != null) {
//         queryParameters['room_type'] = _roomType!.toLowerCase();
//       }
//       if (_roomPriceController.text.isNotEmpty) {
//         queryParameters['rent'] = _roomPriceController.text;
//       }
//       if (_roomCapacityController.text.isNotEmpty) {
//         queryParameters['capacity'] = _roomCapacityController.text;
//       }

//       final uri = Uri.parse(
//         '$baseUrl/api/listings/rooms/',
//       ).replace(queryParameters: queryParameters);

//       final response = await http.get(
//         uri,
//         headers: {
//           'Content-Type': 'application/json',
//           if (token != null) 'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           _rooms = data;
//           _isLoadingRooms = false;
//         });
//         print('✅ Rooms loaded: ${data.length} items');
//       } else {
//         throw Exception(
//           'Failed to load rooms: ${response.statusCode} ${response.reasonPhrase}',
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error loading rooms: $e';
//         _isLoadingRooms = false;
//       });
//       print('❌ Error loading rooms: $e');
//     }
//   }

//   Future<void> _logout() async {
//     await _storage.deleteAll();
//     Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//   }

//   void _showSearchDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return DefaultTabController(
//           length: 2,
//           child: Dialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             backgroundColor: Colors.white,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               color: Colors.white,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TabBar(
//                     tabs: const [Tab(text: 'Properties'), Tab(text: 'Rooms')],
//                     labelColor: const Color(0xFF3B5A7A),
//                     unselectedLabelColor: Colors.grey[600],
//                     indicatorColor: const Color(0xFFE6C871),
//                   ),
//                   const SizedBox(height: 16),
//                   SizedBox(
//                     height: 300,
//                     child: TabBarView(
//                       children: [
//                         _buildPropertyFilterDialog(),
//                         _buildRoomFilterDialog(),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF3B5A7A),
//         title: Text(
//           'Welcome, $_username',
//           style: const TextStyle(
//             color: Color(0xFFE6C871),
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         automaticallyImplyLeading: false,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search, color: Color(0xFFE6C871)),
//             onPressed: _showSearchDialog,
//           ),
//           IconButton(
//             icon: const Icon(Icons.person, color: Color(0xFFE6C871)),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const ProfilePage()),
//               );
//             },
//           ),
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Color(0xFFE6C871)),
//             onSelected: (value) {
//               if (value == 'logout') {
//                 _logout();
//               }
//             },
//             itemBuilder:
//                 (BuildContext context) => [
//                   const PopupMenuItem<String>(
//                     value: 'logout',
//                     child: Row(
//                       children: [
//                         Icon(Icons.logout, color: Color(0xFF3B5A7A)),
//                         SizedBox(width: 8),
//                         Text(
//                           'Logout',
//                           style: TextStyle(color: Color(0xFF3B5A7A)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//           ),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(icon: Icon(Icons.home_work), text: 'Properties'),
//             Tab(icon: Icon(Icons.room), text: 'Rooms'),
//           ],
//           labelColor: const Color(0xFFE6C871),
//           unselectedLabelColor: Colors.grey[400],
//           indicatorColor: const Color(0xFFE6C871),
//           labelStyle: TextStyle(fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: SafeArea(
//         child: TabBarView(
//           controller: _tabController,
//           children: [_buildPropertiesTab(), _buildRoomsTab()],
//         ),
//       ),
//     );
//   }

//   Widget _buildPropertiesTab() {
//     return _isLoadingProperties || _isLoadingFacilities
//         ? const Center(
//           child: CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE6C871)),
//           ),
//         )
//         : _errorMessage.isNotEmpty
//         ? Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
//               const SizedBox(height: 16),
//               Text(
//                 _errorMessage,
//                 style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   _fetchSharedFacilities();
//                   _fetchProperties();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE6C871),
//                   foregroundColor: const Color(0xFF3B5A7A),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         )
//         : _properties.isEmpty
//         ? Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.home_work_outlined, size: 64, color: Colors.grey[600]),
//               const SizedBox(height: 16),
//               Text(
//                 'No properties found',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         )
//         : ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: _properties.length,
//           itemBuilder: (context, index) {
//             final property = _properties[index];
//             return GestureDetector(
//               onTap: () async {
//                 final token = await _loadToken();
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder:
//                         (context) => PropertyDetailPage(
//                           property: property,
//                           initialToken: token,
//                         ),
//                   ),
//                 );
//               },
//               child: _buildPropertyCard(property),
//             );
//           },
//         );
//   }

//   Widget _buildRoomsTab() {
//     return _isLoadingRooms
//         ? const Center(
//           child: CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE6C871)),
//           ),
//         )
//         : _errorMessage.isNotEmpty
//         ? Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
//               const SizedBox(height: 16),
//               Text(
//                 _errorMessage,
//                 style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _fetchRooms,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE6C871),
//                   foregroundColor: const Color(0xFF3B5A7A),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         )
//         : _rooms.isEmpty
//         ? Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.room_outlined, size: 64, color: Colors.grey[600]),
//               const SizedBox(height: 16),
//               Text(
//                 'No rooms found',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         )
//         : ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: _rooms.length,
//           itemBuilder: (context, index) {
//             final room = _rooms[index];
//             return _buildRoomCard(room);
//           },
//         );
//   }

//   Widget _buildPropertyFilterDialog() {
//     return StatefulBuilder(
//       builder: (BuildContext context, StateSetter dialogSetState) {
//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextField(
//                 controller: _propertySearchCityController,
//                 decoration: InputDecoration(
//                   labelText: 'City (e.g., Berlin)',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   prefixIcon: const Icon(
//                     Icons.location_city,
//                     color: Color(0xFF3B5A7A),
//                   ),
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.clear, color: Color(0xFF3B5A7A)),
//                     onPressed: () {
//                       _propertySearchCityController.clear();
//                       dialogSetState(() {});
//                     },
//                   ),
//                 ),
//                 onChanged: (_) => dialogSetState(() {}),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Shared Facilities',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF3B5A7A),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               _isLoadingFacilities
//                   ? const Center(
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         Color(0xFFE6C871),
//                       ),
//                     ),
//                   )
//                   : _sharedFacilities.isEmpty
//                   ? const Text(
//                     'No facilities available',
//                     style: TextStyle(color: Colors.grey, fontSize: 14),
//                   )
//                   : Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children:
//                         _sharedFacilities.map((facility) {
//                           final id = facility['id'].toString();
//                           final name = facility['name'] ?? 'Facility $id';
//                           return ChoiceChip(
//                             label: Text(name),
//                             selected: _selectedPropertyFacilities.contains(id),
//                             selectedColor: const Color(
//                               0xFFE6C871,
//                             ).withOpacity(0.3),
//                             backgroundColor: Colors.grey[200],
//                             labelStyle: TextStyle(
//                               color:
//                                   _selectedPropertyFacilities.contains(id)
//                                       ? const Color(0xFF3B5A7A)
//                                       : Colors.grey[600],
//                               fontWeight:
//                                   _selectedPropertyFacilities.contains(id)
//                                       ? FontWeight.w600
//                                       : FontWeight.normal,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               side: BorderSide(
//                                 color:
//                                     _selectedPropertyFacilities.contains(id)
//                                         ? const Color(0xFFE6C871)
//                                         : Colors.grey[400]!,
//                               ),
//                             ),
//                             onSelected: (selected) {
//                               dialogSetState(() {
//                                 if (selected) {
//                                   _selectedPropertyFacilities.add(id);
//                                 } else {
//                                   _selectedPropertyFacilities.remove(id);
//                                 }
//                               });
//                               setState(() {});
//                             },
//                           );
//                         }).toList(),
//                   ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () {
//                       _propertySearchCityController.clear();
//                       _selectedPropertyFacilities.clear();
//                       dialogSetState(() {});
//                       setState(() {});
//                       Navigator.pop(context);
//                     },
//                     child: const Text(
//                       'Clear',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   ElevatedButton(
//                     onPressed: () {
//                       _fetchProperties();
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFE6C871),
//                       foregroundColor: const Color(0xFF3B5A7A),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Text('Apply'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildRoomFilterDialog() {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextField(
//             controller: _roomPriceController,
//             decoration: InputDecoration(
//               labelText: 'Price',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               filled: true,
//               fillColor: Colors.grey[100],
//               prefixIcon: const Icon(
//                 Icons.attach_money,
//                 color: Color(0xFF3B5A7A),
//               ),
//             ),
//             keyboardType: TextInputType.number,
//           ),
//           const SizedBox(height: 16),
//           TextField(
//             controller: _roomCapacityController,
//             decoration: InputDecoration(
//               labelText: 'Capacity',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               filled: true,
//               fillColor: Colors.grey[100],
//               prefixIcon: const Icon(Icons.people, color: Color(0xFF3B5A7A)),
//             ),
//             keyboardType: TextInputType.number,
//           ),
//           const SizedBox(height: 16),
//           DropdownButtonFormField<String>(
//             value: _roomType,
//             decoration: InputDecoration(
//               labelText: 'Room Type',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               filled: true,
//               fillColor: Colors.grey[100],
//             ),
//             items: const [
//               DropdownMenuItem(value: 'single', child: Text('Single')),
//               DropdownMenuItem(value: 'double', child: Text('Double')),
//               DropdownMenuItem(value: 'shared', child: Text('Shared')),
//             ],
//             onChanged: (value) {
//               setState(() {
//                 _roomType = value;
//               });
//             },
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text(
//                   'Cancel',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               ElevatedButton(
//                 onPressed: () {
//                   _fetchRooms();
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE6C871),
//                   foregroundColor: const Color(0xFF3B5A7A),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text('Apply'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPropertyCard(Map<String, dynamic> property) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//             child: Container(
//               height: 200,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE6C871).withOpacity(0.2),
//                 border: Border.all(color: Colors.grey[200]!),
//               ),
//               child:
//                   property['thumbnail'] != null &&
//                           property['thumbnail'].isNotEmpty
//                       ? Image.network(
//                         property['thumbnail'],
//                         fit: BoxFit.cover,
//                         errorBuilder:
//                             (context, error, stackTrace) => const Center(
//                               child: Icon(
//                                 Icons.home_work,
//                                 size: 64,
//                                 color: Color(0xFFE6C871),
//                               ),
//                             ),
//                       )
//                       : const Center(
//                         child: Icon(
//                           Icons.home_work,
//                           size: 64,
//                           color: Color(0xFFE6C871),
//                         ),
//                       ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         property['title'] ?? 'Property',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF3B5A7A),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             property['is_active'] == true
//                                 ? Colors.green.withOpacity(0.2)
//                                 : Colors.red.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         property['is_active'] == true ? 'Active' : 'Inactive',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color:
//                               property['is_active'] == true
//                                   ? Colors.green[700]
//                                   : Colors.red[700],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         '${property['address'] ?? ''}, ${property['city'] ?? ''}',
//                         style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Icon(Icons.description, size: 16, color: Colors.grey[600]),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         property['description'] ?? 'No description available',
//                         style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRoomCard(Map<String, dynamic> room) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//             child: Container(
//               height: 200,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE6C871).withOpacity(0.2),
//                 border: Border.all(color: Colors.grey[200]!),
//               ),
//               child:
//                   room['thumbnail'] != null && room['thumbnail'].isNotEmpty
//                       ? Image.network(
//                         room['thumbnail'],
//                         fit: BoxFit.cover,
//                         errorBuilder:
//                             (context, error, stackTrace) => const Center(
//                               child: Icon(
//                                 Icons.room,
//                                 size: 64,
//                                 color: Color(0xFFE6C871),
//                               ),
//                             ),
//                       )
//                       : const Center(
//                         child: Icon(
//                           Icons.room,
//                           size: 64,
//                           color: Color(0xFFE6C871),
//                         ),
//                       ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Room ${room['room_number'] ?? 'N/A'}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF3B5A7A),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             room['is_available'] == true
//                                 ? Colors.green.withOpacity(0.2)
//                                 : Colors.red.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         room['is_available'] == true ? 'Available' : 'Occupied',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color:
//                               room['is_available'] == true
//                                   ? Colors.green[700]
//                                   : Colors.red[700],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Icon(Icons.category, size: 16, color: Colors.grey[600]),
//                     const SizedBox(width: 4),
//                     Text(
//                       room['room_type']?.toUpperCase().substring(0, 1) +
//                               room['room_type']?.substring(1) ??
//                           'Standard',
//                       style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                     ),
//                     const SizedBox(width: 16),
//                     Icon(Icons.people, size: 16, color: Colors.grey[600]),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Capacity: ${room['capacity'] ?? 'N/A'}',
//                       style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
//                     Text(
//                       '${room['rent_per_month'] ?? 'N/A'}/month',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF3B5A7A),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();
//   Map<String, dynamic> _userData = {};
//   bool _isLoadingUserData = false;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserProfile();
//   }

//   Future<String?> _loadToken() async {
//     final token = await _storage.read(key: 'access_token');
//     print('📦 ProfilePage - Using access_token: $token');
//     return token;
//   }

//   Future<void> _fetchUserProfile() async {
//     setState(() {
//       _isLoadingUserData = true;
//       _errorMessage = '';
//     });

//     try {
//       final token = await _loadToken();
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/auth/me/'),
//         headers: {
//           'Content-Type': 'application/json',
//           if (token != null) 'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         setState(() {
//           _userData = data;
//           _isLoadingUserData = false;
//         });
//         print('✅ User profile loaded: ${data['username']}');
//       } else {
//         throw Exception(
//           'Failed to load user profile: ${response.statusCode} ${response.reasonPhrase}',
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error loading user profile: $e';
//         _isLoadingUserData = false;
//       });
//       print('❌ Error loading user profile: $e');
//     }
//   }

//   Future<void> _updateUserProfile(String username, String email) async {
//     setState(() {
//       _isLoadingUserData = true;
//       _errorMessage = '';
//     });

//     try {
//       final token = await _loadToken();
//       if (token == null) {
//         throw Exception('No access token available');
//       }

//       final response = await http.patch(
//         Uri.parse('$baseUrl/api/auth/me/'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode({'username': username, 'email': email}),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         await _storage.write(key: 'username', value: username);
//         setState(() {
//           _userData = data;
//           _isLoadingUserData = false;
//         });
//         print('✅ User profile updated: ${data['username']}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Profile updated successfully'),
//             backgroundColor: Color(0xFFE6C871),
//           ),
//         );
//       } else {
//         throw Exception(
//           'Failed to update profile: ${response.statusCode} ${response.reasonPhrase}',
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error updating profile: $e';
//         _isLoadingUserData = false;
//       });
//       print('❌ Error updating profile: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error updating profile: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   void _showEditProfileDialog() {
//     final usernameController = TextEditingController(
//       text: _userData['username'] ?? '',
//     );
//     final emailController = TextEditingController(
//       text: _userData['email'] ?? '',
//     );

//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           backgroundColor: Colors.white,
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Edit Profile',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF3B5A7A),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: usernameController,
//                   decoration: InputDecoration(
//                     labelText: 'Username',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                     prefixIcon: const Icon(
//                       Icons.person,
//                       color: Color(0xFF3B5A7A),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                     prefixIcon: const Icon(
//                       Icons.email,
//                       color: Color(0xFF3B5A7A),
//                     ),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text(
//                         'Cancel',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         _updateUserProfile(
//                           usernameController.text,
//                           emailController.text,
//                         );
//                         Navigator.pop(context);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFE6C871),
//                         foregroundColor: const Color(0xFF3B5A7A),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text('Save'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF3B5A7A),
//         title: const Text(
//           'Profile',
//           style: TextStyle(
//             color: Color(0xFFE6C871),
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFFE6C871)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit, color: Color(0xFFE6C871)),
//             onPressed: _showEditProfileDialog,
//           ),
//         ],
//       ),
//       body:
//           _isLoadingUserData
//               ? const Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE6C871)),
//                 ),
//               )
//               : _errorMessage.isNotEmpty
//               ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.error_outline,
//                       size: 64,
//                       color: Colors.grey[600],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       _errorMessage,
//                       style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: _fetchUserProfile,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFE6C871),
//                         foregroundColor: const Color(0xFF3B5A7A),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               )
//               : _userData.isEmpty
//               ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.person_off_outlined,
//                       size: 64,
//                       color: Colors.grey[600],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No user data available',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Center(
//                       child: CircleAvatar(
//                         radius: 50,
//                         backgroundColor: const Color(
//                           0xFFE6C871,
//                         ).withOpacity(0.2),
//                         child: const Icon(
//                           Icons.person,
//                           size: 60,
//                           color: Color(0xFF3B5A7A),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Profile Information',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF3B5A7A),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             _buildProfileItem(
//                               icon: Icons.person,
//                               label: 'Username',
//                               value: _userData['username'] ?? 'N/A',
//                             ),
//                             const SizedBox(height: 12),
//                             _buildProfileItem(
//                               icon: Icons.email,
//                               label: 'Email',
//                               value: _userData['email'] ?? 'N/A',
//                             ),
//                             const SizedBox(height: 12),
//                             _buildProfileItem(
//                               icon: Icons.admin_panel_settings,
//                               label: 'Role',
//                               value:
//                                   _userData['role']?.toUpperCase().substring(
//                                         0,
//                                         1,
//                                       ) +
//                                       _userData['role']?.substring(1) ??
//                                   'N/A',
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }

//   Widget _buildProfileItem({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, color: const Color(0xFF3B5A7A), size: 24),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Color(0xFF3B5A7A),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hostelive_app/constant.dart';
import 'package:hostelive_app/screen/student_property_detail.dart';
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
  List<dynamic> _sharedFacilities = [];
  bool _isLoadingProperties = false;
  bool _isLoadingRooms = false;
  bool _isLoadingFacilities = false;
  String _errorMessage = '';

  // Analytics data
  Map<String, int> _analyticsData = {
    'totalProperties': 0,
    'activeProperties': 0,
    'totalRooms': 0,
    'availableRooms': 0,
    'singleRooms': 0,
    'doubleRooms': 0,
    'sharedRooms': 0,
  };

  // Property filter controllers
  final _propertySearchCityController = TextEditingController();
  final _propertySearchNameController = TextEditingController();
  List<String> _selectedPropertyFacilities = [];

  // Room filter controllers
  final _roomPriceController = TextEditingController();
  final _roomCapacityController = TextEditingController();
  String? _roomType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
    _fetchSharedFacilities();
    _fetchProperties();
    _fetchRooms();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _propertySearchCityController.dispose();
    _propertySearchNameController.dispose();
    _roomPriceController.dispose();
    _roomCapacityController.dispose();
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

  void _updateAnalytics() {
    setState(() {
      _analyticsData = {
        'totalProperties': _properties.length,
        'activeProperties':
            _properties.where((p) => p['is_active'] == true).length,
        'totalRooms': _rooms.length,
        'availableRooms': _rooms.where((r) => r['is_available'] == true).length,
        'singleRooms':
            _rooms
                .where((r) => r['room_type']?.toLowerCase() == 'single')
                .length,
        'doubleRooms':
            _rooms
                .where((r) => r['room_type']?.toLowerCase() == 'double')
                .length,
        'sharedRooms':
            _rooms
                .where((r) => r['room_type']?.toLowerCase() == 'shared')
                .length,
      };
    });
  }

  Future<void> _fetchSharedFacilities() async {
    setState(() {
      _isLoadingFacilities = true;
      _errorMessage = '';
    });

    try {
      final token = await _loadToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/listings/shared-facilities/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _sharedFacilities = data;
          _isLoadingFacilities = false;
        });
        print('✅ Shared facilities loaded: ${data.length} items');
      } else {
        throw Exception(
          'Failed to load shared facilities: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading shared facilities: $e';
        _isLoadingFacilities = false;
      });
      print('❌ Error loading shared facilities: $e');
    }
  }

  Future<void> _fetchProperties() async {
    setState(() {
      _isLoadingProperties = true;
      _errorMessage = '';
    });

    try {
      final token = await _loadToken();
      final queryParameters = <String, List<String>>{};
      if (_propertySearchCityController.text.isNotEmpty) {
        queryParameters['search_city'] = [_propertySearchCityController.text];
      }
      if (_propertySearchNameController.text.isNotEmpty) {
        queryParameters['search_city'] = [_propertySearchNameController.text];
      }
      if (_selectedPropertyFacilities.isNotEmpty) {
        queryParameters['shared_facilities'] = _selectedPropertyFacilities;
      }

      final uri = Uri.parse('$baseUrl/api/listings/properties/').replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value),
        ),
      );

      print('🔍 Fetching properties with URL: $uri');

      final response = await http.get(
        uri,
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
        _updateAnalytics();
        print('✅ Properties loaded: ${data.length} items');
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
      print('❌ Error loading properties: $e');
    }
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoadingRooms = true;
      _errorMessage = '';
    });

    try {
      final token = await _loadToken();
      final queryParameters = <String, String>{};
      if (_roomType != null) {
        queryParameters['room_type'] = _roomType!.toLowerCase();
      }
      if (_roomPriceController.text.isNotEmpty) {
        queryParameters['rent'] = _roomPriceController.text;
      }
      if (_roomCapacityController.text.isNotEmpty) {
        queryParameters['capacity'] = _roomCapacityController.text;
      }

      final uri = Uri.parse(
        '$baseUrl/api/listings/rooms/',
      ).replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
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
        _updateAnalytics();
        print('✅ Rooms loaded: ${data.length} items');
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
      print('❌ Error loading rooms: $e');
    }
  }

  Future<void> _logout() async {
    await _storage.deleteAll();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    tabs: const [Tab(text: 'Properties'), Tab(text: 'Rooms')],
                    labelColor: const Color(0xFF1A365D),
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: const Color(0xFF1A365D),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      children: [
                        _buildPropertyFilterDialog(),
                        _buildRoomFilterDialog(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A365D),
        elevation: 0,
        title: Text(
          'Welcome, $_username',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _showSearchDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
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
                        Icon(Icons.logout, color: Color(0xFF1A365D)),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(color: Color(0xFF1A365D)),
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
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.home_work), text: 'Properties'),
            Tab(icon: Icon(Icons.room), text: 'Rooms'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAnalyticsTab(),
            _buildPropertiesTab(),
            _buildRoomsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (_isLoadingProperties || _isLoadingRooms) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A365D)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading analytics...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1A365D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A365D), Color(0xFF2D5A87)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your accommodation options at a glance',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Properties Section
          _buildSectionHeader(
            'Properties Analytics',
            Icons.home_work,
            'Tap to explore properties',
            onTap: () => _tabController.animateTo(1),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Properties',
                  _analyticsData['totalProperties'].toString(),
                  Icons.apartment,
                  const Color(0xFF3B82F6),
                  onTap: () => _tabController.animateTo(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  'Active Properties',
                  _analyticsData['activeProperties'].toString(),
                  Icons.check_circle,
                  const Color(0xFF10B981),
                  onTap: () => _tabController.animateTo(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Property Availability Chart
          _buildAvailabilityChart(
            'Property Status',
            _analyticsData['activeProperties']!,
            _analyticsData['totalProperties']! -
                _analyticsData['activeProperties']!,
            'Active',
            'Inactive',
            const Color(0xFF10B981),
            const Color(0xFFEF4444),
            onTap: () => _tabController.animateTo(1),
          ),
          const SizedBox(height: 32),

          // Rooms Section
          _buildSectionHeader(
            'Rooms Analytics',
            Icons.room,
            'Tap to explore rooms',
            onTap: () => _tabController.animateTo(2),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Rooms',
                  _analyticsData['totalRooms'].toString(),
                  Icons.meeting_room,
                  const Color(0xFF8B5CF6),
                  onTap: () => _tabController.animateTo(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  'Available Rooms',
                  _analyticsData['availableRooms'].toString(),
                  Icons.done_all,
                  const Color(0xFF06B6D4),
                  onTap: () => _tabController.animateTo(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Room Types Distribution
          _buildRoomTypesSection(),
          const SizedBox(height: 16),

          // Room Availability Chart
          _buildAvailabilityChart(
            'Room Availability',
            _analyticsData['availableRooms']!,
            _analyticsData['totalRooms']! - _analyticsData['availableRooms']!,
            'Available',
            'Occupied',
            const Color(0xFF06B6D4),
            const Color(0xFFF59E0B),
            onTap: () => _tabController.animateTo(2),
          ),
          const SizedBox(height: 32),

          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A365D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF1A365D), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityChart(
    String title,
    int available,
    int unavailable,
    String availableLabel,
    String unavailableLabel,
    Color availableColor,
    Color unavailableColor, {
    VoidCallback? onTap,
  }) {
    final total = available + unavailable;
    final availablePercentage = total > 0 ? (available / total) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: unavailableColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: availablePercentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: availableColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Legend
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: availableColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$availableLabel: $available',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: unavailableColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$unavailableLabel: $unavailable',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTypesSection() {
    return GestureDetector(
      onTap: () => _tabController.animateTo(2),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Room Types Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRoomTypeItem(
                    'Single',
                    _analyticsData['singleRooms']!,
                    Icons.person,
                    const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRoomTypeItem(
                    'Double',
                    _analyticsData['doubleRooms']!,
                    Icons.people,
                    const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRoomTypeItem(
                    'Shared',
                    _analyticsData['sharedRooms']!,
                    Icons.group,
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTypeItem(
    String type,
    int count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            type,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Search Properties',
                  Icons.search,
                  const Color(0xFF3B82F6),
                  () {
                    _tabController.animateTo(1);
                    _showSearchDialog();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Profile',
                  Icons.person,
                  const Color(0xFF8B5CF6),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesTab() {
    return _isLoadingProperties || _isLoadingFacilities
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
              Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _fetchSharedFacilities();
                  _fetchProperties();
                },
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
        : _properties.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_work_outlined, size: 64, color: Colors.grey[600]),
              const SizedBox(height: 16),
              Text(
                'No properties found',
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
                          initialToken: token,
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
    return _isLoadingRooms
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
        : _rooms.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.room_outlined, size: 64, color: Colors.grey[600]),
              const SizedBox(height: 16),
              Text(
                'No rooms found',
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
          padding: const EdgeInsets.all(16),
          itemCount: _rooms.length,
          itemBuilder: (context, index) {
            final room = _rooms[index];
            return GestureDetector(
              onTap: () async {
                final token = await _loadToken();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            RoomDetailPage(room: room, initialToken: token),
                  ),
                );
              },
              child: _buildRoomCard(room),
            );
          },
        );
  }

  Widget _buildPropertyFilterDialog() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter dialogSetState) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _propertySearchCityController,
                decoration: InputDecoration(
                  labelText: 'City (e.g., Berlin)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  prefixIcon: const Icon(
                    Icons.location_city,
                    color: Color(0xFF1A365D),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF1A365D)),
                    onPressed: () {
                      _propertySearchCityController.clear();
                      dialogSetState(() {});
                    },
                  ),
                ),
                onChanged: (_) => dialogSetState(() {}),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _propertySearchNameController,
                decoration: InputDecoration(
                  labelText: 'Name (e.g., Hostel Hive)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  prefixIcon: const Icon(
                    Icons.home_work,
                    color: Color(0xFF1A365D),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF1A365D)),
                    onPressed: () {
                      _propertySearchNameController.clear();
                      dialogSetState(() {});
                    },
                  ),
                ),
                onChanged: (_) => dialogSetState(() {}),
              ),
              const SizedBox(height: 16),
              const Text(
                'Shared Facilities',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A365D),
                ),
              ),
              const SizedBox(height: 8),
              _isLoadingFacilities
                  ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF1A365D),
                      ),
                    ),
                  )
                  : _sharedFacilities.isEmpty
                  ? const Text(
                    'No facilities available',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  )
                  : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _sharedFacilities.map((facility) {
                          final id = facility['id'].toString();
                          final name = facility['name'] ?? 'Facility $id';
                          return ChoiceChip(
                            label: Text(name),
                            selected: _selectedPropertyFacilities.contains(id),
                            selectedColor: const Color(
                              0xFF1A365D,
                            ).withOpacity(0.3),
                            backgroundColor: Colors.grey.shade100,
                            labelStyle: TextStyle(
                              color:
                                  _selectedPropertyFacilities.contains(id)
                                      ? const Color(0xFF1A365D)
                                      : Colors.grey[600],
                              fontWeight:
                                  _selectedPropertyFacilities.contains(id)
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color:
                                    _selectedPropertyFacilities.contains(id)
                                        ? const Color(0xFF1A365D)
                                        : Colors.grey[400]!,
                              ),
                            ),
                            onSelected: (selected) {
                              dialogSetState(() {
                                if (selected) {
                                  _selectedPropertyFacilities.add(id);
                                } else {
                                  _selectedPropertyFacilities.remove(id);
                                }
                              });
                              setState(() {});
                            },
                          );
                        }).toList(),
                  ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _propertySearchCityController.clear();
                      _propertySearchNameController.clear();
                      _selectedPropertyFacilities.clear();
                      dialogSetState(() {});
                      setState(() {});
                      _fetchProperties();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _fetchProperties();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A365D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoomFilterDialog() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter dialogSetState) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _roomPriceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  prefixIcon: const Icon(
                    Icons.attach_money,
                    color: Color(0xFF1A365D),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF1A365D)),
                    onPressed: () {
                      _roomPriceController.clear();
                      dialogSetState(() {});
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => dialogSetState(() {}),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _roomCapacityController,
                decoration: InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  prefixIcon: const Icon(
                    Icons.people,
                    color: Color(0xFF1A365D),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF1A365D)),
                    onPressed: () {
                      _roomCapacityController.clear();
                      dialogSetState(() {});
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => dialogSetState(() {}),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _roomType,
                decoration: InputDecoration(
                  labelText: 'Room Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                items: const [
                  DropdownMenuItem(value: 'single', child: Text('Single')),
                  DropdownMenuItem(value: 'double', child: Text('Double')),
                  DropdownMenuItem(value: 'shared', child: Text('Shared')),
                ],
                onChanged: (value) {
                  dialogSetState(() {
                    _roomType = value;
                  });
                  setState(() {
                    _roomType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _roomPriceController.clear();
                      _roomCapacityController.clear();
                      _roomType = null;
                      dialogSetState(() {});
                      setState(() {});
                      _fetchRooms();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                      _fetchRooms();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A365D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child:
                  property['thumbnail'] != null &&
                          property['thumbnail'].isNotEmpty
                      ? Image.network(
                        property['thumbnail'],
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Center(
                              child: Icon(
                                Icons.home_work,
                                size: 64,
                                color: Color(0xFF1A365D),
                              ),
                            ),
                      )
                      : const Center(
                        child: Icon(
                          Icons.home_work,
                          size: 64,
                          color: Color(0xFF1A365D),
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
                    Expanded(
                      child: Text(
                        property['title'] ?? 'Property',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A365D),
                        ),
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
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        property['is_active'] == true ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              property['is_active'] == true
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
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
    final images = room['images_detail'] as List<dynamic>? ?? [];
    final pageController = PageController();
    int currentPage = 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  images.isNotEmpty
                      ? PageView.builder(
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
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Image.network(
                              image['image'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
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
                            margin: const EdgeInsets.symmetric(horizontal: 4),
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
                        color: Color(0xFF1A365D),
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
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        room['is_available'] == true ? 'Available' : 'Occupied',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              room['is_available'] == true
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
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
                      room['room_type']?.toUpperCase().substring(0, 1) +
                              room['room_type']?.substring(1) ??
                          'Standard',
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
                        color: Color(0xFF1A365D),
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
