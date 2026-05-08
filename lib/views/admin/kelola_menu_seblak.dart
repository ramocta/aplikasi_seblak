import 'package:flutter/material.dart';
import 'kelola_menu_mie.dart';
import 'kelola_menu_minuman.dart';

class KelolaMenuSeblak extends StatelessWidget {
  const KelolaMenuSeblak({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Menu Seblak"),
        backgroundColor: const Color(0xFFDE3905),

        // 🔙 kembali ke Home
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Column(
        children: [

          // 🔥 KATEGORI MENU
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [

                // SEBLAK (aktif)
                _kategoriButton("Seblak", true, () {}),

                // MIE
                _kategoriButton("Mie", false, () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KelolaMenuMie(),
                    ),
                  );
                }),

                // MINUMAN
                _kategoriButton("Minuman", false, () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KelolaMenuMinuman(),
                    ),
                  );
                }),
              ],
            ),
          ),

          // 🔥 LIST MENU
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _menuItem("Seblak Level 1", "Rp 7.000"),
                _menuItem("Seblak Level 2", "Rp 7.000"),
                _menuItem("Seblak Level 3", "Rp 7.000"),
                _menuItem("Seblak Level 4", "Rp 7.000"),
              ],
            ),
          ),
        ],
      ),

      // ➕ tombol tambah
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFDE3905),
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  // 🔹 BUTTON KATEGORI
  Widget _kategoriButton(
      String title, bool active, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              active ? const Color(0xFFDE3905) : Colors.grey[300],
        ),
        onPressed: onTap,
        child: Text(
          title,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // 🔹 ITEM MENU
  Widget _menuItem(String nama, String harga) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.fastfood),
        title: Text(nama),
        subtitle: Text(harga),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.edit, color: Colors.orange),
            SizedBox(width: 10),
            Icon(Icons.delete, color: Colors.red),
          ],
        ),
      ),
    );
  }
}