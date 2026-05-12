import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/core/constans/app_color.dart';
import 'package:seblak_say_cafe/core/constans/app_assets.dart' show AppAssets;
import '../../controllers/order_controller.dart';
import 'package:seblak_say_cafe/views/widgets/header_clipper.dart';
// Import file tempat CustomButton berada
import 'package:seblak_say_cafe/views/widgets/custom_button.dart'; 

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER PUTIH DENGAN ELLIPS
          ClipPath(
            clipper: HeaderClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.38,
              color: AppColors.primary,
              child: Center(child: Image.asset(AppAssets.logo1, width: 400)),
            ),
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "How would you like to enjoy your order?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 30),

                  // OPSI PILIHAN
                  Row(
                    children: [
                      _buildOrderOption(
                        controller,
                        "Dine In",
                        Icons.local_dining,
                      ),
                      const SizedBox(width: 15),
                      _buildOrderOption(
                        controller,
                        "Take Away",
                        Icons.shopping_bag_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Fill in these ordering option before continuing. You'll enter a table number if you chose Dine in, and continue if you chose Take away.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),

                  const Spacer(),

                  // IMPLEMENTASI CUSTOM BUTTON
                  Obx(
                    () => Center( // Gunakan Center agar bayangan tombol tidak terpotong
                      child: Opacity(
                        // Memberikan efek visual jika tombol belum aktif
                        opacity: controller.isOrderTypeSelected ? 1.0 : 0.5,
                        child: CustomButton(
                          text: "Continue",
                          onPressed: controller.isOrderTypeSelected
                              ? () => context.push(controller.getNextRoute())
                              : () {
                                  // Feedback jika user klik saat belum pilih opsi
                                  Get.snackbar(
                                    "Pilih Opsi", 
                                    "Silahkan pilih Dine In atau Take Away",
                                    snackPosition: SnackPosition.BOTTOM
                                  );
                                },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderOption(
    OrderController controller,
    String type,
    IconData icon,
  ) {
    return Expanded(
      child: Obx(() {
        bool isSelected = controller.selectedOrderType.value == type;
        return GestureDetector(
          onTap: () => controller.selectType(type),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? Colors.yellow[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.orange : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.orange : Colors.black54,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}