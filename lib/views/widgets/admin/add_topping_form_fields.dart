import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AddToppingFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final int? selectedCategoryId;
  final List<dynamic> categories;
  final ValueChanged<int?> onChangedCategoryId;

  final FormFieldValidator<String?> nameValidator;

  const AddToppingFormFields({
    super.key,
    required this.nameController,
    required this.priceController,
    required this.stockController,
    required this.selectedCategoryId,
    required this.categories,
    required this.onChangedCategoryId,
    required this.nameValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Topping Name'),
        _buildTextField(
          controller: nameController,
          hint: 'Example: Cheese Dumpling',
          keyboardType: TextInputType.text,
          validator: nameValidator,
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Category'),
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: categories.isEmpty
                        ? const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Empty',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedCategoryId,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey.shade600,
                              ),
                              style: const TextStyle(color: Colors.black87, fontSize: 15),
                              onChanged: onChangedCategoryId,
                              items: categories.map((cat) {
                                return DropdownMenuItem<int>(
                                  value: cat.id as int,
                                  child: Text(cat.nama),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Stock'),
                  _buildTextField(
                    controller: stockController,
                    hint: '100',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Stok wajib diisi' : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildLabel('Price (Rp)'),
        _buildTextField(
          controller: priceController,
          hint: '2000',
          keyboardType: TextInputType.number,
          validator: (v) => v!.isEmpty ? 'Harga wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFF1F3F4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE64A19), width: 1.5),
        ),
      ),
    );
  }
}

