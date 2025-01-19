import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  final Function(Map<String, String>) onProductAdded;

  const AddProductPage({super.key, required this.onProductAdded});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _linkController = TextEditingController();
  final _itemCodeController = TextEditingController();

  File? _selectedImage; // Variable to hold the selected image

  final ImagePicker _picker = ImagePicker(); // Image picker instance

  // Function to pick an image
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // Set the selected image
      });
    }
  }

  void _submitForm() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload an image")),
      );
      return;
    }

    // Create a map of the product details
    final newProduct = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'imageUrl': _selectedImage!.path, // Store the image file path
      'price': _priceController.text,
      'salePrice': _salePriceController.text,
      'link': _linkController.text,
      'itemCode': _itemCodeController.text,
    };

    // Call the callback function passed from the catalog page
    widget.onProductAdded(newProduct);

    // Navigate back to the catalog page
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: const Text('Add New Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Upload Button
            _selectedImage == null
                ? GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Upload Image',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            // Product Name Input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration:
                  const InputDecoration(labelText: 'Product Description'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            TextField(
              controller: _salePriceController,
              decoration: const InputDecoration(labelText: 'Sale Price'),
            ),
            TextField(
              controller: _linkController,
              decoration: const InputDecoration(labelText: 'Product Link'),
            ),
            TextField(
              controller: _itemCodeController,
              decoration: const InputDecoration(labelText: 'Item Code'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
