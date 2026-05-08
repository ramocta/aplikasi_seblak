import 'package:flutter/material.dart';

class EditSemuaMenu extends StatefulWidget {
  const EditSemuaMenu({super.key});

  @override
  State<EditSemuaMenu> createState() => _EditSemuaMenuState();
}

class _EditSemuaMenuState extends State<EditSemuaMenu> {
  Widget inputField(String title, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              hint,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // APPBAR
              Row(
                children: const [
                  Icon(Icons.arrow_back),
                  SizedBox(width: 12),
                  Text(
                    "Edit Menu",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // IMAGE
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F4),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.photo_camera,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              inputField("Product Name", "Seblak Level 1"),
              inputField("Category", "Seblak"),
              inputField("Stock", "50"),
              inputField("Price (IDR)", "Rp 25000"),
              inputField("Product Description", "Add your toppings"),

              const SizedBox(height: 20),

              // BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDE3905),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}