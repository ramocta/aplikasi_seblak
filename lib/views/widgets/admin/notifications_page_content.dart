import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'notification_item_card.dart';
import 'notifications_time_util.dart';

class NotificationsPageContent extends StatelessWidget {
  final RxBool isOrdersLoading;
  final RxBool isStockLoading;
  final String activeTab;
  final List<dynamic> items;
  final Color primaryOrange;

  final ValueSetter<String> onTabChanged;

  const NotificationsPageContent({
    super.key,
    required this.isOrdersLoading,
    required this.isStockLoading,
    required this.activeTab,
    required this.items,
    required this.primaryOrange,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- TAB SELECTOR ---
        Padding(
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
        ),

        // --- NOTIFICATION LIST WITH GETX REACTIVE OBS ---
        Expanded(
          child: Obx(() {
            if (isOrdersLoading.value || isStockLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              );
            }

            if (items.isEmpty) {
              return const Center(
                child: Text(
                  'No notifications available.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isStockAlert = item['type'] == 'stock_alert';
                final time = NotificationsTimeUtil.formatNotificationTime(
                  item['created_at'].toString(),
                );

                return NotificationItemCard(
                  item: item,
                  time: time,
                  isStockAlert: isStockAlert,
                  primaryOrange: primaryOrange,
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

