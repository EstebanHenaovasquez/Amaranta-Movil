import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'package:amaranta/services/pending_order_service.dart';
import 'package:provider/provider.dart';
import 'package:amaranta/models/cart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Intentar reenviar pedidos pendientes al iniciar la app
  final sent = await PendingOrderService.retryAll();
  debugPrint('PendingOrderService: reintentos enviados = $sent');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
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
      title: 'Amaranta Login',
      theme: ThemeData(primarySwatch: Colors.brown),
      home: const AmarantaLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}
