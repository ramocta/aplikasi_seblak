import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationItemCard extends StatelessWidget {
  final dynamic item;
  final String time;
  final bool isStockAlert;
  final Color primaryOrange;

  const NotificationItemCard({
    super.key,
    required this.item,
    required this.time,
    required this.isStockAlert,
    required this.primaryOrange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          if (!isStockAlert) {
            context.push('/order_detail', extra: item['raw_data']);
          } else {
            context.push('/menu');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isStockAlert ? Colors.red.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isStockAlert ? Colors.red.shade200 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: isStockAlert
                    ? Colors.red.withOpacity(0.1)
                    : primaryOrange.withOpacity(0.1),
                child: Icon(
                  isStockAlert
                      ? Icons.warning_amber_rounded
                      : Icons.shopping_bag_outlined,
                  color: isStockAlert ? Colors.red : primaryOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['title'] ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isStockAlert ? Colors.red : primaryOrange,
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isStockAlert
                          ? "Menu [ ${item['name']} ] is running low! Remaining stock: ${item['stok']}"
                          : item['name'] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (!isStockAlert) ...[
                      const SizedBox(height: 2),
                      Text(
                        "Click to update status & process in kitchen",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

