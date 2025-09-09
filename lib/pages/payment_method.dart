import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pos/config/constants.dart';
import 'package:flutter_pos/providers/appid_provider.dart';
import 'package:flutter_pos/providers/order_provider.dart';
import 'package:flutter_pos/services/transaction_service.dart';
import 'package:flutter_pos/utils/currency.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentPage extends StatefulWidget {
  final int trxQr;

  const PaymentPage({super.key, required this.trxQr});

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

  Future<void> _payCash(
    AppIdProvider appid,
    OrderProvider order,
    trx_nominal,
  ) async {
    // ✅ Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Konfirmasi Pembayaran"),
          content: const Text(
            "Apakah anda akan membayar menggunakan cash/tunai?",
          ),
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

    if (confirm == true) {
      setState(() {
        loading = true;
        message = null;
        qrData = null;
      });

      final success = await TransactionService.updateTransaction(
        appid,
        order,
        widget.trxQr,
        'cash',
      );

      if (success) {
        setState(() {
          loading = false;
          messageWidget = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80, // ✅ agak besar
              ),
              const SizedBox(height: 16),
              Text(
                "Terima kasih\nSilakan melakukan pembayaran cash/tunai di kasir dengan total $trx_nominal.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          );
        });

        order.setNominal(nominal: 0);
      } else {
        setState(() {
          loading = false;
          messageWidget = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.close,
                color: Colors.red,
                size: 80, // ✅ agak besar
              ),
              const SizedBox(height: 16),
              Text(
                "Gagal memilih metode cash/tunai, silahkan ulangi kembali",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          );
        });
      }
    }
  }

  Future<void> _payQris(
    AppIdProvider appid,
    OrderProvider order,
    trx_nominal,
  ) async {
    // ✅ Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Konfirmasi Pembayaran"),
          content: const Text("Apakah anda akan membayar menggunakan Qris?"),
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

    if (confirm == true) {
      setState(() {
        loading = true;
        message = null;
        qrData = null;
      });

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConfig.payUrl}/req_qris'),
        );
        request.fields.addAll({
          'merchant_key': order.merchantKey,
          'merchant_tipe': 'cafe',
          'trx_nominal': trx_nominal.toString(),
          'trx_ref_no': widget.trxQr.toString(),
        });

        var response = await request.send();
        var res = await http.Response.fromStream(response);

        var data = json.decode(res.body);
        if (res.statusCode == 200 && data['success']) {
          var data = json.decode(res.body);

          await TransactionService.updateTransaction(
            appid,
            order,
            widget.trxQr,
            'qris',
          );
          // misal API mengembalikan field "qris_url" berupa link gambar qris
          setState(() {
            loading = false;
            qrData = data['trx_qris'] ?? '';
            trxId = data['trx_id'] ?? '';
            trxRefNo = widget.trxQr.toString();
          });

          order.setNominal(nominal: 0);

          // mulai polling setelah QR ditampilkan
          _startPolling(order);
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
  }

  void _startPolling(OrderProvider order) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (trxId == null || trxRefNo == null) return;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.payUrl}/cek_qris'),
      );
      request.fields.addAll({
        'merchant_key': order.merchantKey,
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

      if (data['trx_status'] == 'expire') {
        timer.cancel();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Qris Expired")));
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text(
          "Apakah anda yakin ingin mengakhiri sesi ini? Silahkan Lanjut ke kasir untuk melakukan pembayaran",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // batal
            child: const Text("Tidak"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true), // lanjut keluar
            child: const Text("Ya"),
          ),
        ],
      ),
    );

    return result ?? false; // default false kalau user dismiss dialog
  }

  Widget? messageWidget;

  @override
  Widget build(BuildContext context) {
    final appid = context.watch<AppIdProvider>();
    final order = context.watch<OrderProvider>();
    return PopScope(
      canPop: false, // mencegah pop otomatis
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          // Panggil fungsi untuk menampilkan dialog
          final shouldPop = await _onWillPop(context);

          // Jika user konfirmasi untuk keluar, lakukan pop manual
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Metode Pembayaran")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.money),
                title: const Text("Cash"),
                onTap: () => order.trx_nominal != 0
                    ? _payCash(
                        appid,
                        order,
                        formatCurrency(order.trx_nominal.toInt()),
                      )
                    : null,
              ),
              if (order.useQris == 1)
                ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: const Text("QRIS"),
                  onTap: () => order.trx_nominal != 0
                      ? _payQris(appid, order, order.trx_nominal.toString())
                      : null,
                ),
              const SizedBox(height: 20),
              if (loading) const CircularProgressIndicator(),
              messageWidget ?? const SizedBox(),
              if (qrData != null && qrData!.isNotEmpty)
                Column(
                  children: [
                    const Text(
                      "Silakan Scan QRIS di bawah ini",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 80, // ✅ agak besar
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Terima kasih\nPesanan anda sudah dibayar menggunakan QRIS: $trxRefNo",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
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
      ),
    );
  }
}
