import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_app/core/dependency_injection/injection.dart';
import 'package:food_app/core/services/biometric_service.dart';
import '../cart/presentation/cubit/cart_cubit.dart';
import '../cart/presentation/cubit/cart_state.dart';
import '../cart/presentation/screens/cart_screen.dart';
import '../favorites/presentation/cubit/favorites_cubit.dart';
import '../favorites/presentation/screens/favorites_screen.dart';
import '../home/presentation/screens/home_screen.dart';
import '../orders/presentation/screens/orders_screen.dart';
import '../profile/presentation/screens/profile_screen.dart';
import '../vendors/presentation/screens/nearby_vendors_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  final BiometricService _biometricService = BiometricService();

  Future<void> _onDestinationSelected(int index) async {
    // Profile is the last tab (index 5).
    if (index == 5 && _currentIndex != 5) {
      final authenticated = await _biometricService.authenticate();

      if (!mounted) return;

      if (!authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('biometricAuthenticationFailed'.tr())),
        );
        return;
      }
    }

    if (!mounted) return;

    setState(() {
      _currentIndex = index;
    });
  }

  static const List<Widget> _tabs = [
    HomeScreen(),
    FavoritesScreen(),
    CartScreen(),
    OrdersScreen(),
    NearbyVendorsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<FavoritesCubit>()),
        BlocProvider.value(value: getIt<CartCubit>()),
      ],
      child: Scaffold(
        body: _tabs[_currentIndex],
        bottomNavigationBar: BlocSelector<CartCubit, CartState, int>(
          selector: (state) => state.itemCount,
          builder: (ctx, cartCount) => NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: 'homeTab'.tr(),
              ),
              NavigationDestination(
                icon: const Icon(Icons.favorite_outline_rounded),
                selectedIcon: const Icon(Icons.favorite_rounded),
                label: 'favoritesTab'.tr(),
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  child: const Icon(Icons.shopping_cart_rounded),
                ),
                label: 'cartTab'.tr(),
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(Icons.receipt_long_rounded),
                label: 'ordersTab'.tr(),
              ),

              NavigationDestination(
                icon: const Icon(Icons.map_outlined),
                selectedIcon: const Icon(Icons.map_rounded),
                label: 'nearbyVendorsTitle'.tr(),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded),
                label: 'profileTab'.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
