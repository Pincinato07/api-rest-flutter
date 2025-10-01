import 'package:flutter/material.dart';
import '../../repositories/user_repository.dart';
import '../../utils/error_utils.dart';

class UsersUpsertScreen extends StatefulWidget {
  final Map<String, dynamic>? user; // if null -> create
  const UsersUpsertScreen({super.key, this.user});

  @override
  State<UsersUpsertScreen> createState() => _UsersUpsertScreenState();
}

class _UsersUpsertScreenState extends State<UsersUpsertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'USER';
  bool _loading = false;
  final repo = UserRepository();

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    if (u != null) {
      _nameCtrl.text = u['name'] ?? '';
      _emailCtrl.text = u['email'] ?? '';
      _role = (u['role'] ?? 'USER').toString();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (widget.user == null) {
        await repo.create(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
          role: _role,
        );
      } else {
        final id = '${widget.user!['id']}';
        await repo.update(id, name: _nameCtrl.text.trim());
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(humanizeError(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.user != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Editar Usuário' : 'Novo Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
                  return ok ? null : 'E-mail inválido';
                },
                enabled: !editing,
              ),
              if (!editing) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(labelText: 'Papel'),
                  items: const [
                    DropdownMenuItem(value: 'USER', child: Text('USER')),
                    DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                  ],
                  onChanged: (v) => setState(() => _role = v ?? 'USER'),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading ? const CircularProgressIndicator() : const Text('Salvar'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
