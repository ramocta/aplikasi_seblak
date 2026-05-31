import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/cart_controller.dart';
import '../cart_components/cart_header.dart';
import '../cart_components/cart_action_bar.dart';
import '../cart_components/cart_list_section.dart';
import '../cart_components/checkout_section.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  final CartController cartController = Get.find<CartController>();
  final RxString activeMode = ''.obs;
  final RxInt selectedIndex = (-1).obs;

  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  void _showValidationDialog({
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              selectedIndex.value = -1;
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onConfirm();
                selectedIndex.value = -1;
              });
            },
            child: Text(
              confirmText,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: CartHeader(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CartActionBar(
            activeMode: activeMode,
            blinkAnimation: _blinkAnimation,
            onEditPressed: () {
              activeMode.value = activeMode.value == 'edit' ? '' : 'edit';
              selectedIndex.value = -1;
            },
            onDeletePressed: () {
              activeMode.value = activeMode.value == 'delete' ? '' : 'delete';
              selectedIndex.value = -1;
            },
          ),
          const SizedBox(height: 10),
          CartListSection(
            cartController: cartController,
            activeMode: activeMode,
            selectedIndex: selectedIndex,
            showValidationDialog: _showValidationDialog,
          ),
          CheckoutSection(cartController: cartController),
        ],
      ),
    );
  }
}
