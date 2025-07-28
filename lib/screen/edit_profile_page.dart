import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String username;
  final String imageUrl;
  final dynamic points;
  final dynamic bPoints;
  final String role;
  final String dept;

  const EditProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.username,
    required this.imageUrl,
    required this.points,
    required this.bPoints,
    required this.role,
    required this.dept,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  String? _selectedRole;
  String? _selectedDept;

  Future<void> saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final docRef =
        FirebaseFirestore.instance.collection('Client').doc(user.uid);

    Map<String, dynamic> updatedData = {};

    if (_usernameController.text.trim().isNotEmpty &&
        _usernameController.text.trim() != widget.username) {
      updatedData['username'] = _usernameController.text.trim();
    }

    if (_nameController.text.trim().isNotEmpty &&
        _nameController.text.trim() != widget.name) {
      updatedData['name'] = _nameController.text.trim();
    }

    if (_emailController.text.trim().isNotEmpty &&
        _emailController.text.trim() != widget.email) {
      updatedData['email'] = _emailController.text.trim();
    }

    if (_selectedRole != null) {
      updatedData['role'] = _selectedRole;
    }

    // check if department is entered

    if (_selectedDept != null) {
      updatedData['department'] = _selectedDept;
    }
    if (updatedData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No changes made")),
      );
      return;
    }

    try {
      await docRef.update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );

      Navigator.pop(context); // go back to profile page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Widget readOnlyTextField({required String label, required String value}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight / 76.6), //10
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: value,
          fillColor: Theme.of(context).colorScheme.onSurface,
          border: OutlineInputBorder(),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  Widget dropDownMenu({
    required List<DropdownMenuItem<String>>? item,
    required String? value,
    required void Function(String?)? onChanged,
    required String? label,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: false,
      items: item,
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(15),
      dropdownColor: Theme.of(context).colorScheme.onPrimary,
      decoration: InputDecoration(
          fillColor: Theme.of(context).colorScheme.onPrimary,
          labelStyle:
              TextStyle(color: Theme.of(context).colorScheme.onSecondary),
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.onSurface)),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onTertiary,
                    borderRadius: BorderRadius.circular(6)),
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth / 45,
                    vertical: screenHeight / 95.75), //8
                child: Text('Cancel',
                    style: GoogleFonts.lato(
                        fontSize: screenWidth / 22.5, //16
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(width: screenWidth / 72), //5
            const Text("Edit Profile"),
            SizedBox(width: screenWidth / 72), // 5
            GestureDetector(
              onTap: () {
                // Save action
                saveChanges();
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onTertiary,
                    borderRadius: BorderRadius.circular(6)),
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth / 45,
                    vertical: screenHeight / 95.75), //8
                child: Text('Save',
                    style: GoogleFonts.lato(
                        fontSize: screenWidth / 22.5, //16
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth / 22.5), //16
        child: Column(
          children: [
            // Circle Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: widget.imageUrl.isNotEmpty
                      ? NetworkImage(widget.imageUrl)
                      : const AssetImage('assets/default_photo.jpg')
                          as ImageProvider,
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Icon(Icons.edit,
                        color: Colors.white, size: screenWidth / 20), //18
                  ),
                )
              ],
            ),
            SizedBox(height: screenHeight / 25.53), //30

            // TextFields
            _buildTextField(
              label: 'Username',
              hint: widget.username,
              controller: _usernameController,
            ),
            SizedBox(height: screenHeight / 38), //20
            _buildTextField(
              label: 'Name',
              hint: widget.name,
              controller: _nameController,
            ),
            SizedBox(height: screenHeight / 38), //20
            _buildTextField(
              label: 'Email',
              hint: widget.email,
              controller: _emailController,
            ),

            SizedBox(height: screenHeight / 38), //20
            readOnlyTextField(
                label: "Points Earned", value: widget.points.toString()),
            SizedBox(height: screenHeight / 38), //20
            readOnlyTextField(
                label: "Bonus Points", value: widget.bPoints.toString()),
            SizedBox(height: screenHeight / 38), //20
            dropDownMenu(
              label: 'Change Department',
              item: [
                "HRA",
                "ITIS",
                "CPS",
                "R&C",
                "FMC",
                "CS",
                "EG&DED",
                "R&D",
                "DLCD",
                "CC&MR",
                "SMP",
                "A&IC",
              ]
                  .map((department) => DropdownMenuItem<String>(
                        value: department,
                        child: Container(
                            width: screenWidth / 3, //120
                            child: Text(
                              department,
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            )),
                      ))
                  .toList(),
              value: _selectedDept,
              onChanged: (value) {
                setState(() {
                  _selectedDept = value;
                });
              },
            ),

            SizedBox(height: screenHeight / 38), //20

            dropDownMenu(
              label: 'Change Role',
              item: ["General Staff", "Supervisor", "Manager", "CEO"]
                  .map((role) => DropdownMenuItem<String>(
                        value: role,
                        child: Container(
                            width: screenWidth / 3, //120
                            child: Text(
                              role,
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            )),
                      ))
                  .toList(),
              value: _selectedRole,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.lato(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
