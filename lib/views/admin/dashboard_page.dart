import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/controllers/order_controller.dart';

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
          if (controller.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.only(top: 100.0),
              child: Center(child: CircularProgressIndicator(color: Color(0xFFE64A19))),
            );
          }

          // LOGIKA HITUNG: Hanya hitung jika status di database adalah 'done'
          int completedCount = controller.recentActivities.where((activity) {
            var rawStatus = activity['status_pesanan'] ?? activity['status'] ?? '';
            String status = rawStatus.toString().toLowerCase().trim();
            return status == 'done';
          }).length;

          int totalOrdersCount = controller.recentActivities.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 BOKS INFORMASI PENDAPATAN BULANAN (SEKARANG BISA DIKLIK KANAN-KIRI UNTUK KE REPORTS)
              InkWell(
                onTap: () => context.push('/reports'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE64A19),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE64A19).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Monthly Revenue (${controller.reportMonth.value})", 
                            style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const Row(
                            children: [
                              Text(
                                "View Report ",
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Rp ${controller.monthlyRevenue.value}", 
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.white54, size: 14),
                          SizedBox(width: 4),
                          Text("Tap to view full sales reports", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // KARTU STATISTIK
              Row(
                children: [
                  _buildStatCard(
                    "Completed Today", 
                    "$completedCount", 
                    Icons.check_circle_outline,
                    Colors.green
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    "Total Orders", 
                    "$totalOrdersCount", 
                    Icons.receipt_long_outlined,
                    const Color(0xFFE64A19)
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // RECENT ACTIVITY TITLE
              const Text("Recent Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              if (controller.recentActivities.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text("Belum ada aktivitas transaksi hari ini", style: TextStyle(color: Colors.grey))),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.recentActivities.take(10).length, 
                  itemBuilder: (context, index) {
                    var activity = controller.recentActivities[index];
                    var rawStatus = (activity['status_pesanan'] ?? 'pending').toString().toLowerCase().trim();

                    Color statusColor;
                    String statusText;

                    if (rawStatus == 'done') {
                      statusColor = Colors.green;
                      statusText = "Done";
                    } else if (rawStatus == 'reject') {
                      statusColor = Colors.red;
                      statusText = "Reject";
                    } else {
                      statusColor = Colors.amber;
                      statusText = "Pending";
                    }

                    return _buildActivityItem(
                      activity['nama_pemesan'] ?? activity['customer'] ?? "Pelanggan",
                      "Metode: ${activity['payment_method'] ?? 'Tunai'}", 
                      activity['created_at'] ?? "Baru saja",
                      statusText,
                      statusColor,
                    );
                  },
                ),
            ],
          );
        }),
      ),
    );
  }

  // Desain Kartu Indikator Data Terkoneksi Database
  Widget _buildStatCard(String title, String val, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5), 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String name, String desc, String time, String status, Color statusColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Color.fromARGB(255, 227, 227, 227), 
        child: Icon(Icons.person, color: Colors.white)
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(desc, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.3)),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time.length > 10 ? time.substring(0, 10) : time, 
            style: const TextStyle(fontSize: 11, color: Colors.grey)
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(30)
            ),
            child: Text(
              status, 
              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }
}