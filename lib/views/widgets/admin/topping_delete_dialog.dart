import 'package:flutter/material.dart';
import 'package:seblak_say_cafe/controllers/topping_controller.dart' as topping_controller;

class ToppingDeleteDialog {
  static Future<void> show({
    required BuildContext context,
    required topping_controller.ToppingController controller,
    required dynamic topping,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text("Hapus Topping", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text("Yakin ingin menghapus topping '${topping.nama}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await controller.deleteTopping(topping.id);
                  await Future.delayed(const Duration(milliseconds: 300));

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text("Topping '${topping.nama}' sukses dihapus!"),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text("Gagal menghapus: $e"),
                      ),
                    );
                  }
                }
              },
              child: const Text(
                "Hapus",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

