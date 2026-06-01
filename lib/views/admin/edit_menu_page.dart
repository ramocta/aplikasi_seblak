import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:seblak_say_cafe/core/constans/api_constans.dart';
import '../../models/menu_models.dart';
import '../../controllers/menu_controller.dart' as getx;
import 'package:seblak_say_cafe/views/widgets/admin/edit_menu_photo_picker.dart';
import 'package:seblak_say_cafe/views/widgets/admin/edit_menu_form_fields.dart';
import 'package:seblak_say_cafe/views/widgets/admin/edit_menu_save_button.dart';

class EditMenuPage extends StatefulWidget {
  final MenuModels menu;

  const EditMenuPage({super.key, required this.menu});

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
    // Menggunakan widget.menu untuk mengakses data dari StatefulWidget
    _nameController = TextEditingController(text: widget.menu.nama);
    
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

      String cleanPrice = _priceController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');

      Map<String, dynamic> payload = {
        'nama_menu': _nameController.text.trim(),
        'id_kategori_menu': _selectedCategoryId.toString(),
        'harga': cleanPrice,
        'stok': _stockController.text.trim(),
        '_method': 'PUT', 
      };

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

      dio.Response response = await apiDio.post(
        "${ApiConstants.baseUrl}${ApiConstants.adminMenu}/${widget.menu.id}",
        data: formData,
        options: dio.Options(
          headers: {
            'Accept': 'application/json',
            'X-HTTP-Method-Override': 'PUT', // Penting untuk Laravel agar menangkap PUT
            if (tokenAdmin != null) 'Authorization': 'Bearer $tokenAdmin',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          try {
            if (Get.isRegistered<getx.MenuController>()) {
              Get.find<getx.MenuController>().clearCache();
            }
          } catch (e) {
            debugPrint("Cache GetX tidak ditemukan: $e");
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(backgroundColor: Colors.green, content: Text("Menu sukses diperbarui!")),
          );
          context.go('/menu_management'); 
        }
      } else {
        throw Exception("Gagal merespon server: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Gagal Menyimpan"),
            content: Text(e.toString()),
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
        title: const Text('Edit Menu', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/menu_management'), 
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  EditMenuPhotoPicker(
                    imageFile: _imageFile,
                    webImageBytes: _webImageBytes,
                    webImageName: _webImageName,
                    gambarUrl: widget.menu.gambarUrl,
                    onPickImage: _pickImage,
                  ),
                  const SizedBox(height: 20),
                  EditMenuFormFields(
                    nameController: _nameController,
                    priceController: _priceController,
                    stockController: _stockController,
                    selectedCategoryId: _selectedCategoryId,
                    categoriesMap: _categoriesMap,
                    onChangedCategory: (val) => setState(() => _selectedCategoryId = val),
                    nameValidator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
                    stockValidator: (v) => v!.isEmpty ? "Stok wajib diisi" : null,
                    priceValidator: (v) => v!.isEmpty ? "Harga wajib diisi" : null,
                  ),
                  EditMenuSaveButton(
                    isLoading: _isLoading,
                    onPressed: _saveChanges,
                  ),
                ],
              ),
            ),
          ),
    );
  }
}