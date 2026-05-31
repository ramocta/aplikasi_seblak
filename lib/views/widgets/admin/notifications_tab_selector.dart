import 'package:flutter/material.dart';

class NotificationsTabSelector extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;
  final Color primaryOrange;

  const NotificationsTabSelector({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    required this.primaryOrange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['All', 'Orders', 'Stock'].map((tab) {
          final isActive = activeTab == tab;
          return GestureDetector(
            onTap: () => onTabChanged(tab),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? primaryOrange : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tab == 'Stock' ? 'Low Stock' : tab,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

