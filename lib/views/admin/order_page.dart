import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Filter
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildFilterTab("All Orders", true),
              _buildFilterTab("Pending", false),
              _buildFilterTab("Completed", false),
            ],
          ),
        ),
        
        // Daftar Pesanan
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              _buildOrderCard(
                context,
                orderId: "8821",
                name: "Budi Setiawan",
                items: "Seblak - Level 5, Extra Ceker, Bakso Mercon",
                time: "Today, 14:20",
                price: "Rp 45.000",
                status: "Pending",
                statusColor: Colors.orange[50]!,
                statusTextColor: Colors.orange,
                isPending: true,
              ),
              const SizedBox(height: 16),
              _buildOrderCard(
                context,
                orderId: "8819",
                name: "Siti Aminah",
                items: "Seblak - Level 2, Sosis, Telur Puyuh",
                time: "Today, 13:45",
                price: "Rp 32.000",
                status: "Completed",
                statusColor: Colors.green[50]!,
                statusTextColor: Colors.green,
                isPending: false,
              ),
              const SizedBox(height: 16),
              _buildOrderCard(
                context,
                orderId: "8822",
                name: "Andi Pratama",
                items: "Seblak - Level 2, Ekstra Keju Mozzarella",
                time: "Today, 14:45",
                price: "Rp 28.500",
                status: "Pending",
                statusColor: Colors.orange[50]!,
                statusTextColor: Colors.orange,
                isPending: true,
              ),
              const SizedBox(height: 80), // Padding bawah agar tidak tertutup FAB
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(String label, bool isActive) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.deepOrange : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label, 
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[600], 
              fontWeight: FontWeight.bold
            )
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context, {
    required String orderId, 
    required String name, 
    required String items,
    required String time, 
    required String price, 
    required String status,
    required Color statusColor, 
    required Color statusTextColor, 
    required bool isPending,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending ? Colors.deepOrange : Colors.grey[200]!, 
          width: isPending ? 1.5 : 1
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("#ORD-$orderId", style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                child: Text(status, style: TextStyle(color: statusTextColor, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("Items:", style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text(items, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: const TextStyle(color: Colors.grey)),
              Text(price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isPending ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPending ? Colors.deepOrange : Colors.white,
                    disabledBackgroundColor: Colors.white,
                    elevation: 0,
                    side: isPending ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    isPending ? "Complete Order" : "Completed",
                    style: TextStyle(color: isPending ? Colors.white : Colors.grey[400]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/order_detail');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Detail", style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}