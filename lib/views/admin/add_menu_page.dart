import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_lib;
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../controllers/menu_controller.dart' as getx; 

class AddMenuPage extends StatefulWidget {
  const AddMenuPage({super.key});

  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  
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
    _selectedCategoryId = _categoriesMap.values.first;
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

  Future<void> _saveMenu() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (kIsWeb && _webImageBytes == null) {
      _showSnackBar("Foto menu wajib diupload!", Colors.red);
      return;
    }
    if (!kIsWeb && _imageFile == null) {
      _showSnackBar("Foto menu wajib diupload!", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      dio_lib.Dio apiDio = dio_lib.Dio();
      final prefs = await SharedPreferences.getInstance();
      String? tokenAdmin = prefs.getString('token');
      
      String cleanPrice = _priceController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');

      Map<String, dynamic> payload = {
        'nama_menu': _nameController.text.trim(),
        'id_kategori_menu': _selectedCategoryId.toString(),
        'harga': cleanPrice,
        'stok': _stockController.text.trim(),
      };

      if (kIsWeb && _webImageBytes != null) {
        payload['gambar'] = dio_lib.MultipartFile.fromBytes(
          _webImageBytes!,
          filename: _webImageName ?? 'menu_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      } else if (!kIsWeb && _imageFile != null) {
        payload['gambar'] = await dio_lib.MultipartFile.fromFile(
          _imageFile!.path,
          filename: _imageFile!.path.split('/').last,
        );
      }

      dio_lib.FormData formData = dio_lib.FormData.fromMap(payload);

      var response = await apiDio.post(
        "http://192.168.18.171:8000/api/admin/menu", 
        data: formData,
        options: dio_lib.Options(
          headers: {
            'Accept': 'application/json',
            if (tokenAdmin != null) 'Authorization': 'Bearer $tokenAdmin',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        try {
          if (Get.isRegistered<getx.MenuController>()) {
            final menuCtrl = Get.find<getx.MenuController>();
            menuCtrl.clearCache(); 
          }
        } catch (e) {
          print("Gagal menghapus cache GetX: $e");
        }

        _showSnackBar("Berhasil menyimpan menu baru!", Colors.green);
        
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/menu_management');
        }
      } else if (response.statusCode == 401) {
        throw Exception("Sesi login habis (401). Silakan login kembali.");
      } else {
        throw Exception("Gagal merespon server: Code ${response.statusCode}\nDetail: ${response.data}");
      }
    } catch (e) {
      print("Detail Error: $e");
      if (mounted) {
        _showSnackBar(e.toString().replaceAll("Exception:", ""), Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: bgColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Add Menu', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/menu_management');
            }
          },
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD84315)))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- UPLOAD FOTO (MATCH FIGMA) ---
                  const Text(
                    'upload menu photo', 
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black)
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E0E0).withOpacity(0.6)),
                        image: kIsWeb && _webImageBytes != null 
                          ? DecorationImage(image: MemoryImage(_webImageBytes!), fit: BoxFit.cover)
                          : !kIsWeb && _imageFile != null
                            ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _webImageBytes == null && _imageFile == null 
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_a_photo_outlined, 
                                size: 38, 
                                color: Color(0xFFE64A19)
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Tap to upload image', 
                                style: TextStyle(
                                  color: Colors.grey.shade500, 
                                  fontSize: 15, 
                                  fontWeight: FontWeight.w500
                                )
                              ),
                            ],
                          )
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
                  const SizedBox(height: 24),

                  // --- MENU NAME ---
                  _buildLabel("Menu Name"),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration(hint: 'Enter the menu name'),
                    validator: (v) => v!.trim().isEmpty ? "Menu name is required" : null,
                  ),
                  const SizedBox(height: 20),

                  // --- ROW CATEGORY & STOCK ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DROPDOWN CATEGORY
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Category"),
                            Container(
                              height: 54,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F4), 
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _categoriesMap.values.contains(_selectedCategoryId) ? _selectedCategoryId : _categoriesMap.values.first,
                                  isExpanded: true,
                                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                                  items: _categoriesMap.entries.map((e) => DropdownMenuItem(value: e.value, child: Text(e.key))).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // INPUT STOCK
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Stock"),
                            TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(hint: '0'),
                              validator: (v) => v!.trim().isEmpty ? "Required" : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- PRICE ---
                  _buildLabel("Price (Rp)"),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: 'Rp  0'),
                    validator: (v) {
                      if (v!.isEmpty) return "Price is required";
                      String digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                      if (digits.isEmpty) return "Invalid price format";
                      return null;
                    },
                  ),
                  const SizedBox(height: 44),

                  // --- ACTION BUTTON SAVE ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE64A19), // Orange Figma
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _saveMenu,
                      child: const Text(
                        'Save', 
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
    child: Text(
      text, 
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)
    ),
  );

  InputDecoration _inputDecoration({required String hint}) => InputDecoration(
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
  );
}