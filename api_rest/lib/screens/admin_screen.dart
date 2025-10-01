import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import 'courses_screen.dart';
import 'login_screen.dart';
import 'users/users_list_screen.dart';

class AdminScreen extends StatelessWidget {
  final UserModel user;
  const AdminScreen({super.key, required this.user});

  Future<void> _logout(BuildContext context) async {
    await AuthRepository().logout();
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          IconButton(onPressed: () => _logout(context), icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Olá, ${user.name} (ADMIN)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Email: ${user.email}'),
            const SizedBox(height: 24),
            const Text('Operações'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CoursesScreen()));
                },
                child: const Text('CRUD de Cursos'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UsersListScreen()));
                },
                child: const Text('Usuários (ADMIN)'),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Dica: Rotas /users e /admin também exigem ADMIN.'),
          ],
        ),
      ),
    );
  }
}
