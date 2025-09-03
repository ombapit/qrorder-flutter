import 'package:flutter/material.dart';
import 'package:flutter_pos/providers/appid_provider.dart';
import 'package:flutter_pos/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'pages/order_template_page.dart';
import 'utils/scroll_behavior.dart';
import 'package:web/web.dart' as web;

void main() {
  final path = web.window.location.pathname;
  final id = path.startsWith("/") ? path.substring(1) : path;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AppIdProvider(id)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qr Order Web',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const OrderTemplatePage(),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: child!,
        );
      },
    );
  }
}
