import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartActionBar extends StatelessWidget {
  final RxString activeMode;
  final Animation<double> blinkAnimation;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const CartActionBar({
    super.key,
    required this.activeMode,
    required this.blinkAnimation,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  Widget _buildActionIcon(
    IconData icon,
    Color color,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isActive ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: isActive ? color : Colors.grey, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Obx(() {
        final bool modeActive = activeMode.value.isNotEmpty;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-0.2, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: modeActive
                    ? AnimatedBuilder(
                        key: ValueKey(activeMode.value),
                        animation: blinkAnimation,
                        builder: (context, child) => Opacity(
                          opacity: blinkAnimation.value,
                          child: child,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              activeMode.value == 'edit'
                                  ? Icons.edit
                                  : Icons.delete,
                              size: 13,
                              color: const Color(0xFFDE3905),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              activeMode.value == 'edit'
                                  ? "Click on the menu you want to edit.."
                                  : "Click on the menu you want to delete..",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFDE3905),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(key: ValueKey('empty')),
              ),
            ),
            Row(
              children: [
                Obx(() {
                  final bool isEditActive = activeMode.value == 'edit';
                  return _buildActionIcon(
                    Icons.edit,
                    Colors.red,
                    isEditActive,
                    onEditPressed,
                  );
                }),
                const SizedBox(width: 10),
                Obx(() {
                  final bool isDeleteActive = activeMode.value == 'delete';
                  return _buildActionIcon(
                    Icons.delete,
                    Colors.red,
                    isDeleteActive,
                    onDeletePressed,
                  );
                }),
              ],
            ),
          ],
        );
      }),
    );
  }
}
