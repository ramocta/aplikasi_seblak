import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../models/topping_models.dart'; 
import '../../controllers/topping_controller.dart'; 

class EditToppingPage extends StatefulWidget {
  final ToppingModels topping; 

  const EditToppingPage({
    super.key,
    required this.topping,
  });

  @override
  State<EditToppingPage> createState() => _EditToppingPageState();
}

class _EditToppingPageState extends State<EditToppingPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  
  late int _selectedCategoryId; 
  
  File? _imageFile;
  Uint8List? _webImageBytes;
  String? _webImageName;
  bool _isLoading = false;

  final Map<String, int> _categoryMap = {
    'Kerupuk': 1,
    'Frozen Food': 2,
    'Other': 3,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.topping.nama);
    _priceController = TextEditingController(text: widget.topping.harga.toString());
    _stockController = TextEditingController(text: widget.topping.stok.toString());
    
    String kategoriNama = widget.topping.kategoritopping?.nama ?? 'Kerupuk';
    _selectedCategoryId = _categoryMap[kategoriNama] ?? _categoryMap.values.first;
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
      String cleanPrice = _priceController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');

      Map<String, dynamic> payload = {
        'id_kategori_topping': _selectedCategoryId.toString(),
        'nama_topping': _nameController.text.trim(),
        'harga': cleanPrice,
        'stok': _stockController.text.trim(),
        '_method': 'PUT', 
      };

      if (kIsWeb && _webImageBytes != null) {
        payload['gambar'] = dio.MultipartFile.fromBytes(_webImageBytes!, filename: _webImageName ?? 'update_topping.jpg');
      } else if (!kIsWeb && _imageFile != null) {
        payload['gambar'] = await dio.MultipartFile.fromFile(_imageFile!.path, filename: _imageFile!.path.split('/').last);
      }

      dio.FormData formData = dio.FormData.fromMap(payload);

      dio.Response response = await apiDio.post(
        "http://localhost:8000/api/admin/topping/${widget.topping.id}",
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
          try {
            if (Get.isRegistered<ToppingController>()) {
              Get.find<ToppingController>().refreshData(); 
            }
          } catch (e) { print("Gagal refresh data: $e"); }

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Topping sukses diperbarui!")));
          context.go('/topping_management'); 
        }
      } else {
        throw Exception("Gagal merespon server: Code ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Gagal Menyimpan"),
            content: Text(e.toString().replaceAll("Exception:", "")),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Edit Topping', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.canPop() ? context.pop() : context.go('/topping_management'),
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
                  const Text('Upload Foto Topping', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                : (widget.topping.gambarUrl.isNotEmpty && widget.topping.gambarUrl.startsWith('http'))
                                    ? DecorationImage(image: NetworkImage(widget.topping.gambarUrl), fit: BoxFit.cover)
                                    : null,
                      ),
                      child: _webImageBytes == null && _imageFile == null && (!widget.topping.gambarUrl.startsWith('http'))
                          ? const Center(child: Icon(Icons.camera_alt, size: 40, color: Colors.grey))
                          : const Stack(children: [Positioned(bottom: 12, right: 12, child: CircleAvatar(backgroundColor: Colors.white, radius: 18, child: Icon(Icons.edit, size: 16, color: Color(0xFFE64A19))))]),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Nama Topping"),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration(),
                    validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
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
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _selectedCategoryId,
                                  isExpanded: true,
                                  onChanged: (val) => setState(() => _selectedCategoryId = val!),
                                  items: _categoryMap.entries.map((e) => DropdownMenuItem(value: e.value, child: Text(e.key))).toList(),
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
                    validator: (v) => v!.isEmpty ? "Harga wajib diisi" : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE64A19), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: _saveChanges,
                      child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)));

  InputDecoration _inputDecoration() => InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE64A19), width: 1.5)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
  );
}