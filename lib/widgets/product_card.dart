import 'package:flutter/material.dart';
import '../models/product.dart';
import 'qty_button.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final String priceText;

  const ProductCard({
    super.key,
    required this.product,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
    required this.priceText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardH = constraints.maxHeight;
          // bagi tinggi: ~55% untuk gambar, sisanya untuk konten
          final imageH = (cardH * 0.55).clamp(110.0, cardH * 0.65);
          final contentH = cardH - imageH;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: imageH,
                child: Ink.image(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                  child: InkWell(onTap: onAdd),
                ),
              ),
              // Gunakan Container dengan height tetap (agar tidak bergantung Expanded)
              Container(
                height: contentH,
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Info produk
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          priceText,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),

                    // Baris tombol
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        QtyButton(
                          icon: Icons.remove,
                          onTap: qty == 0 ? null : onRemove,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            qty.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        QtyButton(icon: Icons.add, onTap: onAdd),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
