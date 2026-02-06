// import 'package:flutter/material.dart';

// /// EditLoungePage - Form screen for editing existing lounge details
// ///
// /// This page allows lounge owners/admins to modify lounge information including:
// /// - Basic information (name, description, capacity, pricing)
// /// - Facility selection (Wi-Fi, A/C, Cafeteria, etc.)
// /// - Photo gallery management
// ///
// /// Features:
// /// - Input validation for all fields
// /// - Checkbox list for facility selection
// /// - Photo upload interface
// /// - Photo tips and guidelines
// /// - Updates navigate to lounge list screen
// class EditLoungePage extends StatefulWidget {
//   const EditLoungePage({super.key});

//   @override
//   State<EditLoungePage> createState() => _EditLoungePageState();
// }

// class _EditLoungePageState extends State<EditLoungePage> {
//   // ==============================================================================
//   // FORM CONTROLLERS - Text field controllers for form inputs
//   // ==============================================================================
//   final _nameController = TextEditingController();
//   final _descController = TextEditingController();
//   final _capacityController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _facilitiesController = TextEditingController();

//   // ==============================================================================
//   // FACILITIES DATA - Available amenities and their selection state
//   // ==============================================================================
//   /// List of all available facilities that can be selected for the lounge
//   final List<String> _facilities = [
//     "Wi-Fi",
//     "A/C",
//     "Cafeteria",
//     "Charging Ports",
//     "Entertainment",
//     "Parking",
//     "Rest Rooms",
//     "Waiting Area",
//   ];

//   /// Map tracking which facilities are currently selected (true) or not (false)
//   final Map<String, bool> _selectedFacilities = {};

//   @override
//   void initState() {
//     super.initState();
//     // Initialize all facilities as unselected
//     for (var f in _facilities) {
//       _selectedFacilities[f] = false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFFBF5),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Edit Lounge",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Section: Basic Info
//             const Text(
//               "Basic Information",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             _buildInputField(Icons.storefront, "Lounge Name", _nameController),
//             _buildInputField(Icons.description, "Description", _descController),
//             _buildInputField(Icons.people, "Capacity", _capacityController),
//             _buildInputField(
//               Icons.attach_money,
//               "Price per Hour",
//               _priceController,
//             ),
//             _buildInputField(
//               Icons.business_center,
//               "Facilities",
//               _facilitiesController,
//             ),

//             const SizedBox(height: 16),
//             // Section: Facilities
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: _facilities.map((facility) {
//                 return CheckboxListTile(
//                   title: Text(facility),
//                   activeColor: Colors.orange,
//                   value: _selectedFacilities[facility],
//                   onChanged: (bool? value) {
//                     setState(() {
//                       _selectedFacilities[facility] = value ?? false;
//                     });
//                   },
//                   controlAffinity: ListTileControlAffinity.leading,
//                   contentPadding: EdgeInsets.zero,
//                 );
//               }).toList(),
//             ),

//             const SizedBox(height: 16),

//             // Photos Section
//             const Text(
//               "Photos and Gallery",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             const Text(
//               "Show off your lounge with great pictures",
//               style: TextStyle(fontSize: 13, color: Colors.grey),
//             ),
//             const SizedBox(height: 12),

//             // Add photo button
//             GestureDetector(
//               onTap: () {},
//               child: Container(
//                 height: 110,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade50,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.orange.shade200),
//                 ),
//                 child: const Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.add_photo_alternate_outlined,
//                         color: Colors.orange,
//                         size: 30,
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         "Add photos",
//                         style: TextStyle(color: Colors.orange),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Photo Tips Box
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.orange.shade50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.orange.shade100),
//               ),
//               child: const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "📸 Photo Tips",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.orange,
//                     ),
//                   ),
//                   SizedBox(height: 6),
//                   Text("• Include interior and exterior shots."),
//                   Text("• Ensure good lighting and cleanliness."),
//                   Text("• Minimum 3 high-quality photos recommended."),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 30),

//             // Update Button
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Lounge updated successfully!"),
//                     ),
//                   );
//                   // Navigate to lounge list screen
//                   Navigator.pushNamed(context, '/lounge/list');
//                 },
//                 child: const Text(
//                   "Update",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Custom Input Field Widget
//   Widget _buildInputField(
//     IconData icon,
//     String hint,
//     TextEditingController controller,
//   ) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon, color: Colors.orange),
//           hintText: hint,
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: 14,
//             horizontal: 12,
//           ),
//         ),
//       ),
//     );
//   }
// }
