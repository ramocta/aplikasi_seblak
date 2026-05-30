import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon; // 💡 Tambahkan parameter icon opsional di sini

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon, // 💡 Masukkan ke constructor
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  bool get _isDisabled => widget.onPressed == null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: _isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: _isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: _isDisabled ? null : widget.onPressed,
      child: MouseRegion(
        cursor: _isDisabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  color: _isDisabled
                      ? Colors.grey[350]
                      : _isPressed
                          ? const Color(0xFFDE3905).withOpacity(0.9)
                          : const Color(0xFFDE3905),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 💡 Menjaga isi button tetap di tengah
                  children: [
                    // 💡 Tampilkan ikon jika parameter icon tidak bernilai null
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 20,
                        // Warna ikon mengikuti status tombol (disabled / aktif)
                        color: _isDisabled ? Colors.grey[500] : const Color(0xFFEFEAEA),
                      ),
                      const SizedBox(width: 8), // 💡 Jarak konstan antara ikon dan teks
                    ],
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}