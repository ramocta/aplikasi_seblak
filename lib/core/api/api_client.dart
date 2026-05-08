import 'package:dio/dio.dart';
import '../constans/app_constans.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      // Contoh jika menggunakan Emulator Android
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  static Dio get dio => _dio;
}
