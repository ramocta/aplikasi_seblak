import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CheckoutPage(),
  ));
}

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────

class OrderItem {
  String name;
  int price;
  String? flavor;
  List<String> toppings;
  String? imagePath;

  OrderItem({
    required this.name,
    required this.price,
    this.flavor,
    this.toppings = const [],
    this.imagePath,
  });

  int get subtotal => price;
}

// ─────────────────────────────────────────────────────────────────────────────
// DUMMY DATA
// ─────────────────────────────────────────────────────────────────────────────

List<OrderItem> orders = [
  OrderItem(
    name: 'Seblak Level 1',
    price: 7000,
    imagePath: 'assets/images/seblak1.png',
    toppings: [
      'Dumpling Ayam x 1',
      'Dumpling Ayam x 1',
      'Dumpling Ayam x 1',
      'Dumpling Ayam x 1',
    ],
  ),
  OrderItem(
    name: 'Mie Level 1 x 1',
    price: 9000,
    imagePath: 'assets/images/mie1.png',
    flavor: 'Flavor: Sweet',
  ),
  OrderItem(
    name: 'Es Teh x 1',
    price: 3000,
    imagePath: 'assets/images/es_teh.png',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// HALAMAN CHECKOUT
// ─────────────────────────────────────────────────────────────────────────────

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // Mode: 'normal', 'edit', 'hapus'
  String mode = 'normal';

  // Item yang dicentang
  final Set<int> itemDipilih = {};

  // Untuk fitur Undo
  List<OrderItem>? _backupOrders;

  int get total =>
      orders.fold(0, (sum, item) => sum + item.subtotal);

  String formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp. ${buffer.toString().split('').reversed.join()}';
  }

  // ── TOMBOL EDIT DIPENCET ────────────────────────────────────────────────────
  void aktifkanModeEdit() {
    setState(() {
      mode = 'edit';
      itemDipilih.clear();
    });
  }

  // ── TOMBOL HAPUS DIPENCET ───────────────────────────────────────────────────
  void aktifkanModeHapus() {
    setState(() {
      mode = 'hapus';
      itemDipilih.clear();
    });
  }

  // ── BATAL / KEMBALI KE NORMAL ───────────────────────────────────────────────
  void kembaliNormal() {
    setState(() {
      mode = 'normal';
      itemDipilih.clear();
    });
  }

  // ── HAPUS ITEM YANG DIPILIH ─────────────────────────────────────────────────
  void hapusItemDipilih() {
    if (itemDipilih.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete This item ?',
          style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Text(
          'If you delete this item it cannot be restored.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _lakukanHapus();
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _lakukanHapus() {
    // Backup dulu sebelum hapus untuk fitur Undo
    _backupOrders = List.from(orders);

    setState(() {
      final sortedIndexes = itemDipilih.toList()
        ..sort((a, b) => b.compareTo(a));
      for (final i in sortedIndexes) {
        orders.removeAt(i);
      }
      itemDipilih.clear();
      mode = 'normal';
    });

    // Tampilkan snackbar "Successful Delete" + tombol Undo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
        content: const Text(
          'Successful Delete',
          style: TextStyle(color: Colors.black87),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.red,
          onPressed: () {
            // Kembalikan data yang dihapus
            setState(() {
              if (_backupOrders != null) {
                orders = List.from(_backupOrders!);
                _backupOrders = null;
              }
            });
          },
        ),
      ),
    );
  }

  // ── EDIT ITEM ───────────────────────────────────────────────────────────────
  void editItem(int index) {
    final namaCtrl =
        TextEditingController(text: orders[index].name);
    final hargaCtrl =
        TextEditingController(text: orders[index].price.toString());
    final flavorCtrl =
        TextEditingController(text: orders[index].flavor ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Pesanan',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            const Text('Nama Item',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: namaCtrl,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFE53935)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            const Text('Harga (Rp)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: hargaCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFE53935)),
                ),
              ),
            ),

            if (orders[index].flavor != null) ...[
              const SizedBox(height: 12),
              const Text('Flavor',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: flavorCtrl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFE53935)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  setState(() {
                    orders[index].name = namaCtrl.text;
                    orders[index].price =
                        int.tryParse(hargaCtrl.text) ??
                            orders[index].price;
                    if (orders[index].flavor != null) {
                      orders[index].flavor = flavorCtrl.text;
                    }
                  });
                  Navigator.pop(ctx);
                  kembaliNormal();
                },
                child: const Text('Simpan Perubahan',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) =>
                    _buildItemCard(index),
              ),
            ),
            // Hanya tampilkan total & checkout kalau mode normal
            if (mode == 'normal') _buildBottomSection(),
            // Kalau mode hapus & ada yang dipilih, tampilkan tombol hapus
            if (mode == 'hapus' && itemDipilih.isNotEmpty)
              _buildTombolHapus(),
          ],
        ),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          Row(
            children: [
              // Tombol kembali
              GestureDetector(
                onTap: mode != 'normal'
                    ? kembaliNormal
                    : () => Navigator.maybePop(context),
                child: const Icon(Icons.arrow_back,
                    color: Color(0xFFE53935)),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.shopping_cart_outlined,
                  color: Color(0xFFE53935)),
              const SizedBox(width: 8),
              const Text('Your Cart',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),

              const Spacer(),

              // Kalau mode hapus & ada yang dipilih, tampilkan jumlah
              if (mode == 'hapus' && itemDipilih.isNotEmpty)
                Text(
                  '${itemDipilih.length} Item',
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 13),
                ),
              const SizedBox(width: 8),

              // Tombol edit (pensil)
              GestureDetector(
                onTap: mode == 'normal'
                    ? aktifkanModeEdit
                    : (mode == 'edit' && itemDipilih.length == 1)
                        ? () => editItem(itemDipilih.first)
                        : null,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: mode == 'edit' &&
                            itemDipilih.length == 1
                        ? Colors.orange
                        : const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 8),

              // Tombol hapus (tong sampah)
              GestureDetector(
                onTap: mode == 'normal'
                    ? aktifkanModeHapus
                    : (mode == 'hapus' &&
                            itemDipilih.isNotEmpty)
                        ? hapusItemDipilih
                        : null,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── KARTU ITEM ──────────────────────────────────────────────────────────────
  Widget _buildItemCard(int index) {
    final item = orders[index];
    final dipilih = itemDipilih.contains(index);
    final tampilCheckbox = mode == 'edit' || mode == 'hapus';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: dipilih
            ? Border.all(color: const Color(0xFFE53935), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox (hanya muncul di mode edit/hapus)
                if (tampilCheckbox)
                  Checkbox(
                    value: dipilih,
                    activeColor: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          itemDipilih.add(index);
                        } else {
                          itemDipilih.remove(index);
                        }
                      });
                    },
                  )
                else
                  // Nomor urut (mode normal)
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 8, top: 4),
                    child: Text('${index + 1}.',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                  ),

                // Gambar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: item.imagePath != null
                        ? Image.asset(
                            item.imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.fastfood,
                                  color: Colors.grey, size: 28),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.fastfood,
                                color: Colors.grey, size: 28),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Detail item
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.name,
                              style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                  fontSize: 13)),
                          Text(formatRupiah(item.price),
                              style: const TextStyle(
                                  fontSize: 13)),
                        ],
                      ),

                      if (item.flavor != null) ...[
                        const SizedBox(height: 4),
                        Text(item.flavor!,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12)),
                      ],

                      if (item.toppings.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        const Text('Topping:',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12)),
                        ...item.toppings.map((t) => Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text(t,
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12)),
                                const Text('Rp. 2.000',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12)),
                              ],
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:',
                    style: TextStyle(fontSize: 13)),
                Text(formatRupiah(item.subtotal),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── BAGIAN BAWAH (mode normal) ───────────────────────────────────────────────
  Widget _buildBottomSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text(formatRupiah(total),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Checkout! Total: ${formatRupiah(total)}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Checkout',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── TOMBOL HAPUS (mode hapus & ada yang dipilih) ────────────────────────────
  Widget _buildTombolHapus() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: hapusItemDipilih,
          child: Text(
            'Hapus ${itemDipilih.length} Item',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}