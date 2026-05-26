import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ProfilePage({super.key, this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggingOut = false;

  // --- LOGOUT FUNCTION (SYNCHRONIZED WITH GOROUTER) ---
  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);

    try {
      await http.post(
        Uri.parse("http://10.0.2.2:8000/api/logout"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.userData?['token']}',
        },
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint("Server error during logout: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic data fallback
    final String nama = widget.userData?['nama_user'] ?? "Admin";
    final String username = widget.userData?['username'] ?? "admin";
    final String namaToko = widget.userData?['nama_toko'] ?? "Seblak Say Cafe";
    final String alamatToko = widget.userData?['alamat_toko'] ?? "Jl. Seblak Say, Bandung";
    
    // SAFE USER ID CONVERSION (Fixes the USR-0 issue)
    final String idUser = widget.userData?['id_user']?.toString() ?? "1";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color.fromARGB(255, 194, 189, 188),
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(nama, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("@$username", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  // Edit Profile button has been removed from here
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildInfoCard(
              title: "Account Information",
              icon: Icons.person_outline,
              children: [
                _buildInfoItem("Full Name", nama),
                _buildDivider(),
                _buildInfoItem("Username", username),
                _buildDivider(),
                _buildInfoItem("User ID", "USR-$idUser"), // Safely prints database ID
              ],
            ),
            _buildInfoCard(
              title: "Store",
              icon: Icons.store_outlined,
              children: [
                _buildInfoItem("Store Name", namaToko),
                _buildDivider(),
                _buildInfoItem("Address", alamatToko),
              ],
            ),
            const SizedBox(height: 10),
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildInfoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        children: [
          Row(children: [
            Icon(icon, color: const Color(0xFFE64A19)), 
            const SizedBox(width: 10), 
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 15),
          ...children
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(color: Colors.grey[100]);

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _isLoggingOut 
        ? const CircularProgressIndicator(color: Colors.red)
        : TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), 
                      child: const Text("Cancel")
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); 
                        _handleLogout();        
                      }, 
                      child: const Text("Yes, Log Out", style: TextStyle(color: Colors.red))
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text("Log Out Account", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
    );
  }
}