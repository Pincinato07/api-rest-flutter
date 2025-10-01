import 'package:flutter/material.dart';
import '../repositories/course_repository.dart';
import '../models/course.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final repo = CourseRepository();
  late Future<List<CourseModel>> _future;

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

  Future<void> _createOrEdit({CourseModel? course}) async {
    final nameCtrl = TextEditingController(text: course?.name);
    final descCtrl = TextEditingController(text: course?.desc);
    final priceCtrl = TextEditingController(text: course?.price.toString());

    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(course == null ? 'Novo Curso' : 'Editar Curso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descrição')),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Preço'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar')),
        ],
      ),
    );

    if (res != true) return;

    final input = CourseModel(
      id: course?.id ?? '',
      name: nameCtrl.text.trim(),
      desc: descCtrl.text.trim(),
      price: num.tryParse(priceCtrl.text.trim()) ?? 0,
    );

    if (course == null) {
      await repo.create(input);
    } else {
      await repo.update(course.id, input);
    }
    await _refresh();
  }

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir curso?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true) {
      await repo.delete(id);
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos'),
      ),
      body: FutureBuilder<List<CourseModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('Nenhum curso'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final c = data[i];
                return ListTile(
                  title: Text(c.name),
                  subtitle: Text('${c.desc} — R\$ ${c.price}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _createOrEdit(course: c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _delete(c.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
