import 'package:flutter/material.dart';
import '../../repositories/user_repository.dart';
import '../../utils/error_utils.dart';
import 'users_upsert_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final repo = UserRepository();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = repo.list();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = repo.list();
    });
  }

  Future<void> _create() async {
    final changed = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UsersUpsertScreen()),
    );
    if (changed == true) await _refresh();
  }

  Future<void> _edit(Map<String, dynamic> user) async {
    final changed = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UsersUpsertScreen(user: user)),
    );
    if (changed == true) await _refresh();
  }

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir usuário?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await repo.delete(id);
        await _refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(humanizeError(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários (ADMIN)'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(humanizeError(snapshot.error!)));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) return const Center(child: Text('Nenhum usuário'));
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final u = list[i];
                return ListTile(
                  title: Text(u['name'] ?? ''),
                  subtitle: Text('${u['email']} — ${u['role']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _edit(u)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete('${u['id']}')),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        child: const Icon(Icons.add),
      ),
    );
  }
}
