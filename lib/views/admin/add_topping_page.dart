import 'dart:io'; // Untuk handle File gambar di Android/iOS
import 'package:flutter/foundation.dart'; // Untuk kIsWeb (antisipasi jika run di web)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // Library untuk ambil foto dari galeri
import 'package:seblak_say_cafe/controllers/topping_controller.dart';
import 'package:seblak_say_cafe/services/topping_services.dart';
import 'package:seblak_say_cafe/views/widgets/admin/add_topping_photo_picker.dart';
import 'package:seblak_say_cafe/views/widgets/admin/add_topping_form_fields.dart';
import 'package:seblak_say_cafe/views/widgets/admin/add_topping_save_button.dart';

class AddToppingPage extends StatefulWidget {
  const AddToppingPage({super.key});

  @override
  State<AddToppingPage> createState() => _AddToppingPageState();
}

class _AddToppingPageState extends State<AddToppingPage> {
  // Controller untuk menangkap inputan text form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  // Hubungkan ke GetX Controller dan Service Topping
  final ToppingController _toppingController = Get.find<ToppingController>();
  final ToppingService _toppingService = ToppingService();

  int? _selectedCategoryId;
  bool _isSaving = false;

  // Variabel penampung gambar yang dipilih
  File? _pickedImage; // Digunakan di Android / iOS
  Uint8List? _webImage; // Digunakan kalau running di Browser/Web
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Set default kategori yang terpilih pertama kali sesuai data dari database
    if (_toppingController.listCategories.isNotEmpty) {
      _selectedCategoryId = _toppingController.listCategories.first.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  /// Fungsi untuk membuka galeri dan mengambil gambar
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompres kualitas gambar ke 80% biar hemat storage Laravel
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
          });
        } else {
          setState(() {
            _pickedImage = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      print("❌ Error pas pilih gambar: $e");
    }
  }

  /// Fungsi utama untuk kirim data ke service
  Future<void> _saveTopping() async {
    // Validasi input form kosong di Flutter
    if (_nameController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _stockController.text.trim().isEmpty ||
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.amber, content: Text("Semua data form wajib diisi bang!")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Ambil angka harga & stok secara aman (convert ke int)
      int hargaInt = int.tryParse(_priceController.text.trim()) ?? 0;
      int stokInt = int.tryParse(_stockController.text.trim()) ?? 0;

      // Bungkus data dengan KEY yang SAMA PERSIS dengan aturan validator Laravel lu bang!
      final Map<String, dynamic> toppingData = {
        'id_kategori_topping': _selectedCategoryId, // validator Laravel: id_kategori_topping
        'nama_topping': _nameController.text.trim(), // validator Laravel: nama_topping
        'harga': hargaInt,
        'stok': stokInt,
        'gambar_file': _pickedImage, // Dikirim berupa file objek ke service
        'gambar_bytes': _webImage,   // Dikirim berupa bytes jika web
      };

      final bool success = await _toppingService.addTopping(toppingData);

      if (success) {
        // Tarik ulang list topping terbaru biar halaman utama langsung ter-update otomatis
        await _toppingController.fetchToppingByCategory(_toppingController.selectedCategoryId.value);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(backgroundColor: Colors.green, content: Text("Topping baru berhasil ditambahkan! 🔥")),
          );
          // SINKRON ROUTER: Balik ke halaman kelola topping bawaan GoRouter lu
          context.go('/topping_management'); 
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text("$e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => context.go('/topping_management'), 
        ),
        title: const Text(
          'Add Topping',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: _isSaving 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE64A19)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- UPLOAD FOTO (MATCH FIGMA) ---
                  const Text(
                    "upload topping photo",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  AddToppingPhotoPicker(
                    imageFile: _pickedImage,
                    webImageBytes: _webImage,
                    onPickImage: _pickImage,
                  ),
                  const SizedBox(height: 24),

                  AddToppingFormFields(
                    nameController: _nameController,
                    priceController: _priceController,
                    stockController: _stockController,
                    selectedCategoryId: _selectedCategoryId,
                    categories: _toppingController.listCategories,
                    onChangedCategoryId: (val) => setState(() => _selectedCategoryId = val),
                    nameValidator: (v) => v!.isEmpty ? "Topping name wajib diisi" : null,
                  ),
                  const SizedBox(height: 44),

                  AddToppingSaveButton(onPressed: _saveTopping),
                ],
              ),
            ),
    );
  }

  // Helper Widget untuk Label Form
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text, 
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)
    ),
  );

  // Helper Widget Text Field (Match Figma style)
  Widget _buildTextField(TextEditingController controller, String hint, TextInputType keyboardType) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFF1F3F4), // Abu-abu background figma
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide.none
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide.none
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: const BorderSide(color: Color(0xFFE64A19), width: 1.5)
        ),
      ),
    );
  }
}