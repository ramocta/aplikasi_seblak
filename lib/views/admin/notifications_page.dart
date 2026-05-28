import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../../controllers/order_controller.dart';
import '../../../controllers/menu_controller.dart' as custom; // To avoid conflict with Flutter's built-in Menu widget

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _activeTab = 'All'; 
  late OrderController _orderController;
  late custom.MenuController _menuController;

  @override
  void initState() {
    super.initState();
    // Initialize Order Controller
    try {
      _orderController = Get.find<OrderController>();
    } catch (e) {
      _orderController = Get.put(OrderController());
    }

    // Initialize Menu Controller to monitor real-time master stock
    try {
      _menuController = Get.find<custom.MenuController>();
    } catch (e) {
      _menuController = Get.put(custom.MenuController());
    }

    // Fetch latest data from server when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _orderController.fetchDashboardStats();
      _menuController.refreshData(); 
    });
  }

  // --- 1. GET CRITICAL STOCK ITEMS ---
  List<Map<String, dynamic>> _getCriticalStockItems() {
    List<Map<String, dynamic>> criticalItems = [];

    // Check running out stock from all menus in master cache list
    for (var menu in _menuController.listMenu) {
      int stockMenu = int.tryParse(menu.stok.toString()) ?? 100;
      if (stockMenu <= 10) {
        criticalItems.add({
          'id': menu.id,
          'type': 'stock_alert',
          'title': 'MENU STOCK WARNING',
          'name': menu.nama,
          'stok': stockMenu,
          'created_at': menu.lastUpdate,
        });
      }
    }
    return criticalItems;
  }

  // --- 2. COMBINED & FILTERED NOTIFICATIONS LOGIC (ALL, ORDERS, STOCK) ---
  List<dynamic> getCombinedAndFilteredNotifications() {
    // Get raw orders data from Obx list
    List<dynamic> rawOrders = _orderController.recentActivities;
    
    // Get critical stock data
    List<Map<String, dynamic>> stockAlerts = _getCriticalStockItems();

    // Map all order data to a uniform format
    List<Map<String, dynamic>> formattedOrders = rawOrders.map((item) {
      return {
        'id': item['id'] ?? item['id_transaksi'] ?? 0,
        'type': 'order_entry',
        'title': 'NEW INCOMING ORDER',
        'name': 'Customer: ${item['nama_pemesan'] ?? item['nama'] ?? 'Anonymous'}',
        'status_pesanan': (item['status_pesanan'] ?? item['status'] ?? 'pending').toString().toLowerCase().trim(),
        'created_at': (item['created_at'] ?? item['tanggal_transaksi'] ?? DateTime.now().toString()).toString(),
        'raw_data': item // Save raw data for navigation to order details
      };
    }).toList();

    // --- TAB ORDERS ---
    if (_activeTab == 'Orders') {
      return formattedOrders;
    }

    // --- TAB STOCK ---
    if (_activeTab == 'Stock') {
      return stockAlerts;
    }

    // --- TAB ALL ---
    List<dynamic> allNotifications = [...stockAlerts, ...formattedOrders];
    
    // Sort by latest time
    allNotifications.sort((a, b) => b['created_at'].toString().compareTo(a['created_at'].toString()));
    
    return allNotifications;
  }

  // --- 3. REAL-TIME & SAFE TIME PARSER FUNCTION (FORMAT HH:mm) ---
  String _formatNotificationTime(String rawTime) {
    try {
      if (rawTime.trim().isEmpty) {
        return _getCurrentTimeFormatted();
      }
      
      // If using standard Laravel ISO DateTime string (e.g., 2026-05-24 14:30:00)
      if (rawTime.length >= 16) {
        return rawTime.substring(11, 16); // Extract HH:mm part directly
      }
      
      // Fallback parser using DateTime
      DateTime parsedDate = DateTime.parse(rawTime);
      return "${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      // If parsing fails, provide current device time as real-time fallback
      return _getCurrentTimeFormatted();
    }
  }

  String _getCurrentTimeFormatted() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFE64A19);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notifications', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: primaryOrange),
            onPressed: () {
              _orderController.fetchDashboardStats();
              _menuController.refreshData();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // --- TAB SELECTOR ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['All', 'Orders', 'Stock'].map((tab) {
                bool isActive = _activeTab == tab;
                return GestureDetector(
                  onTap: () => setState(() => _activeTab = tab),
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
                        fontSize: 13
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
              if (_orderController.isLoading.value || _menuController.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: primaryOrange));
              }

              final filteredItems = getCombinedAndFilteredNotifications();

              if (filteredItems.isEmpty) {
                return const Center(
                  child: Text(
                    'No notifications available.', 
                    style: TextStyle(color: Colors.grey)
                  )
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  var item = filteredItems[index];
                  bool isStockAlert = item['type'] == 'stock_alert';
                  
                  // Safe real-time parser execution
                  String time = _formatNotificationTime(item['created_at'].toString());

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
                            color: isStockAlert ? Colors.red.shade200 : Colors.grey.shade200
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
                                isStockAlert ? Icons.warning_amber_rounded : Icons.shopping_bag_outlined,
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
                                          color: isStockAlert ? Colors.red : primaryOrange
                                        ),
                                      ),
                                      Text(
                                        time, 
                                        style: const TextStyle(
                                          fontSize: 11, 
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isStockAlert 
                                        ? "Menu [ ${item['name']} ] is running low! Remaining stock: ${item['stok']}" 
                                        : item['name'] ?? "",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  if (!isStockAlert) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      "Click to update status & process in kitchen",
                                      style: TextStyle(
                                        fontSize: 11, 
                                        color: Colors.grey.shade600, 
                                        fontStyle: FontStyle.italic
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
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}