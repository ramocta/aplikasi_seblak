import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/controllers/order_controller.dart';
import '../widgets/admin/dashboard_home_cards.dart';
import '../widgets/admin/dashboard_recent_activity.dart';

class DashboardPage extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final Widget child; // Widget dinamis penampung rute aktif dari ShellRoute

  DashboardPage({super.key, this.userData, required this.child});

  final OrderController orderController = Get.put(OrderController());

  // Menghitung index BottomNavBar aktif berdasarkan path URL browser
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/order')) return 1;
    if (location.startsWith('/menu_management')) return 2;
    if (location.startsWith('/topping_management')) return 3;
    if (location.startsWith('/profil')) return 4;
    return 0; // Default kembali ke /dashboard (HomeTab)
  }

  // Aksi perpindahan rute murni menggunakan URL GoRouter
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/order');
        break;
      case 2:
        context.go('/menu_management');
        break;
      case 3:
        context.go('/topping_management');
        break;
      case 4:
        context.go('/profil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          currentIndex == 0 ? "Dashboard" :
          currentIndex == 1 ? "Order List" :
          currentIndex == 2 ? "Manage Menu" :
          currentIndex == 3 ? "Manage Topping" : "Profile",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFFE64A19), size: 28),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      
      // MENAMPILKAN HALAMAN SUB-RUTE AKTIF SECARA DINAMIS
      body: child, 
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFFE64A19),
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.layers_outlined), label: 'Topping'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
// --- HOME TAB CONTENT ---


class HomeTab extends StatelessWidget {

  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.find<OrderController>();

    return RefreshIndicator(
      onRefresh: () => controller.fetchDashboardStats(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          // Hasil perhitungan statistik tetap sama
          final int completedCount = controller.recentActivities.where((activity) {
            var rawStatus = activity['status_pesanan'] ?? activity['status'] ?? '';
            final status = rawStatus.toString().toLowerCase().trim();
            return status == 'done';
          }).length;

          final int totalOrdersCount = controller.recentActivities.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MonthlyRevenueCard(),
              const SizedBox(height: 20),
              StatCardsRow(
                completedCount: completedCount,
                totalOrdersCount: totalOrdersCount,
              ),
              const SizedBox(height: 24),
              const Text("Recent Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const RecentActivityList(),
            ],
          );
        }),
      ),
    );
  }
}