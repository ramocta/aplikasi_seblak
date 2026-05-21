import 'package:dio/dio.dart';
import 'package:seblak_say_cafe/core/api/api_client.dart';
import 'package:seblak_say_cafe/core/constans/api_constans.dart';
import '../models/kategori_topping_models.dart';
import '../models/topping_models.dart';

class ToppingService {
  /// Mengambil semua kategori topping
  Future<List<KategoriToppingModels>> getAllCategories() async {
    try {
      final response = await ApiClient.dio.get(
        ApiConstants.kategoriTopping,
      ). timeout(const Duration(seconds: 15));// Gunakan constant jika ada

      print('✅ Get Topping Categories Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data
            .map((json) => KategoriToppingModels.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print("❌ Error getAllCategories: ${e.response?.data ?? e.message}");
      throw Exception(
        'Gagal mengambil kategori topping: ${e.response?.data['message'] ?? e.message}',
      );
    } catch (e) {
      print("❌ Unexpected error getAllCategories: $e");
      throw Exception('Terjadi kesalahan saat mengambil kategori topping');
    }
  }

  /// Mengambil topping berdasarkan kategori
  Future<List<ToppingModels>> getToppingByCategory(int categoryId) async {
    try {
      final response = await ApiClient.dio
          .get(ApiConstants.topping, queryParameters: {'kategori': categoryId})
          .timeout(const Duration(seconds: 15));

      print(
        '✅ Get Topping Category $categoryId Status: ${response.statusCode}',
      );
      print('Data length: ${(response.data['data'] as List?)?.length ?? 0}');

      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((json) => ToppingModels.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print("❌ Error getToppingByCategory: ${e.response?.data ?? e.message}");
      throw Exception(
        'Gagal mengambil topping: ${e.response?.data['message'] ?? e.message}',
      );
    } catch (e) {
      print("❌ Unexpected error getToppingByCategory: $e");
      throw Exception('Terjadi kesalahan saat mengambil topping');
    }
  }
}
