import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'notification_item_card.dart';
import 'notifications_time_util.dart';

class NotificationsList extends StatelessWidget {
  final RxBool isOrdersLoading;
  final RxBool isStockLoading;
  final List<dynamic> items;
  final Color primaryOrange;

  const NotificationsList({
    super.key,
    required this.isOrdersLoading,
    required this.isStockLoading,
    required this.items,
    required this.primaryOrange,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (isOrdersLoading.value || isStockLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: primaryOrange),
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
    );
  }
}

