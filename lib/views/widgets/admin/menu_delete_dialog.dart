import 'package:flutter/material.dart';

class MenuDeleteDialog {
  static Future<void> show({
    required BuildContext context,
    required dynamic menu,
    required Future<void> Function(int idMenu) onConfirmDelete,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text("Hapus Menu", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            "Apakah anda yakin ingin menghapus '${menu.nama}'? Tindakan ini tidak dapat dibatalkan.",
          ),
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
                  final int idMenu = menu is Map ? (menu['id'] ?? 0) : (menu.id ?? 0);

                  await onConfirmDelete(idMenu);

                  await Future.delayed(const Duration(milliseconds: 300));

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text("Menu '${menu.nama}' berhasil dihapus!"),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text("Gagal menghapus menu dari database: $e"),
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

