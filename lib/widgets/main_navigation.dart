import 'package:flutter/material.dart';
import 'package:amaranta/screens/categoria.dart';
import 'package:amaranta/screens/cart.dart';
import 'package:amaranta/screens/orders.dart';
import 'package:amaranta/screens/edit.dart';

class MainNavigationBar extends StatelessWidget {
  final int currentIndex;
  final String? userEmail;

  const MainNavigationBar({
    super.key,
    required this.currentIndex,
    this.userEmail,
  });

  void _navigateToIndex(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget destination;
    switch (index) {
      case 0:
        destination = const CategoriasScreen();
        break;
      case 1:
        destination = const CartScreen();
        break;
      case 2:
        destination = const OrdersScreen();
        break;
      case 3:
        destination = EditProfileScreen(correo: userEmail ?? '');
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _navigateToIndex(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFF5E6D3),
      selectedItemColor: const Color(0xFFD15113),
      unselectedItemColor: const Color(0xFF2C3E2D).withOpacity(0.6),
      selectedFontSize: 12,
      unselectedFontSize: 11,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          activeIcon: Icon(Icons.grid_view_rounded, size: 28),
          label: 'Categorías',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          activeIcon: Icon(Icons.shopping_cart, size: 28),
          label: 'Carrito',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long, size: 28),
          label: 'Pedidos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person, size: 28),
          label: 'Perfil',
        ),
      ],
    );
  }
}
