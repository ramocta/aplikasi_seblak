import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Akun",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Title
                      const Text(
                        "Profil",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Avatar
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage("assets/profile.jpg"),
                      ),

                      const SizedBox(height: 12),

                      // Name
                      const Text(
                        "Udin Starboy",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        "udinstarboy@seblaksaycafe.com",
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 12),

                      // Edit Button
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Edit Profile",
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Account Information Card
                      _buildCard(
                        title: "Account Information",
                        icon: Icons.person,
                        children: const [
                          _InfoItem(label: "Name", value: "Udin Starboy"),
                          _InfoItem(
                              label: "Email",
                              value: "udinstarboy@seblaksaycafe.com"),
                          _InfoItem(
                              label: "Phone", value: "+62 812 3456 789"),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Store Information Card
                      _buildCard(
                        title: "Store Information",
                        icon: Icons.store,
                        children: const [
                          _InfoItem(
                              label: "Store Name",
                              value: "Seblak Say Cafe"),
                          _InfoItem(
                              label: "Address",
                              value: "Jl. Seblak No. 123"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Navigation
            Container(
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 5)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _NavItem(icon: Icons.home, label: "Home"),
                  _NavItem(icon: Icons.receipt, label: "Orders"),
                  _NavItem(icon: Icons.menu_book, label: "Menu"),
                  _NavItem(icon: Icons.list_alt, label: "Topping"),
                  _NavItem(
                    icon: Icons.person,
                    label: "Profile",
                    isActive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(children: children),
        ],
      ),
    );
  }
}

// Info Item
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// Bottom Nav Item
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? Colors.orange : Colors.grey),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.orange : Colors.grey,
          ),
        ),
      ],
    );
  }
}