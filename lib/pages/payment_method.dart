import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pos/providers/order_provider.dart';
import 'package:flutter_pos/utils/currency.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool loading = false;
  String? message;
  String? qrData;
  String? trxId;
  String? trxRefNo;
  Timer? _pollingTimer;
  bool paymentSuccess = false;

  Future<void> _payCash(String trx_nominal) async {
    setState(() {
      loading = true;
      message = null;
      qrData = null;
    });

    // simulasi hit API dummy
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      loading = false;
      message =
          "Pembayaran CASH berhasil.\nSilakan serahkan uang ke kasir sebesar $trx_nominal.";
    });
  }

  Future<void> _payQris(String trx_nominal) async {
    setState(() {
      loading = true;
      message = null;
      qrData = null;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://pay.wepos.id/req_qris'),
      );
      request.fields.addAll({
        'merchant_key': '1715361863-5058',
        'merchant_tipe': 'cafe',
        'trx_nominal': trx_nominal.toString(),
        'trx_ref_no': '2509010002',
      });

      var response = await request.send();
      var res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        // misal API mengembalikan field "qris_url" berupa link gambar qris
        setState(() {
          loading = false;
          qrData = data['trx_qris'] ?? '';
          trxId = data['trx_id'] ?? '';
          trxRefNo = '2509010002';
        });

        // mulai polling setelah QR ditampilkan
        _startPolling();
      } else {
        setState(() {
          loading = false;
          message = "Gagal request QRIS";
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        message = "Error: $e";
      });
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (trxId == null || trxRefNo == null) return;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://pay.wepos.id/cek_qris'),
      );
      request.fields.addAll({
        'merchant_key': '1715361863-5058',
        'merchant_tipe': 'cafe',
        'trx_id': trxId!,
        'trx_ref_no': trxRefNo!,
      });

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = json.decode(respStr);

      if (data['trx_status'] == 'paid') {
        timer.cancel();
        setState(() {
          paymentSuccess = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Pembayaran berhasil ✅")));
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = Provider.of<OrderProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Metode Pembayaran")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text("Cash"),
              onTap: () =>
                  _payCash(formatCurrency(order.total_price).toString()),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text("QRIS"),
              onTap: () => _payQris(order.total_price.toString()),
            ),
            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),
            if (message != null)
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (qrData != null && qrData!.isNotEmpty)
              Column(
                children: [
                  const Text(
                    "Silakan Scan QRIS di bawah ini",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  QrImageView(
                    data: qrData!, // isi dengan trx_qris dari API
                    version: QrVersions.auto,
                    size: 200.0,
                    errorStateBuilder: (cxt, err) {
                      return const Center(
                        child: Text(
                          "❌ Error generate QRIS.\nSilakan ulangi.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  paymentSuccess
                      ? const Text(
                          "✅ Pembayaran Sukses",
                          style: TextStyle(color: Colors.green, fontSize: 18),
                        )
                      : const Text(
                          "Menunggu pembayaran...",
                          style: TextStyle(color: Colors.orange),
                        ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
