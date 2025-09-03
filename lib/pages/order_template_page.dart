import 'package:flutter/material.dart';
import 'package:flutter_pos/pages/checkout_page.dart';
import 'package:flutter_pos/providers/appid_provider.dart';
import 'package:flutter_pos/providers/order_provider.dart';
import 'package:flutter_pos/services/outlet_service.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../widgets/header_chip.dart';
import '../widgets/product_card.dart';
import '../widgets/product_list_tile.dart';
import '../utils/currency.dart';
import '../services/product_service.dart';

class OrderTemplatePage extends StatefulWidget {
  const OrderTemplatePage({super.key});

  @override
  State<OrderTemplatePage> createState() => _OrderTemplatePageState();
}

class _OrderTemplatePageState extends State<OrderTemplatePage> {
  final ProductService _productService = ProductService();
  final OutletService _outletService = OutletService();
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _fetchOutlet();
    _fetchProducts();
  }

  Future<void> _fetchOutlet() async {
    final id = context.read<AppIdProvider>().id;
    final order = context.read<OrderProvider>();
    try {
      final outlet = await _outletService.fetchOutlet(id);
      order.setOutlet(outlet.outletName, outlet.meja);
    } catch (e) {
      // print(e.toString());
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await _productService.fetchProducts();
      // print(products.length);
      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  bool _isGrid = true;

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu Order',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: _isGrid ? 'Ubah ke List' : 'Ubah ke Grid',
            onPressed: () => setState(() => _isGrid = !_isGrid),
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    HeaderChip(
                      rows: [
                        HeaderChipRow(
                          icon: Icons.store_mall_directory,
                          label: 'Outlet', // tetap satu label saja
                          child: Text(
                            order.outlet ?? '-',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        HeaderChipRow(
                          icon: Icons.table_bar,
                          label: 'Meja', // tetap satu label saja
                          child: Text(
                            order.tableNumber.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 0),

            // PRODUCT LIST
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (_isGrid) {
                    int crossAxisCount = 2;
                    final w = constraints.maxWidth;
                    if (w > 1400) {
                      crossAxisCount = 5;
                    } else if (w > 1100) {
                      crossAxisCount = 4;
                    } else if (w > 800) {
                      crossAxisCount = 3;
                    }

                    // ubah ratio berdasarkan lebar layar
                    double aspectRatio;
                    if (w <= 400) {
                      aspectRatio = 0.6; // layar kecil -> card lebih tinggi
                    } else if (w <= 800) {
                      aspectRatio = 0.75; // tablet kecil
                    } else {
                      aspectRatio = 0.8; // default mirip 4/5
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final p = _products[index];
                        final qty = order.cart[p.id]?.qty ?? 0;
                        return ProductCard(
                          product: p,
                          qty: qty,
                          onAdd: () => order.addToCart(p),
                          onRemove: () => order.decreaseFromCart(p),
                          priceText: formatCurrency(p.price),
                        );
                      },
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = _products[index];
                      final qty = order.cart[p.id]?.qty ?? 0;
                      return ProductListTile(
                        product: p,
                        qty: qty,
                        onAdd: () => order.addToCart(p),
                        onRemove: () => order.decreaseFromCart(p),
                        priceText: formatCurrency(p.price),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // BOTTOM BAR
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: const [
              BoxShadow(
                blurRadius: 12,
                spreadRadius: 0,
                offset: Offset(0, -2),
                color: Color(0x14000000),
              ),
            ],
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total:',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    formatCurrency(order.total_price),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ), // kecilin padding
                      minimumSize: Size.zero, // biar gak maksa ukuran default
                      tapTargetSize: MaterialTapTargetSize
                          .shrinkWrap, // biar gak tinggi default 48
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled:
                            true, // biar bisa tinggi penuh kalau banyak data
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder: (context) {
                          return DraggableScrollableSheet(
                            expand: false,
                            builder: (context, scrollController) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: ListView(
                                  controller: scrollController,
                                  children: [
                                    Text(
                                      'Detail Pesanan',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 12),
                                    // contoh item pesanan
                                    ...order.cart.values.map(
                                      (c) => ListTile(
                                        title: Text(c.product.name),
                                        subtitle: Text(
                                          "Qty: ${c.qty} x Rp${c.product.price.toStringAsFixed(0)}",
                                        ),
                                        trailing: Text(
                                          "Rp${c.subtotal.toStringAsFixed(0)}",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: const Text('Detail Pesanan'),
                  ),
                  const SizedBox(width: 4),
                  FilledButton.icon(
                    onPressed: order.totalItems == 0 || order.outlet!.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CheckoutPage(),
                              ),
                            );
                          },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Lanjut'),
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
