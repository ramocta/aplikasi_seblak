import 'package:flutter/material.dart';
import 'home_page.dart';
import 'kelola_menu_seblak.dart';
import 'kelola_menu_mie.dart';

class KelolaMenuMinuman extends StatefulWidget {
  const KelolaMenuMinuman({super.key});

  @override
  State<KelolaMenuMinuman> createState() => _KelolaMenuMinumanState();
}

class _KelolaMenuMinumanState extends State<KelolaMenuMinuman> {

  Widget menuItem(String nama, String harga, String stok, String img) {
    return Column(
      children: [
        Row(
          children: [
            Image.network(img, width: 80, height: 80, fit: BoxFit.cover),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "$nama\nharga : $harga\nstok : $stok",
                style: const TextStyle(fontSize: 12),
              ),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
          ],
        ),
        const Divider()
      ],
    );
  }

  Widget kategoriButton(String title, bool active, VoidCallback onTap) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Menu Minuman"),
        backgroundColor: const Color(0xFFDE3905),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Column(
        children: [

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(10),
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

                kategoriButton("Mie", false, () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KelolaMenuMie(),
                    ),
                  );
                }),

                kategoriButton("Minuman", true, () {}),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                menuItem("Es Jeruk", "5.000", "80",
                    "https://picsum.photos/100"),
                menuItem("Es Teh", "3.000", "80",
                    "https://picsum.photos/100"),
                menuItem("Es Doger", "8.000", "80",
                    "https://picsum.photos/100"),
                menuItem("Air Mineral", "4.000", "80",
                    "https://picsum.photos/100"),
              ], // ✅ INI YANG TADI KURANG
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
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Home()),
              (route) => false,
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: "Topping"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}