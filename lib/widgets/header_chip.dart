import 'package:flutter/material.dart';

class HeaderChipRow {
  final IconData icon;
  final String label;
  final Widget child;

  HeaderChipRow({required this.icon, required this.label, required this.child});
}

class HeaderChip extends StatelessWidget {
  final List<HeaderChipRow> rows;

  const HeaderChip({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(row.icon, size: 18),
                const SizedBox(width: 8),
                Text(
                  row.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                row.child,
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
