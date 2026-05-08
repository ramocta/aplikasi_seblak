import 'package:flutter/material.dart';

class KelolaMenuSnack extends StatelessWidget {
  const KelolaMenuSnack({super.key});

  Widget menuItem(String nama, String harga, String img) {
    return Column(
      children: [
        Row(
          children: [
            Image.network(img, width: 80, height: 80, fit: BoxFit.cover),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "$nama\nHarga: $harga\nStok: 50",
                style: const TextStyle(fontSize: 12),
              ),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget kategoriButton(String text, bool active) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              active ? const Color(0xFFDE3905) : Colors.grey[300],
        ),
        onPressed: () {},
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      appBar: AppBar(
        title: const Text("Kelola Menu Snack"),
        backgroundColor: const Color(0xFFDE3905),
      ),

      body: Column(
        children: [
          // 🔹 Kategori
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                kategoriButton("Seblak", false),
                kategoriButton("Mie", false),
                kategoriButton("Minuman", false),
                kategoriButton("Snack", true),
              ],
            ),
          ),

          // 🔹 List Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                menuItem("Kentang Goreng", "Rp 7.000",
                    "https://picsum.photos/100"),
                menuItem("Cireng", "Rp 7.000",
                    "https://picsum.photos/100"),
              ],
            ),
          ),
        ],
      ),

      // ➕ Tambah
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFDE3905),
        onPressed: () {},
        child: const Icon(Icons.add),
      ),

      // 🔻 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFFDE3905),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
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