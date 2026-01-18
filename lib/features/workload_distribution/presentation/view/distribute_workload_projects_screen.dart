import 'package:aw_flutter/features/workload_distribution/application/workload_distribution_project_service.dart';
import 'package:aw_flutter/features/workload_distribution/domain/models/workload_project.dart';
import 'package:aw_flutter/features/workload_distribution/presentation/view/distribute_workload_screen.dart';
import 'package:aw_flutter/shared/date_time_extension.dart';
import 'package:flutter/material.dart';

class DistributeWorkloadProjectsScreen extends StatefulWidget {
  static const routeName = '/distribute-workload-projects';

  const DistributeWorkloadProjectsScreen({super.key});

  @override
  State<DistributeWorkloadProjectsScreen> createState() =>
      _DistributeWorkloadProjectsScreenState();
}

class _DistributeWorkloadProjectsScreenState
    extends State<DistributeWorkloadProjectsScreen> {
  final _service = WorkloadDistributionProjectService();
  List<WorkloadDistributionProject> _projects = [];

  bool _isLoading = true;

  _DistributeWorkloadProjectsScreenState() {
    () async {
      await Future.delayed(const Duration(seconds: 1));
      await _refreshProjects();
    }();
  }

  void _openCreateDialog() async {
    final result = await showDialog<WorkloadDistributionProject>(
      context: context,
      builder: (context) => _CreateProjectDialog(service: _service),
    );

    if (result != null) {
      _refreshProjects();
    }
  }

  void _setProjects(List<WorkloadDistributionProject> projects) {
    setState(() {
      this._projects = projects;
      _isLoading = false;
    });
  }

  Future<void> _deleteProject(int projectId) async {
    await _service.delete(projectId);
    _refreshProjects();
  }

  Future<void> _refreshProjects() async {
    setState(() {
      _isLoading = true;
    });
    _setProjects(await _service.getAll());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Проекти")),
      body: Align(
        alignment: Alignment.center,
        child:
            _isLoading
                ? const CircularProgressIndicator()
                : _projects.isEmpty
                ? Text('Проектів поки нема :(')
                : ListView.builder(
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return Card(
                      child: ListTile(
                        title: Text(project.title),
                        subtitle: Text(
                          'Створено: ${project.createdAt.toLocal().toDefaultString()}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => DistributeWorkloadScreen(
                                          projectId: project.id,
                                        ),
                                  ),
                                );
                                _refreshProjects();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteDialog(project.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(int projectId) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Видалити проект'),
            content: const Text('Ви впевнені, що хочете видалити цей проект?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Скасувати'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Видалити'),
              ),
            ],
          ),
    );

    if (result == true) {
      _deleteProject(projectId);
    }
  }
}

class _CreateProjectDialog extends StatefulWidget {
  final WorkloadDistributionProjectService _service;

  const _CreateProjectDialog({
    required WorkloadDistributionProjectService service,
  }) : _service = service;

  @override
  State<_CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<_CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final int projectId = await widget._service.create(
        title: _titleController.text,
        universityForm1: UniversityForm1.create(
          academicYear: DateTime.now().year,
        ),
        universityForm3: UniversityForm3.create(
          academicYear: DateTime.now().year,
        ),
      );
      final WorkloadDistributionProject project =
          (await widget._service.getById(projectId))!;
      Navigator.of(context).pop(project);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Створити проект"),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: "Назва проекту"),
          validator:
              (value) =>
                  (value == null || value.isEmpty)
                      ? "Введіть назву проекту"
                      : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text("Скасувати"),
        ),
        ElevatedButton(onPressed: _onSubmit, child: const Text("Створити")),
      ],
    );
  }
}
