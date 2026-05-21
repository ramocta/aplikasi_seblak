import 'package:dio/dio.dart';
import 'package:seblak_say_cafe/core/api/api_client.dart';
import 'package:seblak_say_cafe/core/constans/api_constans.dart';
import '../models/menu_models.dart';
import '../models/kategori_menu_models.dart';

class MenuService {
  // ==================== CUSTOMER / KASIR ====================

  /// Mengambil semua kategori menu
  Future<List<KategoriMenuModels>> getAllCategories() async {
    try {
      final response = await ApiClient.dio.get(
        ApiConstants.kategoriMenu,
      ).timeout(const Duration(seconds: 15));

      print('✅ Get Categories Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((json) => KategoriMenuModels.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print("❌ Error getAllCategories: ${e.response?.data ?? e.message}");
      throw Exception(
        'Gagal mengambil kategori: ${e.response?.data['message'] ?? e.message}',
      );
    } catch (e) {
      print("❌ Unexpected error getAllCategories: $e");
      throw Exception('Terjadi kesalahan saat mengambil kategori');
    }
  }

  /// Mengambil menu berdasarkan kategori
  Future<List<MenuModels>> getMenuByCategory(int categoryId) async {
    try {
      final response = await ApiClient.dio
          .get(ApiConstants.menu, queryParameters: {'kategori': categoryId})
          .timeout(const Duration(seconds: 15));

      print('✅ Get Menu Category $categoryId Status: ${response.statusCode}');
      print('Data length: ${(response.data['data'] as List?)?.length ?? 0}');

      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((json) => MenuModels.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print("❌ Error getMenuByCategory: ${e.response?.data ?? e.message}");
      throw Exception(
        'Gagal mengambil menu: ${e.response?.data['message'] ?? e.message}',
      );
    } catch (e) {
      print("❌ Unexpected error getMenuByCategory: $e");
      throw Exception('Terjadi kesalahan saat mengambil menu');
    }
  }

  // ==================== ADMIN ONLY ====================

  /// Menambah Menu Baru (Admin)
  Future<bool> addMenu(Map<String, dynamic> menuData) async {
    try {
      final response = await ApiClient.dio.post(
        ApiConstants.adminMenu,
        data: menuData,
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      print("❌ Error addMenu: ${e.response?.data ?? e.message}");
      throw Exception(
        'Gagal menambah menu: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  /// Update Menu (Admin)
  Future<bool> updateMenu(int id, Map<String, dynamic> updatedData) async {
    try {
      final response = await ApiClient.dio.put(
        '${ApiConstants.adminMenu}/$id',
        data: updatedData,
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print("❌ Error updateMenu: ${e.response?.data ?? e.message}");
      throw Exception(
        'Gagal update menu: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  /// Hapus Menu (Admin)
  Future<bool> deleteMenu(int id) async {
    try {
      final response = await ApiClient.dio.delete(
        '${ApiConstants.adminMenu}/$id',
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("❌ Error deleteMenu: ${e.response?.data ?? e.message}");
      throw Exception(
        'Gagal menghapus menu: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }
}
