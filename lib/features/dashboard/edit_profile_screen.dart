import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late String _selectedAvatar;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.name);
    _selectedAvatar = userProvider.avatar;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _selectedAvatar = 'custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text("SAVE", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAvatarPicker(),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.image_search_rounded),
              label: const Text("CHOOSE FROM GALLERY"),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Farmer Name",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    final avatars = [
      {'id': 'person', 'icon': Icons.person},
      {'id': 'nature', 'icon': Icons.nature_people},
      {'id': 'agriculture', 'icon': Icons.agriculture},
      {'id': 'eco', 'icon': Icons.eco},
    ];

    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          backgroundImage: _selectedAvatar == 'custom' 
              ? (_imageFile != null 
                  ? FileImage(_imageFile!) 
                  : (userProvider.customAvatarPath != null 
                      ? FileImage(File(userProvider.customAvatarPath!)) 
                      : null))
              : null,
          child: _selectedAvatar == 'custom' && (_imageFile != null || userProvider.customAvatarPath != null)
              ? null 
              : Icon(
                  avatars.firstWhere((a) => a['id'] == _selectedAvatar, orElse: () => avatars[0])['icon'] as IconData,
                  size: 70,
                  color: Colors.green,
                ),
        ),
        const SizedBox(height: 20),
        const Text("Choose Avatar", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: avatars.map((avatar) {
            bool isSelected = _selectedAvatar == avatar['id'];
            return GestureDetector(
              onTap: () => setState(() => _selectedAvatar = avatar['id'] as String),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  avatar['icon'] as IconData,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _saveProfile() async {
    if (_nameController.text.trim().isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.updateProfile(
      _nameController.text.trim(),
      _selectedAvatar,
      customAvatarPath: _imageFile?.path,
    );
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
