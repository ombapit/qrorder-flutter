import 'package:flutter/material.dart';
import '../models/product.dart';
import 'qty_button.dart';

class ProductListTile extends StatelessWidget {
  final Product product;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final String priceText;

  const ProductListTile({
    super.key,
    required this.product,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
    required this.priceText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(product.imageUrl, width: 64, height: 64, fit: BoxFit.cover),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(priceText),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            QtyButton(icon: Icons.remove, onTap: qty == 0 ? null : onRemove),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(qty.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            QtyButton(icon: Icons.add, onTap: onAdd),
          ],
        ),
        onTap: onAdd,
      ),
    );
  }
}
