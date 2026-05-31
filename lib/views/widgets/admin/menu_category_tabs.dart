import 'package:flutter/material.dart';

class MenuCategoryTabs extends StatelessWidget {
  final List<dynamic> categories;
  final int selectedCategoryId;
  final ValueChanged<int> onTap;

  const MenuCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: categories.map((cat) {
            final int id = cat.id as int;
            final String label = cat.nama as String;
            final bool isActive = selectedCategoryId == id;

            return _buildCategoryTab(
              label: label,
              id: id,
              isActive: isActive,
              onTap: () => onTap(id),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryTab({
    required String label,
    required int id,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE64A19) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

