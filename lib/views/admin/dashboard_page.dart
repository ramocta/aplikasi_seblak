import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/views/admin/menu_page.dart';
import 'package:seblak_say_cafe/views/admin/topping_page.dart';
import 'order_page.dart';
import 'add_order_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  // Main pages list
  final List<Widget> _pages = [
    const HomeTab(),             // Index 0
    const OrderPage(),           // Index 1 (From order_page.dart)
    const MenuPage(),
    const ToppingPage(),
    const Center(child: Text("Profile Page")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _currentIndex == 0 ? "Dashboard" :
          _currentIndex == 1 ? "Order List" :
          _currentIndex == 2 ? "Manage Menu" :
          _currentIndex == 3 ? "Manage Topping" : 
          "Profile", 
          style: const TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.bold, 
            fontSize: 20
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFFE64A19), size: 28),
            onPressed: () => context.push('/notifications'), // 👈 Add this, Bro!
          ),
        ],
      ),
      
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFE64A19),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.layers_outlined), label: 'Topping'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),

      // Floating action button only appears on the Orders page
      floatingActionButton: _currentIndex == 1 
        ? FloatingActionButton(
            backgroundColor: const Color(0xFFE64A19),
            child: const Icon(Icons.edit_note, color: Colors.white, size: 30),
            onPressed: () => context.push('/add_order'), // Using GoRouter
          )
        : null,
    );
  }
}

// --- HOME TAB CONTENT ---
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE64A19),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today's Revenue", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Icon(Icons.payments_outlined, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 8),
                const Text("Rp 2.450.000", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const Text("+12.5% from yesterday", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            children: [
              _buildStatCard("New Customers", "42", Icons.people, Colors.orange),
              const SizedBox(width: 16),
              _buildStatCard("Orders Today", "128", Icons.receipt, Colors.deepOrange),
            ],
          ),
          const SizedBox(height: 24),
          const Center(child: Text("Quick Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          const SizedBox(height: 16),
          // Quick Actions Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickAction(Icons.shopping_cart_outlined, "New Order", const Color(0xFFFFF3E0)),
              _buildQuickAction(Icons.inventory_2_outlined, "Stock", const Color(0xFFF5F5F5)),
              _buildQuickAction(Icons.bar_chart, "Reports", const Color(0xFFF5F5F5)),
              _buildQuickAction(Icons.settings_outlined, "Settings", const Color(0xFFF5F5F5)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recent Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(color: Color(0xFFE64A19)))),
            ],
          ),
          _buildActivityItem("Budi Setiawan", "Order Seblak Level 5", "2m ago", "Pending", Colors.orange),
          _buildActivityItem("Siti Aminah", "Order Seblak Level 2", "15m ago", "Completed", Colors.green),
          _buildActivityItem("Andi Pratama", "Order Seblak Level 2", "45m ago", "Pending", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFE64A19)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color bg) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildActivityItem(String name, String desc, String time, String status, Color statusColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(backgroundImage: NetworkImage('https://via.placeholder.com/150')),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(desc),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}