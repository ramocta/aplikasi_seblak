import 'package:flutter/material.dart';

class EditMenuFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final int? selectedCategoryId;
  final Map<String, int> categoriesMap;
  final ValueChanged<int?> onChangedCategory;

  final FormFieldValidator<String?> nameValidator;
  final FormFieldValidator<String?> stockValidator;
  final FormFieldValidator<String?> priceValidator;

  const EditMenuFormFields({
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
        const SizedBox(height: 20),
        _buildLabel("Nama Produk"),
        TextFormField(
          controller: nameController,
          decoration: _inputDecoration(),
          validator: nameValidator,
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Kategori"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: categoriesMap.values.contains(selectedCategoryId)
                            ? selectedCategoryId
                            : categoriesMap.values.first,
                        isExpanded: true,
                        onChanged: (val) => onChangedCategory(val),
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
                  _buildLabel("Stok"),
                  TextFormField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(),
                    validator: stockValidator,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildLabel("Harga (IDR)"),
        TextFormField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration().copyWith(prefixText: 'Rp '),
          validator: priceValidator,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      );

  InputDecoration _inputDecoration() => InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFE64A19), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      );
}

