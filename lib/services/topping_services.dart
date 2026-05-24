import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Untuk handle kIsWeb jika running di browser
import 'package:shared_preferences/shared_preferences.dart'; // Handle token auth admin
import 'package:seblak_say_cafe/core/api/api_client.dart';
import 'package:seblak_say_cafe/core/constans/api_constans.dart';
import '../models/topping_models.dart';
import '../models/kategori_topping_models.dart';

class ToppingService {
  // ==================== CUSTOMER / KASIR ====================

  /// Mengambil semua kategori topping
  Future<List<KategoriToppingModels>> getAllToppingCategories() async {
    try {
      final response = await ApiClient.dio.get(ApiConstants.kategoriTopping);

      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((json) => KategoriToppingModels.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Gagal mengambil kategori: ${e.response?.data['message'] ?? e.message}');
    }
  }

  /// Mengambil topping berdasarkan kategori
  Future<List<ToppingModels>> getToppingByCategory(int categoryId) async {
    try {
      final response = await ApiClient.dio.get(
        ApiConstants.topping,
        queryParameters: {'kategori': categoryId}, 
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((json) => ToppingModels.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Gagal mengambil topping: ${e.response?.data['message'] ?? e.message}');
    }
  }

  // ==================== ADMIN ONLY ====================

  /// Tambah Topping Baru (Admin) - MENGGUNAKAN FORMDATA (MULTIPART)
  Future<bool> addTopping(Map<String, dynamic> data) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? '';

      // 1. Bungkus data teks ke dalam FormData sesuai parameter Validator Laravel
      FormData formData = FormData.fromMap({
        'id_kategori_topping': data['id_kategori_topping'],
        'nama_topping': data['nama_topping'], // SINKRON: Sesuai nama_topping di Laravel
        'harga': data['harga'],
        'stok': data['stok'],
      });

      // 2. Jika user memilih file gambar, konversi menjadi MultipartFile
      if (data['gambar_file'] != null) {
        File file = data['gambar_file'];
        formData.files.add(MapEntry(
          'gambar', // Key harus sesuai dengan 'gambar' di Validator Laravel
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ));
      } else if (data['gambar_bytes'] != null) {
        // Antisipasi cadangan jika aplikasi di-run via Flutter Web Browser
        formData.files.add(MapEntry(
          'gambar',
          MultipartFile.fromBytes(
            data['gambar_bytes'],
            filename: 'topping_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      }

      // 3. Eksekusi POST request ke Laravel API
      final response = await ApiClient.dio.post(
        ApiConstants.adminTopping, 
        data: formData,
        options: Options(
          headers: {
            if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            'Accept': 'application/json', // Menolak mentah-mentah return HTML jika ada error internal
          },
        ),
      );
      
      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
       if (e.response != null) {
         print("❌ DETAIL VALIDASI GAGAL LARAVEL (POST): ${e.response?.data}");
       }
       throw Exception('Gagal menambah topping: ${e.response?.data['message'] ?? e.message}');
    }
  }

  /// Update Topping Lama (Admin) - MENGGUNAKAN FORMDATA + SPOOFING METHOD_PUT
  Future<bool> updateTopping(int id, Map<String, dynamic> data) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? '';

      // TRICK PENTING LARAVEL: Upload file di Laravel via PUT method sering kali bermasalah/kosong.
      // Solusi terbaiknya adalah mengirim POST request, tapi disisipkan field '_method': 'PUT' (Method Spoofing).
      FormData formData = FormData.fromMap({
        '_method': 'PUT', 
        'id_kategori_topping': data['id_kategori_topping'],
        'nama_topping': data['nama_topping'],
        'harga': data['harga'],
        'stok': data['stok'],
      });

      // Validasi file gambar jika ada perubahan foto baru
      if (data['gambar_file'] != null) {
        File file = data['gambar_file'];
        formData.files.add(MapEntry(
          'gambar',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ));
      } else if (data['gambar_bytes'] != null) {
        formData.files.add(MapEntry(
          'gambar',
          MultipartFile.fromBytes(
            data['gambar_bytes'],
            filename: 'topping_update_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      }

      // Endpoint diarahkan menggunakan POST karena sudah dicarry oleh '_method': 'PUT' di atas
      final response = await ApiClient.dio.post(
        '${ApiConstants.adminTopping}/$id', 
        data: formData,
        options: Options(
          headers: {
            if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      
      return response.statusCode == 200;
    } on DioException catch (e) {
       if (e.response != null) {
         print("❌ DETAIL VALIDASI GAGAL LARAVEL (PUT): ${e.response?.data}");
       }
       throw Exception('Gagal update topping: ${e.response?.data['message'] ?? e.message}');
    }
  }

  /// Hapus Topping Permanen (Admin)
  Future<bool> deleteTopping(int id) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? '';

      print("🔑 Request DELETE Topping ID: $id dengan Token: Bearer $token");

      final response = await ApiClient.dio.delete(
        '${ApiConstants.adminTopping}/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
       print("❌ Error deleteTopping: ${e.response?.data ?? e.message}");
       throw Exception('Gagal menghapus topping: ${e.response?.data['message'] ?? e.message}');
    }
  }
}