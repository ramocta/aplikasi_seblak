import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../controllers/cart_controller.dart';
import '../../widgets/custom_button.dart';

class CheckoutSection extends StatelessWidget {
  final CartController cartController;

  const CheckoutSection({super.key, required this.cartController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Obx(
                () => Text(
                  "Rp. ${cartController.totalPrice}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDE3905),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: "Checkout",
            onPressed: () {
              if (cartController.cartItems.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Opps.. Your cart is empty!"),
                    backgroundColor: Color(0xFFDE3905),
                  ),
                );
                return;
              }
              context.push('/checkout');
            },
          ),
        ],
      ),
    );
  }
}
