import 'package:flutter/material.dart';

class AddMenuFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final int? selectedCategoryId;
  final Map<String, int> categoriesMap;
  final ValueChanged<int?> onChangedCategory;

  final FormFieldValidator<String?> nameValidator;
  final FormFieldValidator<String?> stockValidator;
  final FormFieldValidator<String?> priceValidator;

  const AddMenuFormFields({
    super.key,
    required this.nameController,
    required this.priceController,
    required this.stockController,
    required this.selectedCategoryId,
    required this.categoriesMap,
    required this.onChangedCategory,
    required this.nameValidator,
    required this.stockValidator,
    required this.priceValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildLabel('Menu Name'),
        TextFormField(
          controller: nameController,
          decoration: _inputDecoration(hint: 'Enter the menu name'),
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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: categoriesMap.values.contains(selectedCategoryId)
                            ? selectedCategoryId
                            : categoriesMap.values.first,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey.shade600,
                        ),
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                        onChanged: onChangedCategory,
                        items: categoriesMap.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.value,
                                child: Text(e.key),
                              ),
                            )
                            .toList(),
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
                  TextFormField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: '0'),
                    validator: stockValidator,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        _buildLabel('Price (Rp)'),
        TextFormField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(hint: 'Rp  0'),
          validator: priceValidator,
        ),
        const SizedBox(height: 44),
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

  InputDecoration _inputDecoration({required String hint}) => InputDecoration(
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
      );
}

