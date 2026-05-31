import 'package:flutter/material.dart';

class OrderFilterBar extends StatelessWidget {
  final String activeStatus;
  final ValueChanged<String> onChanged;

  const OrderFilterBar({
    super.key,
    required this.activeStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          _buildFilterButton(context, "All Orders", "all"),
          const SizedBox(width: 8),
          _buildFilterButton(context, "Pending", "pending"),
          const SizedBox(width: 8),
          _buildFilterButton(context, "Done", "done"),
          const SizedBox(width: 8),
          _buildFilterButton(context, "Reject", "reject"),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    String label,
    String statusKey,
  ) {
    bool isSelected = activeStatus == statusKey;

    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? const Color(0xFFE64A19) : const Color(0xFFF5F5F5),
          foregroundColor: isSelected ? Colors.white : Colors.black54,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        ),
        onPressed: () {
          onChanged(statusKey);
        },
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

