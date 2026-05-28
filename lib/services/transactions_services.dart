import 'dart:io';
import 'package:image_picker/image_picker.dart'; // ✅ untuk XFile
import 'package:dio/dio.dart';
import 'package:seblak_say_cafe/core/constans/api_constans.dart';
import 'package:seblak_say_cafe/core/api/api_client.dart';
import '../models/transaction_models.dart';
import '../models/transaction_detail_models.dart';

class TransactionService {
 Future<TransactionModel> checkout({
  required String namaPemesan,
  String? noMeja,
  required String opsiPemesanan,
  required String paymentMethod,
  required List<Map<String, dynamic>> items,
  File? imageProof,
  XFile? imageProofXFile, // ✅ Tambah parameter ini untuk web
}) async {
  try {
    Response response;

    if (paymentMethod == 'qris') {
      final Map<String, dynamic> flatData = {
        'nama_pemesan': namaPemesan,
        'opsi_pemesanan': opsiPemesanan,
        'payment_method': paymentMethod,
        if (noMeja != null) 'no_meja': noMeja,
      };

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        flatData['items[$i][id_menu]'] = item['id_menu'].toString();
        flatData['items[$i][qty]'] = item['qty'].toString();

        final toppings = item['toppings'] as List? ?? [];
        for (int j = 0; j < toppings.length; j++) {
          flatData['items[$i][toppings][$j][id_topping]'] =
              toppings[j]['id_topping'].toString();
          flatData['items[$i][toppings][$j][qty]'] =
              toppings[j]['qty'].toString();
        }
      }

      // ✅ Gunakan XFile untuk upload — work di web dan mobile
      final fileToUpload = imageProofXFile ?? (imageProof != null
          ? XFile(imageProof.path)
          : null);

      if (fileToUpload != null) {
        final bytes = await fileToUpload.readAsBytes();
        final fileName = fileToUpload.name;

        flatData['proof_payment'] = MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        );
      }

      final FormData formData = FormData.fromMap(flatData);

      response = await ApiClient.dio.post(
        ApiConstants.checkout,
        data: formData,
        options: Options(headers: {'Accept': 'application/json'}),
      );
    } else {
      response = await ApiClient.dio.post(
        ApiConstants.checkout,
        data: {
          'nama_pemesan': namaPemesan,
          'opsi_pemesanan': opsiPemesanan,
          'payment_method': paymentMethod,
          if (noMeja != null) 'no_meja': noMeja,
          'items': items,
        },
        options: Options(headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        }),
      );
    }

    if (response.statusCode == 201) {
      return TransactionModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Gagal membuat pesanan.');
  } on DioException catch (e) {
  // ✅ Tambah ini untuk lihat detail error
  print("❌ Status: ${e.response?.statusCode}");
  print("❌ Response: ${e.response?.data}");
  print("❌ Message: ${e.message}");
  
  final message = e.response?.data?['message'] ??
      e.response?.data?['errors']?.toString() ??
      'Terjadi kesalahan jaringan.';
  throw Exception(message);
}
}

  // ✅ Tambah method ini di TransactionService
Future<TransactionDetailModel> getTransactionDetailCustomer(int id) async {
  try {
    final response = await ApiClient.dio.get(
      '${ApiConstants.transactionDetailCustomer}/$id',
      options: Options(
        headers: {'Accept': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      return TransactionDetailModel.fromJson(response.data['data']);
    }
    throw Exception('Gagal memuat detail transaksi.');
  } on DioException catch (e) {
    throw Exception(
      e.response?.data?['message'] ?? 'Gagal menghubungi server.',
    );
  }
}


  Future<TransactionDetailModel> getTransactionDetail(int id) async {
    try {
      final response = await ApiClient.dio.get(
        "${ApiConstants.transactionDetail}/$id",
      );

      if (response.statusCode == 200) {
        return TransactionDetailModel.fromJson(response.data['data']);
      }
      throw Exception('Gagal memuat detail transaksi.');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal menghubungi server.');
    }
  }

  Future<bool> applyTransaction(int id) async {
    try {
      final response = await ApiClient.dio.post(
        "${ApiConstants.applyTransaction}/$id/apply",
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error Apply Transaction: $e");
      return false;
    }
  }

  Future<bool> rejectTransaction(int id) async {
    try {
      final response = await ApiClient.dio.post(
        "${ApiConstants.rejectTransaction}/$id/reject",
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error Reject Transaction: $e");
      return false;
    }
  }
}