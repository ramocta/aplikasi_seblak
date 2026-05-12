import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/core/constans/app_color.dart';
import 'package:seblak_say_cafe/core/constans/app_assets.dart' show AppAssets;
import '../../controllers/order_controller.dart';
import 'package:seblak_say_cafe/views/widgets/header_clipper.dart';
import 'package:seblak_say_cafe/views/widgets/custom_button.dart';

class TableNumberScreen extends StatelessWidget {
  const TableNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();

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
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(AppAssets.logo1, width: 400),
                  ),
                  Positioned(
                    top: 50,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ],
              ),
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
                    "Enter your table number", 
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // INPUT NOMOR MEJA
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      // ✅ DIGANTI DENGAN setTableNumber
                      onChanged: (value) => controller.setTableNumber(value),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Please enter the number listed on your table. This helps our team deliver your Seblak faster!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),

                  const Spacer(),

                  // BUTTON
                  Obx(() {
                    final bool isReady = controller.isTableNumberValid;

                    return Center(
                      child: Opacity(
                        opacity: isReady ? 1.0 : 0.5,
                        child: CustomButton(
                          text: "Save",
                          onPressed: isReady 
                            ? () => context.push('/menu') 
                            : () {
                                Get.snackbar(
                                  "Input Meja", 
                                  "Silahkan isi nomor meja yang valid (1-20)",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.redAccent,
                                  colorText: Colors.white,
                                );
                              },
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}