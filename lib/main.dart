import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router.dart';
import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/loyalty_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/admin_provider.dart';

import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, auth, cart) {
            final uid = auth.currentUser?.uid;
            if (cart == null || cart.uid != uid) {
              return CartProvider(uid: uid);
            }
            return cart;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => OrderProvider(),
          update: (_, auth, order) {
            final uid = auth.currentUser?.uid;
            if (order == null || order.uid != uid) {
              return OrderProvider(uid: uid);
            }
            return order;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, LoyaltyProvider>(
          create: (_) => LoyaltyProvider(),
          update: (_, auth, loyalty) {
            final uid = auth.currentUser?.uid;
            if (loyalty == null || loyalty.uid != uid) {
              return LoyaltyProvider(uid: uid);
            }
            return loyalty;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, WishlistProvider>(
          create: (_) => WishlistProvider(),
          update: (_, auth, wishlist) {
            if (wishlist == null || wishlist.authProvider != auth) {
              return WishlistProvider(authProvider: auth);
            }
            return wishlist;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, AdminProvider>(
          create: (_) => AdminProvider(),
          update: (_, auth, admin) {
            final adminProvider = admin ?? AdminProvider();
            final uid = auth.currentUser?.uid;
            final isAdmin = auth.isAdmin;
            if (uid != null && isAdmin) {
              adminProvider.loadPermissions(uid);
            } else {
              adminProvider.clear();
            }
            return adminProvider;
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'Eli\'s Art Supplies',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
