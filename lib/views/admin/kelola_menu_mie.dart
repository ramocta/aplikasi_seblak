import 'package:flutter/material.dart';
import 'kelola_menu_seblak.dart';
import 'kelola_menu_minuman.dart';

class KelolaMenuMie extends StatefulWidget {
  const KelolaMenuMie({super.key});

  @override
  State<KelolaMenuMie> createState() => _KelolaMenuMieState();
}

class _KelolaMenuMieState extends State<KelolaMenuMie> {

  Widget menuItem(String title, String img) {
    return Column(
      children: [
        Row(
          children: [
            Image.network(img, width: 85, height: 85, fit: BoxFit.cover),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                "$title\nVarian: (Manis / Gurih)\nHarga: Rp 9.000\nStok: 50",
                style: const TextStyle(fontSize: 12),
              ),
            )
          ],
        ),
        const Divider()
      ],
    );
  }

  // 🔥 PERBAIKAN: tambah onTap
  Widget kategoriButton(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFDE3905) : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Menu Mie"),
        backgroundColor: const Color(0xFFDE3905),
      ),

      backgroundColor: const Color(0xFFF8F8F8),

      body: Column(
        children: [
          const SizedBox(height: 16),

          // 🔹 Kategori
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [

                kategoriButton("Seblak", false, () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KelolaMenuSeblak(),
                    ),
                  );
                }),

                kategoriButton("Mie", true, () {}),

                kategoriButton("Minuman", false, () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KelolaMenuMinuman(),
                    ),
                  );
                }),

                kategoriButton("Snack", false, () {}),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 List menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                menuItem("Mie Level 1", "https://via.placeholder.com/100"),
                menuItem("Mie Level 2", "https://via.placeholder.com/100"),
                menuItem("Mie Level 3", "https://via.placeholder.com/100"),
                menuItem("Mie Level 4", "https://via.placeholder.com/100"),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFDE3905),
        onPressed: () {},
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFFDE3905),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context); // kembali ke Home
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
}