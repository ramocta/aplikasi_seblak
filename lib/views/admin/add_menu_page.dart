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
        "http://localhost:8000/api/admin/menu", 
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
                  const Text(
                    'upload menu photo', 
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black)
                  ),
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
                      String digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                      if (digits.isEmpty) return "Invalid price format";
                      return null;
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