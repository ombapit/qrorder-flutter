import 'package:flutter/material.dart';
import 'package:flutter_pos/pages/payment_method.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final order = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Form pembeli
            const Text(
              "Informasi Pembeli",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Nama"),
              onChanged: (val) => order.setBuyerInfo(name: val),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: "No. HP",
                prefixText: "+62 ", // 👈 prefix otomatis
              ),
              keyboardType: TextInputType.phone,
              onChanged: (val) {
                // val hanya berisi angka setelah +62
                order.setBuyerInfo(phone: "+62$val");
              },
            ),

            const Divider(),

            // Ringkasan Pesanan
            const Text(
              "Ringkasan Pesanan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...order.cart.values.map(
              (c) => ListTile(
                title: Text(c.product.name),
                subtitle: Text(
                  "Qty: ${c.qty} x Rp ${c.product.price.toStringAsFixed(0)}",
                ),
                trailing: Text("Rp ${c.subtotal.toStringAsFixed(0)}"),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Total: Rp ${order.total_price.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Konfirmasi
            FilledButton.icon(
              onPressed:
                  order.cart.isEmpty ||
                      order.buyerName.isEmpty ||
                      (order.buyerPhone.isEmpty || order.buyerPhone == '+62')
                  ? () {
                      // error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Keranjang/Nama/No HP Kosong"),
                          backgroundColor: Colors.red, // 🔴 warna merah
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : () async {
                      // ✅ Tampilkan dialog konfirmasi
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: const Text("Konfirmasi Pesanan"),
                            content: const Text("Apakah pesanan sudah sesuai?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text("Batal"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text("Ya, Lanjut"),
                              ),
                            ],
                          );
                        },
                      );

                      // ✅ Jika user pilih "Ya, Lanjut" → pindah ke PaymentPage
                      if (confirm == true) {
                        // hapus nilai provider
                        order.clearCart();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentPage(),
                          ),
                        );
                      }
                    },
              icon: const Icon(Icons.check_circle),
              label: const Text("Konfirmasi Pesanan"),
            ),
          ],
        ),
      ),
    );
  }
}
