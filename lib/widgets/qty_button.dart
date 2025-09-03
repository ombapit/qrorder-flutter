import 'package:flutter/material.dart';

class QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const QtyButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onTap,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
