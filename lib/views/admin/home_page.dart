import 'package:flutter/material.dart';
import 'kelola_menu_seblak.dart';
import 'kelola_menu_mie.dart';
import 'kelola_menu_minuman.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: const Color(0xFFDE3905),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔥 Revenue
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDE3905),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Revenue",
                      style: TextStyle(color: Colors.white)),
                  SizedBox(height: 8),
                  Text("Rp 2.450.000",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 📊 Stats
            Row(
              children: [
                Expanded(child: _statCard("New Customers", "42")),
                const SizedBox(width: 10),
                Expanded(child: _statCard("Orders Today", "128")),
              ],
            ),

            const SizedBox(height: 20),

            // ⚡ Quick Actions
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Quick Actions",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _quickButton(Icons.add_shopping_cart, "New Order", () {}),
                _quickButton(Icons.inventory, "Stock", () {}),
                _quickButton(Icons.bar_chart, "Reports", () {}),
                _quickButton(Icons.settings, "Settings", () {}),
              ],
            ),

            const SizedBox(height: 20),

            // 🧾 Recent Activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Recent Activity",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("See All",
                    style: TextStyle(color: Color(0xFFDE3905))),
              ],
            ),

            const SizedBox(height: 10),

            _activityItem(
              "Budi Setiawan",
              "Order Seblak Level 5",
              "2m ago",
              "Pending",
            ),

            _activityItem(
              "Siti Aminah",
              "Order Seblak Level 2",
              "15m ago",
              "Completed",
            ),

            _activityItem(
              "Andi Pratama",
              "Order Seblak Level 2",
              "45m ago",
              "Pending",
            ),
          ],
        ),
      ),

      // 🔻 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFFDE3905),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          // 🔥 Navigasi menu
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const KelolaMenuSeblak(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: "Topping"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // 🔹 STAT CARD
  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 🔹 QUICK BUTTON
  Widget _quickButton(
      IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFDE3905)),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // 🔹 ACTIVITY ITEM
  Widget _activityItem(
    String name,
    String order,
    String time,
    String status,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage:
            NetworkImage("https://i.pravatar.cc/150?u=$name"),
      ),
      title: Text(name),
      subtitle: Text(order),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(time, style: const TextStyle(fontSize: 10)),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: status == "Pending"
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                color: status == "Pending"
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}