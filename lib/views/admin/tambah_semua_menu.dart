import 'package:flutter/material.dart';

class TambahSemuaMenu extends StatefulWidget {
  const TambahSemuaMenu({super.key});

  @override
  State<TambahSemuaMenu> createState() => _TambahSemuaMenuState();
}

class _TambahSemuaMenuState extends State<TambahSemuaMenu> {
  String namaMenu = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Menu"),
        backgroundColor: const Color(0xFFDE3905),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 📸 Upload Foto
            const Text("Upload Foto Menu"),
            const SizedBox(height: 10),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, color: Color(0xFFDE3905), size: 30),
                  SizedBox(height: 5),
                  Text("Tap to upload image",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📝 Nama Menu
            const Text("Nama Menu"),
            const SizedBox(height: 5),
            TextField(
              onChanged: (v) => setState(() => namaMenu = v),
              decoration: InputDecoration(
                hintText: "Contoh: Mie Goreng Spesial",
                filled: true,
                fillColor: const Color(0xFFF3F3F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🍜 Kategori
            const Text("Kategori"),
            const SizedBox(height: 10),
            Row(
              children: [
                _kategori("Seblak", true),
                _kategori("Mie", false),
                _kategori("Minuman", false),
                _kategori("Snack", false),
              ],
            ),

            const SizedBox(height: 20),

            // 🧾 Deskripsi
            const Text("Deskripsi"),
            const SizedBox(height: 5),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Jelaskan menu...",
                filled: true,
                fillColor: const Color(0xFFF3F3F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 💰 Harga & Stok
            Row(
              children: [
                Expanded(
                  child: _inputField("Harga (Rp)"),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _inputField("Stok"),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 💾 Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  print("Menu disimpan: $namaMenu");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDE3905),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Simpan Menu"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Widget kategori
  Widget _kategori(String text, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              active ? const Color(0xFFDE3905) : Colors.grey.shade300,
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

  // 🔹 Input field reusable
  Widget _inputField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF3F3F4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}