import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:go_router/go_router.dart';
import '../../controllers/order_controller.dart';

// --- PATH ASSETS ---
class AppAssets {
  static const String logo1 = "assets/images/logo1.png"; // putih
  static const String logo2 = "assets/images/logo2.png"; // merah
  static const String bannerPromo = "assets/images/banner.jpg"; 
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;
  String? _error;
  bool _isLoading = false;

  // --- FUNGSI LOGIN ORIGINAL (KODINGAN LAMA LU YANG BISA LOGIN) ---
  Future<void> _login() async {
    if (_username.text.isEmpty || _password.text.isEmpty) {
      setState(() => _error = "Username & Password wajib diisi!");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse("http://192.168.18.171:8000/api/admin/login"), // Dikembalikan ke localhost bawaan lu bang
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': _username.text.trim(),
          'password': _password.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final prefs = await SharedPreferences.getInstance();
        if (data['token'] != null) {
          await prefs.setString('token', data['token']);
        }

        if (mounted) {
          final orderController = Get.put(OrderController());
          await orderController.fetchDashboardStats();

          // Pindah screen pakai GoRouter
          context.go('/dashboard', extra: data['user']);
        }
      } else {
        setState(() => _error = "Username atau password salah!");
      }
    } catch (e) {
      setState(() => _error = "Koneksi gagal. Pastikan server Laravel jalan.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- CONTAINER MERAH STANDAR (Tinggi 200 Pas Sesuai Figma Kanan) ---
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE64A19),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Image.asset(
                      AppAssets.logo1,
                      height: 120, // Ukuran logo saycafe digedein di dalam box standar
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.restaurant_menu, size: 80, color: Colors.white);
                      },
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Teks Login Admin + Garis Oranje Menempel
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            "Login Admin", 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 1.5,
                            width: 75,
                            color: const Color(0xFFE64A19),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20), // Jarak proporsional ke inputan
                    
                    if (_error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                      ),
                    
                    // Input Username
                    _buildTextField("Username", _username, false, ""),
                    const SizedBox(height: 20), 
                    
                    // Input Password
                    _buildTextField("Password", _password, _hide, ""),
                    const SizedBox(height: 12),
                    
                    // View Password Checkbox
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: !_hide,
                            activeColor: const Color(0xFFE64A19),
                            side: const BorderSide(color: Colors.grey, width: 1.5),
                            onChanged: (v) => setState(() => _hide = !v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "view password", 
                          style: TextStyle(color: Colors.black87, fontSize: 14)
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    
                    // Tombol Login Oranje + Shadow Halus
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE64A19).withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE64A19),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "Login", 
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Textfield kustom pendukung background abu-abu #D9D9D9
  Widget _buildTextField(String label, TextEditingController controller, bool obscure, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.black87)
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9), 
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              border: InputBorder.none, 
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
            ),
          ),
        ),
      ],
    );
  }
}