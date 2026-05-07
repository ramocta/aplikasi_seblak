import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuPage3 extends StatefulWidget {
  const MenuPage3({super.key});

  @override
  State<MenuPage3> createState() => _MenuPage3State();
}

class _MenuPage3State extends State<MenuPage3> {
  int kategoriDipilih = 2; // index 2 = Drink

  final List<String> kategori = ['Seblak', 'Mie', 'Drink', 'Snack'];

  
  final Map<String, int> keranjang = {};

  final List<Map<String, String>> daftarMenu = [
    {
      'nama': 'Es Doger',
      'desc': '( Minuman Segar )',
      'harga': 'Rp. 7.000',
      'gambar': 'assets/images/es_doger.png',
    },
    {
      'nama': 'Es Teh',
      'desc': '( Minuman Segar )',
      'harga': 'Rp. 7.000',
      'gambar': 'assets/images/es_teh.png',
    },
    {
      'nama': 'Es Jeruk',
      'desc': '( Minuman Segar )',
      'harga': 'Rp. 7.000',
      'gambar': 'assets/images/es_jeruk.png',
    },
    {
      'nama': 'Air Putih',
      'desc': '( Minuman Segar )',
      'harga': 'Rp. 5.000',
      'gambar': 'assets/images/air_putih.png',
    },
  ];

  int get totalKeranjang =>
      keranjang.values.fold(0, (sum, qty) => sum + qty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

    
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () {
          },
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          label: Text(
            totalKeranjang > 0
                ? 'View cart ($totalKeranjang)'
                : 'View cart',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53935),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFFE53935),
                    ),
                  ),
                  Image.asset(
                    'assets/images/Logo2.png',
                    height: 36,
                    errorBuilder: (_, __, ___) => const Text(
                      'Say!',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.menu, color: Color(0xFFE53935)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    // ── Banner ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/images/banner_bg.jpg',
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 130,
                                color: Colors.black87,
                              ),
                            ),
                            Container(
                              height: 130,
                              color: Colors.black.withOpacity(0.4),
                              padding: const EdgeInsets.all(16),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Let's Celebrate",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13),
                                  ),
                                  Text(
                                    'THIS NIGHT OF SHIVA',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    'with us !',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'DELICIOUS FOOD  |  WARM DRINKS  |  GOOD MOOD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Table Info ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5C518),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Table 1',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '|',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Dine in',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Tab Kategori ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(kategori.length, (i) {
                          final dipilih = i == kategoriDipilih;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => kategoriDipilih = i),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: dipilih
                                    ? const Color(0xFFE53935)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: dipilih
                                    ? null
                                    : Border.all(
                                        color: Colors.grey.shade300),
                              ),
                              child: Text(
                                kategori[i],
                                style: TextStyle(
                                  color: dipilih
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  fontWeight: dipilih
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Daftar Menu Minuman ──
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: daftarMenu.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 1, color: Color(0xFFEEEEEE)),
                      itemBuilder: (context, i) {
                        final menu = daftarMenu[i];
                        final qty = keranjang[menu['nama']] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // Gambar minuman
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: Image.asset(
                                    menu['gambar']!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(
                                      color: const Color(0xFFE3F2FD),
                                      child: const Icon(
                                        Icons.local_drink,
                                        color: Color(0xFFE53935),
                                        size: 36,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              // Nama & harga
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      menu['nama']!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      menu['harga']!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Tombol Add / quantity
                              qty == 0
                                  ? OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          keranjang[menu['nama']!] = 1;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Color(0xFFE53935)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 18,
                                                vertical: 8),
                                      ),
                                      child: const Text(
                                        'Add',
                                        style: TextStyle(
                                          color: Color(0xFFE53935),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (qty > 1) {
                                                keranjang[menu['nama']!] =
                                                    qty - 1;
                                              } else {
                                                keranjang
                                                    .remove(menu['nama']);
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: const Color(
                                                      0xFFE53935)),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      14),
                                            ),
                                            child: const Icon(
                                              Icons.remove,
                                              size: 16,
                                              color: Color(0xFFE53935),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets
                                              .symmetric(horizontal: 8),
                                          child: Text(
                                            '$qty',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              keranjang[menu['nama']!] =
                                                  qty + 1;
                                            });
                                          },
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color:
                                                  const Color(0xFFE53935),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      14),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}