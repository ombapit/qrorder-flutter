import 'package:flutter/material.dart';
import 'package:flutter_pos/pages/payment_method.dart';
import 'package:flutter_pos/providers/appid_provider.dart';
import 'package:flutter_pos/services/transaction_service.dart';
import 'package:flutter_pos/utils/currency.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appid = Provider.of<AppIdProvider>(context);
    final order = Provider.of<OrderProvider>(context);

    final nameController = TextEditingController(text: order.buyerName);
    final phoneController = TextEditingController(text: order.buyerPhone);

    // biar cursor tetap di akhir teks
    nameController.selection = TextSelection.fromPosition(
      TextPosition(offset: nameController.text.length),
    );
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: phoneController.text.length),
    );

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
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nama"),
              onChanged: (val) => order.setBuyerInfo(name: val),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "No. HP",
                prefixText: "+62 ", // 👈 prefix otomatis
              ),
              keyboardType: TextInputType.phone,
              onChanged: (val) => order.setBuyerInfo(phone: val),
              // onChanged: (val) {
              //   // val hanya berisi angka setelah +62
              //   order.setBuyerInfo(phone: "+62$val");
              // },
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
                subtitle: Text("Qty: ${c.qty} x ${formatCurrency(c.subtotal)}"),
                trailing: Text(formatCurrency(c.subtotal)),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Total: ${formatCurrency(order.total_price)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Pb1 10%: ${formatCurrency(order.total_tax.toInt())}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Service: ${formatCurrency(order.total_service.toInt())}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Grand Total: ${formatCurrency(order.trx_nominal.toInt())}",
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

                      // ✅ Jika user pilih "Ya, Lanjut" → ke payment page
                      if (confirm == true) {
                        // Insert transaction to API
                        final success =
                            await TransactionService.insertTransaction(
                              appid,
                              order,
                            );

                        if (success != null) {
                          // Clear cart after successful API call
                          order.clearCart();

                          // Navigate to payment page
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentPage(trxQr: success),
                            ),
                            (Route<dynamic> route) => route
                                .isFirst, // sisain route pertama (HomePage)
                          );

                          // Close loading dialog
                          // Navigator.of(context).pop();
                        } else {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Gagal menyimpan transaksi. Silakan coba lagi.",
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
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
