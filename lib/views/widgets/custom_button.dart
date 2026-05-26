import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  // ✅ Ubah menjadi nullable agar bisa pass null untuk state disabled
  final VoidCallback? onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  // ✅ Button dianggap disabled jika onPressed null
  bool get _isDisabled => widget.onPressed == null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: _isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: _isDisabled ? null : () => setState(() => _isPressed = false),
      // ✅ onTap null saat disabled — tidak bisa diklik
      onTap: _isDisabled ? null : widget.onPressed,
      child: MouseRegion(
        cursor: _isDisabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          width: double.infinity,
          height: 52,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity,
                height: 48,
                decoration: ShapeDecoration(
                  // ✅ Warna abu-abu saat disabled, merah saat aktif
                  color: _isDisabled
                      ? Colors.grey[350]
                      : _isPressed
                          ? const Color(0xFFDE3905).withOpacity(0.9)
                          : const Color(0xFFDE3905),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    style: TextStyle(
                      // ✅ Warna teks lebih pudar saat disabled
                      color: _isDisabled
                          ? Colors.grey[500]
                          : const Color(0xFFEFEAEA),
                      fontSize: 16,
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w500,
                      letterSpacing: _isPressed ? 0.8 : 0.0,
                    ),
                    child: Text(widget.text),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}