import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailMiePage extends StatefulWidget {
  const DetailMiePage({super.key});

  @override
  State<DetailMiePage> createState() => _DetailMiePageState();
}

class _DetailMiePageState extends State<DetailMiePage> {
  String _flavor = 'Sweet';
  int _quantity = 1;
  final int _price = 9000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE64A19)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Deskripsi Menu Mie',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mie Level 1',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Price: 9.000',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 30),
            
            const Text(
              'Choose your noodle flavor',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _flavorBtn('Sweet'),
                const SizedBox(width: 12),
                _flavorBtn('Salty'),
              ],
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                const Text(
                  'Quantity',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
                const Spacer(),
                _counterBtn(Icons.remove, () {
                  if (_quantity > 1) setState(() => _quantity--);
                }, isAdd: false),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                _counterBtn(Icons.add, () => setState(() => _quantity++), isAdd: true),
              ],
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  'Rp. ${_price * _quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFFE64A19),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE64A19),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => context.pop(),
                child: const Text(
                  'Simpan Pesanan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _flavorBtn(String label) {
    bool isSelected = _flavor == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _flavor = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFE0B2) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFFE64A19) : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFFE64A19) : Colors.black54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              if (isSelected)
                const Icon(
                  Icons.check,
                  size: 16,
                  color: Color(0xFFE64A19),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap, {required bool isAdd}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isAdd ? const Color(0xFFE64A19) : Colors.white,
          border: Border.all(color: const Color(0xFFE64A19)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isAdd ? Colors.white : const Color(0xFFE64A19),
        ),
      ),
    );
  }
}