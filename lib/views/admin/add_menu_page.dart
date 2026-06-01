import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_lib;
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:seblak_say_cafe/core/constans/api_constans.dart';
import '../../controllers/menu_controller.dart' as getx; 
import 'package:seblak_say_cafe/views/widgets/admin/add_menu_photo_picker.dart';
import 'package:seblak_say_cafe/views/widgets/admin/add_menu_form_fields.dart';
import 'package:seblak_say_cafe/views/widgets/admin/add_menu_save_button.dart';

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
    
    if (kIsWeb ? (_webImageBytes == null) : (_imageFile == null)) {
      _showSnackBar("Foto menu wajib diupload!", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      dio_lib.Dio apiDio = dio_lib.Dio();
      final prefs = await SharedPreferences.getInstance();
      String? tokenAdmin = prefs.getString('token');
      
      String cleanPrice = _priceController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');

      // Membuat FormData
      dio_lib.FormData formData = dio_lib.FormData.fromMap({
        'nama_menu': _nameController.text.trim(),
        'id_kategori_menu': _selectedCategoryId.toString(),
        'harga': cleanPrice,
        'stok': _stockController.text.trim(),
        'gambar': kIsWeb 
            ? dio_lib.MultipartFile.fromBytes(_webImageBytes!, filename: _webImageName ?? 'menu.jpg')
            : await dio_lib.MultipartFile.fromFile(_imageFile!.path, filename: _imageFile!.path.split('/').last),
      });

      var response = await apiDio.post(
        "${ApiConstants.baseUrl}${ApiConstants.adminMenu}",
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

        // Refresh cache GetX
        if (Get.isRegistered<getx.MenuController>()) {
          Get.find<getx.MenuController>().clearCache();
        }

        _showSnackBar("Berhasil menyimpan menu baru!", Colors.green);
        context.canPop() ? context.pop() : context.go('/menu_management');
      } else {
        throw Exception("Gagal menyimpan: ${response.statusCode} - ${response.data}");
      }
    } catch (e) {
      if (mounted) _showSnackBar(e.toString().replaceAll("Exception:", ""), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text('Add Menu', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.canPop() ? context.pop() : context.go('/menu_management'),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD84315)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Upload Menu Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  AddMenuPhotoPicker(
                    imageFile: _imageFile,
                    webImageBytes: _webImageBytes,
                    webImageName: _webImageName,
                    onPickImage: _pickImage,
                  ),
                  AddMenuFormFields(
                    nameController: _nameController,
                    priceController: _priceController,
                    stockController: _stockController,
                    selectedCategoryId: _selectedCategoryId,
                    categoriesMap: _categoriesMap,
                    onChangedCategory: (val) => setState(() => _selectedCategoryId = val),
                    nameValidator: (v) => v!.trim().isEmpty ? "Menu name is required" : null,
                    stockValidator: (v) => v!.trim().isEmpty ? "Required" : null,
                    priceValidator: (v) {
                      if (v!.isEmpty) return "Price is required";
                      return v.replaceAll(RegExp(r'[^0-9]'), '').isEmpty ? "Invalid format" : null;
                    },
                  ),
                  AddMenuSaveButton(onPressed: _saveMenu),
                ],
              ),
            ),
          ),
    );
  }
}