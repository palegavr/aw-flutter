import 'package:aw_flutter/features/workload_distribution/presentation/bloc/import_bloc.dart';
import 'package:aw_flutter/features/workload_distribution/presentation/view/distribute_screen.dart';
import 'package:aw_flutter/theme.dart';
import 'package:aw_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImportScreen extends StatelessWidget {
  static const routeName = '/import';

  const ImportScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    return BlocListener<ImportBloc, ImportState>(
      listener: (ctx, state) {},
      child: Scaffold(
        appBar: awSimpleAppBar(),
        floatingActionButton: BlocBuilder<ImportBloc, ImportState>(
          builder: (ctx, state) {
            final isEnabled =
                state is ImportReadyState && state.files.isNotEmpty;

            return AWFloatingActionButton(
              label: 'Далі',
              icon: Icons.arrow_forward_rounded,
              onPressed:
                  () => Navigator.pushNamed(ctx, DistributeScreen.routeName),
              isEnabled: isEnabled,
            );
          },
        ),
        body: Padding(
          padding: defaultPadding,
          child: BlocBuilder<ImportBloc, ImportState>(
            builder: (context, state) {
              switch (state) {
                case ImportLoadingState _:
                  return const Center(child: CircularProgressIndicator());
                case ImportReadyState state:
                  final fileWidgets =
                      state.files.map((name) => _ImportedFile(name)).toList();
                  return Center(
                    child: Column(
                      spacing: defaultSpacing,
                      children: [
                        const Text('Файли до імпорту:'),
                        Card(
                          child: Padding(
                            padding: defaultPadding,
                            child: SizedBox(
                              width: 500,
                              child: ListView.separated(
                                shrinkWrap: true,
                                separatorBuilder:
                                    (_, _) => const Divider(height: 1),
                                itemCount: fileWidgets.length,
                                itemBuilder: (ctx, index) {
                                  return fileWidgets[index];
                                },
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ImportBloc>().add(
                              ImportNewFileEvent(),
                            );
                          },
                          child: const Text('Додати файл'),
                        ),
                      ],
                    ),
                  );
                case _:
                  return Center(
                    child: Column(
                      spacing: defaultSpacing,
                      children: [
                        const Text(
                          'Файли відсутні. Щоб почати '
                          'роботу, додайте Excel файл:',
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ImportBloc>().add(
                              ImportNewFileEvent(),
                            );
                          },
                          child: const Text('Додати файл'),
                        ),
                      ],
                    ),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _ImportedFileStatusIcon extends StatelessWidget {
  final _ImportedFileStatus status;

  const _ImportedFileStatusIcon(this.status);

  @override
  Widget build(BuildContext context) {
    return Icon(_getIcon(), color: _getIconColor());
  }

  IconData _getIcon() {
    return switch (status) {
      _ImportedFileStatus.ok => Icons.check_rounded,
      _ImportedFileStatus.warning => Icons.warning_rounded,
      _ImportedFileStatus.error => Icons.error_outline_rounded,
    };
  }

  Color _getIconColor() {
    return switch (status) {
      _ImportedFileStatus.ok => Colors.lightGreenAccent,
      _ImportedFileStatus.warning => Colors.amber,
      _ImportedFileStatus.error => Colors.redAccent,
    };
  }
}

class _ImportedFile extends StatelessWidget {
  final String fileName;

  const _ImportedFile(this.fileName);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Padding(
        padding: smallPadding,
        child: Row(
          spacing: defaultSpacing,
          children: [
            Expanded(
              child: Text(
                fileName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _ImportedFileStatusIcon(
              fileName.length > 10
                  ? _ImportedFileStatus.ok
                  : _ImportedFileStatus.warning,
            ),
            OutlinedButton(
              onPressed: () {
                context.read<ImportBloc>().add(ImportRemoveFileEvent(fileName));
              },
              child: const Text(
                'Прибрати',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ImportedFileStatus { ok, warning, error }
