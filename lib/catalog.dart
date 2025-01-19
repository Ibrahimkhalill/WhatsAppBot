import 'package:flutter/material.dart';
import 'package:whatapp/prodcut_page.dart';

class Catalog extends StatefulWidget {
  const Catalog({super.key});

  @override
  _CatalogState createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
  List<Map<String, String>> products = [];

  // Function to add a new product to the list
  void addProduct(Map<String, String> newProduct) {
    setState(() {
      products.add(newProduct);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: const Text('Product Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to the AddProductPage when the 'Add' button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddProductPage(onProductAdded: addProduct),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductItem(
            product['name']!,
            product['description']!,
            product['imageUrl']!,
            product['price']!,
            product['salePrice']!,
            product['link']!,
            product['itemCode']!,
          );
        },
      ),
    );
  }

  // Helper function to build product item
  Widget _buildProductItem(
      String productName,
      String productDescription,
      String imageUrl,
      String price,
      String salePrice,
      String productLink,
      String itemCode) {
    return GestureDetector(
      onTap: () {
        // Action when product is tapped
        print('Product tapped: $productName');
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the product image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              // Display product name
              Text(
                productName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              // Display product description
              Text(
                productDescription,
                style: const TextStyle(color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis, // Prevent overflow
              ),
              const SizedBox(height: 10),
              // Display price and sale price
              Row(
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    salePrice,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        decoration: TextDecoration.lineThrough),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Display product link
              Row(
                children: [
                  const Icon(
                    Icons.link,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 5),
                  TextButton(
                    onPressed: () {
                      print('Go to product link');
                    },
                    child: Text(
                      'View Product',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Display item code
              Row(
                children: [
                  const Icon(
                    Icons.code,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Item Code: $itemCode',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Chat button to send product details (like WhatsApp)
              IconButton(
                icon: const Icon(Icons.chat, color: Colors.green),
                onPressed: () {
                  print('Send product details to chat');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
