import 'package:aw_flutter/features/workload_distribution/domain/models/workload_project.dart';
import 'package:aw_flutter/features/workload_distribution/presentation/bloc/workload_distribution_project_list_bloc.dart';
import 'package:aw_flutter/features/workload_distribution/presentation/view/distribute_workload_screen.dart';
import 'package:aw_flutter/shared/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DistributeWorkloadProjectsScreen extends StatelessWidget {
  static const routeName = '/distribute-workload-projects';

  const DistributeWorkloadProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initial load
    final bloc = context.read<WorkloadDistributionProjectListBloc>();
    if (bloc.state is ProjectListInitial) {
      bloc.add(LoadProjectList());
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Проекти")),
      body: BlocBuilder<WorkloadDistributionProjectListBloc, WorkloadDistributionProjectListState>(
        builder: (context, state) {
          if (state is ProjectListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectListLoadError) {
            return Center(child: Text('Помилка: ${state.message}'));
          }

          if (state is ProjectListReady) {
            final projects = state.projects;
            if (projects.isEmpty) {
              return const Center(child: Text('Проектів поки нема :('));
            }

            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
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
                                builder: (context) => DistributeWorkloadScreen(
                                  projectId: project.id,
                                ),
                              ),
                            );
                            // Refresh list after returning from editor
                            if (context.mounted) {
                              context.read<WorkloadDistributionProjectListBloc>().add(LoadProjectList());
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _showDeleteDialog(context, project.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openCreateDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Створити проект"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "Назва проекту"),
            validator: (value) =>
                (value == null || value.isEmpty) ? "Введіть назву проекту" : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Скасувати"),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<WorkloadDistributionProjectListBloc>().add(
                      CreateProject(
                        title: titleController.text,
                        form1: UniversityForm1.create(
                          academicYear: DateTime.now().year,
                        ),
                        form3: UniversityForm3.create(
                          academicYear: DateTime.now().year,
                        ),
                      ),
                    );
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text("Створити"),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int projectId) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Видалити проект'),
        content: const Text('Ви впевнені, що хочете видалити цей проект?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () {
              context.read<WorkloadDistributionProjectListBloc>().add(DeleteProject(projectId));
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
  }
}
