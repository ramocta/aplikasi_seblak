import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart'; // Wajib di-import untuk clear cache GetX Controller
import '../../models/menu_models.dart';
import '../../controllers/menu_controller.dart' as getx; // Menggunakan alias agar tidak bentrok dengan TextEditingController

class EditMenuPage extends StatefulWidget {
  final MenuModels menu;

  const EditMenuPage({
    super.key,
    required this.menu,
  });

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  
  int? _selectedCategoryId; 
  File? _imageFile;
  Uint8List? _webImageBytes;
  String? _webImageName;
  bool _isLoading = false;

  final Map<String, int> _categoriesMap = {
    'Seblak': 1,
    'Mie': 2,
    'Minuman': 3,
    'Snack': 4,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menu.nama);
    // Bersihkan nilai harga awal dari teks 'Rp', titik, atau spasi bawaan model data
    String initialPrice = widget.menu.harga.toString().replaceAll(RegExp(r'[^0-9]'), '');
    _priceController = TextEditingController(text: initialPrice);
    _stockController = TextEditingController(text: widget.menu.stok.toString());
    
    _selectedCategoryId = _categoriesMap[widget.menu.kategorimenu.nama] ?? _categoriesMap.values.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _webImageName = pickedFile.name;
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      dio.Dio apiDio = dio.Dio();

      final prefs = await SharedPreferences.getInstance();
      String? tokenAdmin = prefs.getString('token');

      // 1. Bersihkan string harga dari karakter non-angka
      String cleanPrice = _priceController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');

      // 2. KUNCI SUKSES: Key disesuaikan 100% dengan $fillable di Model Laravel backend lu bang!
      Map<String, dynamic> payload = {
        'nama_menu': _nameController.text.trim(),        // Sesuai dengan database Laravel
        'id_kategori_menu': _selectedCategoryId.toString(), // Sesuai dengan database Laravel
        'harga': cleanPrice,
        'stok': _stockController.text.trim(),
        '_method': 'PUT', // Spoofing PUT agar dibaca sebagai Update oleh Route::apiResource
      };

      // 3. Masukkan FILE GAMBAR dengan key 'gambar' sesuai $fillable Laravel
      if (kIsWeb && _webImageBytes != null) {
        payload['gambar'] = dio.MultipartFile.fromBytes(
          _webImageBytes!,
          filename: _webImageName ?? 'update_menu.jpg',
        );
      } else if (!kIsWeb && _imageFile != null) {
        payload['gambar'] = await dio.MultipartFile.fromFile(
          _imageFile!.path,
          filename: _imageFile!.path.split('/').last,
        );
      }

      dio.FormData formData = dio.FormData.fromMap(payload);

      // 4. Eksekusi POST biasa ke endpoint Laravel
      dio.Response response = await apiDio.post(
        "http://localhost:8000/api/admin/menu/${widget.menu.id}",
        data: formData,
        options: dio.Options(
          headers: {
            'Accept': 'application/json',
            if (tokenAdmin != null) 'Authorization': 'Bearer $tokenAdmin', 
          },
          validateStatus: (status) => status! < 500, 
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          // 5. Hapus cache GetX biar data terbaru langsung ditarik dari database MySQL
          try {
            if (Get.isRegistered<getx.MenuController>()) {
              final menuCtrl = Get.find<getx.MenuController>();
              menuCtrl.clearCache(); 
            }
          } catch (e) {
            print("Gagal menghapus cache GetX: $e");
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(backgroundColor: Colors.green, content: Text("Menu sukses diperbarui!")),
          );
          context.go('/menu_management'); 
        }
      } else if (response.statusCode == 401) {
        throw Exception("Sesi login habis (401). Silakan logout dan login kembali.");
      } else if (response.statusCode == 404) {
        throw Exception("Menu ID tidak ditemukan atau rute salah (404).");
      } else {
        throw Exception("Gagal merespon server: Code ${response.statusCode}\nDetail: ${response.data}");
      }

    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Gagal Menyimpan"),
            content: Text(e.toString().replaceAll("Exception:", "")),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Edit Menu', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/menu_management'), 
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFE64A19)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Upload Foto Menu', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                        image: kIsWeb && _webImageBytes != null
                            ? DecorationImage(image: MemoryImage(_webImageBytes!), fit: BoxFit.cover)
                            : !kIsWeb && _imageFile != null
                                ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                                : (widget.menu.gambarUrl.isNotEmpty && widget.menu.gambarUrl.startsWith('http'))
                                    ? DecorationImage(image: NetworkImage(widget.menu.gambarUrl), fit: BoxFit.cover)
                                    : null, 
                      ),
                      child: _webImageBytes == null && _imageFile == null && (!widget.menu.gambarUrl.startsWith('http'))
                          ? const Center(child: Icon(Icons.camera_alt, size: 40, color: Colors.grey))
                          : const Stack(
                              children: [
                                Positioned(
                                  bottom: 12, right: 12,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 18,
                                    child: Icon(Icons.edit, size: 16, color: Color(0xFFE64A19)),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Nama Produk"),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration(),
                    validator: (v) => v!.isEmpty ? "Nama tidak boleh kosong" : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Kategori"),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white, 
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _categoriesMap.values.contains(_selectedCategoryId) ? _selectedCategoryId : _categoriesMap.values.first,
                                  isExpanded: true,
                                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                                  items: _categoriesMap.entries.map((e) => DropdownMenuItem(value: e.value, child: Text(e.key))).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Stok"),
                            TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(),
                              validator: (v) => v!.isEmpty ? "Stok wajib diisi" : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Harga (IDR)"),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration().copyWith(prefixText: 'Rp '),
                    validator: (v) {
                      if (v!.isEmpty) return "Harga wajib diisi";
                      String digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                      if (digits.isEmpty) return "Format harga salah";
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE64A19),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _saveChanges,
                      child: const Text(
                        'Simpan Perubahan', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  );

  InputDecoration _inputDecoration() => InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE64A19), width: 1.5)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
  );
}