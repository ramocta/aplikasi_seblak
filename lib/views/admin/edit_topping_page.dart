import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:seblak_say_cafe/core/constans/api_constans.dart';
import '../../models/topping_models.dart';
import '../../controllers/topping_controller.dart';
import 'package:seblak_say_cafe/views/widgets/admin/edit_topping_photo_picker.dart';
import 'package:seblak_say_cafe/views/widgets/admin/edit_topping_form_fields.dart';
import 'package:seblak_say_cafe/views/widgets/admin/edit_topping_save_button.dart';

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
        // Menggabungkan baseUrl dan endpoint adminTopping
        "${ApiConstants.baseUrl}${ApiConstants.adminTopping}/${widget.topping.id}",
        data: formData,
        options: dio.Options(
          headers: {
            'Accept': 'application/json',
            // Jika Anda melakukan update gambar via POST di Laravel, 
            // terkadang perlu menambahkan method override jika API Anda bersifat PUT/PATCH
            'X-HTTP-Method-Override': 'PUT', 
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
                  EditToppingPhotoPicker(
                    imageFile: _imageFile,
                    webImageBytes: _webImageBytes,
                    webImageName: _webImageName,
                    gambarUrl: widget.topping.gambarUrl,
                    onPickImage: _pickImage,
                  ),
                  const SizedBox(height: 20),
                  EditToppingFormFields(
                    nameController: _nameController,
                    priceController: _priceController,
                    stockController: _stockController,
                    selectedCategoryId: _selectedCategoryId,
                    categoryMap: _categoryMap,
                    onChangedCategory: (val) => setState(() => _selectedCategoryId = val),
                  ),
                  const SizedBox(height: 32),
                  EditToppingSaveButton(onPressed: _saveChanges),
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