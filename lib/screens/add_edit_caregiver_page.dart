import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../services/database_service.dart';
import '../models/caregiver_model.dart';

class AddEditCaregiverPage extends StatefulWidget {
  final Caregiver? caregiver;

  const AddEditCaregiverPage({super.key, this.caregiver});

  @override
  _AddEditCaregiverPageState createState() => _AddEditCaregiverPageState();
}

class _AddEditCaregiverPageState extends State<AddEditCaregiverPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _qualificationsController;
  late TextEditingController _experienceController;
  File? _image;
  String? _imageUrl;
  bool _isLoading = false;
  bool get _isEditMode => widget.caregiver != null;

  final StorageService _storageService = StorageService();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    final caregiver = widget.caregiver;

    _nameController = TextEditingController(text: caregiver?.name ?? '');
    _emailController = TextEditingController(text: caregiver?.email ?? '');
    _phoneController = TextEditingController(text: caregiver?.phone ?? '');
    _qualificationsController = TextEditingController(text: caregiver?.qualifications ?? '');
    _experienceController = TextEditingController(text: caregiver?.experience.toString() ?? '');
    _imageUrl = caregiver?.profilePictureUrl;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveCaregiver() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String profilePictureUrl = _imageUrl ?? '';
        String caregiverId = _isEditMode ? widget.caregiver!.id : DateTime.now().millisecondsSinceEpoch.toString();

        if (_image != null) {
          profilePictureUrl = await _storageService.uploadProfilePicture(caregiverId, _image!);
        }

        final caregiver = Caregiver(
          id: caregiverId,
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          certifications: '',
          qualifications: _qualificationsController.text,
          experience: int.tryParse(_experienceController.text) ?? 0,
          profilePictureUrl: profilePictureUrl,
        );

        if (_isEditMode) {
          await _databaseService.updateCaregiver(caregiver);
        } else {
          await _databaseService.addCaregiver(caregiver);
        }

        Get.back();
        Get.snackbar(
          'Success',
          'Caregiver details saved successfully.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar('Error', 'Failed to save caregiver: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qualificationsController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Caregiver' : 'Add Caregiver'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (_imageUrl != null && _imageUrl!.isNotEmpty
                                ? NetworkImage(_imageUrl!)
                                : null) as ImageProvider?,
                        child: _image == null && (_imageUrl == null || _imageUrl!.isEmpty)
                            ? const Icon(Icons.add_a_photo, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
                    ),
                    TextFormField(
                      controller: _qualificationsController,
                      decoration: const InputDecoration(labelText: 'Qualifications'),
                      validator: (value) => value!.isEmpty ? 'Please enter qualifications' : null,
                    ),
                    TextFormField(
                      controller: _experienceController,
                      decoration: const InputDecoration(labelText: 'Experience (Years)'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Please enter years of experience' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveCaregiver,
                      child: const Text('Save Caregiver'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
