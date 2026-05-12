import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Variabel untuk tab kategori aktif
  String _activeTab = 'All';

  // Data Simulasi Notifikasi
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'category': 'Orders',
      'title': 'New Order',
      'subtitle': 'Budi Setiawan - Seblak Level 3, Extra Asin, Bakso Aci',
      'time': '10:55 AM',
      'date': 'Today',
      'isRead': false,
      'icon': Icons.restaurant,
    },
    {
      'id': 2,
      'category': 'Stock',
      'title': 'Low Stock',
      'subtitle': 'Kerupuk Rafael sisa 3 portions. Re-order required before lunch rush starts.',
      'time': '09:35 AM',
      'date': 'Today',
      'isRead': false,
      'icon': Icons.warning_amber_rounded,
    },
    {
      'id': 3,
      'category': 'Orders',
      'title': 'Completed',
      'subtitle': 'Refill - Rp 25.000, Payment verified and order processed.',
      'time': 'Yesterday',
      'date': 'Yesterday',
      'isRead': true,
      'icon': Icons.check_circle_outline,
    },
    {
      'id': 4,
      'category': 'Stock',
      'title': 'Stock Stable',
      'subtitle': 'Remaining stocks for 12 products.',
      'time': '01:00 PM',
      'date': 'Yesterday',
      'isRead': true,
      'icon': Icons.inventory_2_outlined,
    },
  ];

  // Fungsi untuk memfilter notifikasi berdasarkan tab
  List<Map<String, dynamic>> get filteredNotifications {
    if (_activeTab == 'All') {
      return _notifications;
    }
    return _notifications.where((item) => item['category'] == _activeTab).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(), // Menggunakan GoRouter
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var element in _notifications) {
                  element['isRead'] = true;
                }
              });
            },
            child: const Text(
              'Mark all as read',
              style: TextStyle(
                color: Color(0xFFE64A19),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Kategori Tabs (All, Orders, Stock)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTab('All'),
                _buildTab('Orders'),
                _buildTab('Stock'),
              ],
            ),
          ),
          
          // Daftar Notifikasi
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: _buildGroupedNotifications(),
            ),
          ),
        ],
      ),
    );
  }

  // Tombol Tab Kategori
  Widget _buildTab(String label) {
    bool isActive = _activeTab == label;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE64A19) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Logika Menampilkan List Notifikasi
  List<Widget> _buildGroupedNotifications() {
    final items = filteredNotifications;

    if (items.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('Tidak ada notifikasi saat ini.'),
          ),
        ),
      ];
    }

    return items.map((item) {
      return InkWell( // 👈 Gunakan InkWell agar ada efek klik (ripple effect)
        onTap: () {
          setState(() {
            // Mengubah status menjadi read (sudah dibaca) saat diklik
            item['isRead'] = true;
          });

          // Contoh Aksi: Menampilkan SnackBar atau Navigasi ke detail
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Membuka: ${item['title']}'),
              duration: const Duration(seconds: 1),
            ),
          );
          
          // Jika ingin pindah ke halaman detail:
          // context.push('/notification_detail', extra: item);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item['isRead'] ? Colors.white : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item['isRead'] ? Colors.grey.shade200 : const Color(0xFFFFB74D),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ikon Notifikasi
              CircleAvatar(
                backgroundColor: const Color(0xFFE64A19).withOpacity(0.1),
                child: Icon(
                  item['icon'],
                  color: const Color(0xFFE64A19),
                ),
              ),
              const SizedBox(width: 12),
              
              // Teks Informasi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          item['time'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subtitle'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}