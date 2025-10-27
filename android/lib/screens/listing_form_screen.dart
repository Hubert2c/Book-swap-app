// lib/screens/listing_form_screen.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';

class ListingFormScreen extends StatefulWidget {
  const ListingFormScreen({Key? key}) : super(key: key);

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestore = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _editionController = TextEditingController();
  final _conditionController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isSaving = false;
  List<File> _selectedImages = [];

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages = images.map((img) => File(img.path)).toList();
      });
    }
  }

  Future<List<String>> _uploadImages(String bookId) async {
    List<String> downloadUrls = [];
    for (File image in _selectedImages) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('book_images/$bookId/$fileName');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      downloadUrls.add(url);
    }
    return downloadUrls;
  }

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please log in first.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final docRef = FirebaseFirestore.instance.collection('books').doc();
      final bookId = docRef.id;

      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _uploadImages(bookId);
      }

      final newBook = Book(
        id: bookId,
        title: _titleController.text.trim(),
        authors: _authorController.text.trim().split(','),
        edition: _editionController.text.trim(),
        condition: _conditionController.text.trim(),
        description: _descriptionController.text.trim(),
        images: imageUrls,
        ownerId: user.uid,
        timestamp: DateTime.now(),
      );

      await _firestore.createBook(newBook);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book listed successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _editionController.dispose();
    _conditionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book Listing'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_titleController, 'Book Title', 'Enter book title'),
              _buildTextField(_authorController, 'Author(s)', 'Enter authors, separated by commas'),
              _buildTextField(_editionController, 'Edition', 'e.g. 3rd Edition'),
              _buildTextField(_conditionController, 'Condition', 'e.g. Like New, Good, Used'),
              _buildTextField(
                _descriptionController,
                'Description',
                'Enter a brief description...',
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              const Text(
                'Book Images',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _selectedImages.isEmpty
                  ? TextButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.image),
                      label: const Text('Select Images'),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.file(
                                _selectedImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _pickImages,
                          child: const Text('Change Images'),
                        ),
                      ],
                    ),
              const SizedBox(height: 30),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save Listing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: _saveListing,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
        maxLines: maxLines,
      ),
    );
  }
}
