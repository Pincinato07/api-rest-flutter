import 'package:flutter/material.dart';
import '../core/token_storage.dart';
import '../repositories/auth_repository.dart';
import '../models/user.dart';
import 'login_screen.dart';
import 'admin_screen.dart';
import 'user_screen.dart';
import '../core/user_cache.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = AuthRepository();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        _goToLogin();
        return;
      }
      // Try cached profile for instant routing
      final cached = await UserCache.get();
      if (cached != null) {
        _goToRole(cached);
        // Refresh in background
        try {
          final fresh = await _auth.me();
          await UserCache.save(fresh);
        } catch (_) {}
        return;
      }
      // No cache, call /me
      final me = await _auth.me();
      await UserCache.save(me);
      _goToRole(me);
    } catch (e) {
      _goToLogin();
    }
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _goToRole(UserModel me) {
    if (!mounted) return;
    final isAdmin = me.role.toUpperCase() == 'ADMIN';
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => isAdmin ? AdminScreen(user: me) : UserScreen(user: me)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
