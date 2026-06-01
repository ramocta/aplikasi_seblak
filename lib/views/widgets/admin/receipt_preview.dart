import 'package:flutter/material.dart';

class ReceiptPreview extends StatelessWidget {
  final List<dynamic> items;
  final double subtotal;
  final double grandTotal;
  final String orderId;

  const ReceiptPreview({
    super.key,
    required this.items,
    required this.subtotal,
    required this.grandTotal,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Say Cafe",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 2),
          const Center(
            child: Text(
              "Stall #04 - Food Junction Central",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "-------------------------------------------------------------------------",
            style: TextStyle(color: Colors.black12),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order ID: #SB-${orderId.padLeft(4, '0')}" ,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                DateTime.now().toString().substring(0, 16).replaceAll('-', '/'),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const Text(
            "-------------------------------------------------------------------------",
            style: TextStyle(color: Colors.black12),
          ),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              if (item == null) return const SizedBox.shrink();

              String namaMenu =
                  item['nama_menu'] ?? item['menu']?['nama_menu'] ?? "Menu";
              int qty = int.tryParse(item['qty']?.toString() ?? item['jumlah']?.toString() ?? "1") ?? 1;
              double hargaSatuan =
                  double.tryParse(item['harga_satuan']?.toString() ?? item['menu']?['harga']?.toString() ?? "0") ?? 0.0;
              double totalHargaItem = hargaSatuan * qty;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${qty} x ${namaMenu}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "Rp${totalHargaItem.toInt()}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (item['toppings'] != null || item['pesanan_toppings'] != null)
                      ...((item['toppings'] ?? item['pesanan_toppings'] ?? []) as List)
                          .map((t) {
                        String namaTopping =
                            t['nama_topping'] ?? t['topping']?['nama_topping'] ?? "Topping";
                        return Padding(
                          padding: const EdgeInsets.only(left: 14, top: 2),
                          child: Text(
                            "+ $namaTopping",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              );
            },
          ),

          const Text(
            "-------------------------------------------------------------------------",
            style: TextStyle(color: Colors.black12),
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Subtotal",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                "Rp${subtotal.toInt()}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TOTAL BAYAR",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "Rp${grandTotal.toInt()}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD84315),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

