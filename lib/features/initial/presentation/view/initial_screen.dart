import 'package:aw_flutter/features/archive/presentation/view/archive_entries_screen.dart';
import 'package:aw_flutter/features/employee/presentation/view/view_employees_screen.dart';
import 'package:aw_flutter/features/workload_distribution/presentation/view/import_screen.dart';
import 'package:aw_flutter/theme.dart';
import 'package:flutter/material.dart';

class InitialScreen extends StatelessWidget {
  static const routeName = '/';

  const InitialScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    final items = [
      _MenuItem(
        title: 'Імпорт',
        onTap: () => Navigator.pushNamed(ctx, ImportScreen.routeName),
      ),
      const _MenuItem(title: 'Продовжити'),
      _MenuItem(
        title: 'Переглянути архів',
        onTap: () => Navigator.pushNamed(ctx, ArchiveEntriesScreen.routeName),
      ),
      _MenuItem(
        title: 'Співробітники',
        onTap: () => Navigator.pushNamed(ctx, ViewEmployeesScreen.routeName),
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Cloud auth button
          Positioned(
            right: defaultSpacing,
            top: defaultSpacing,
            child: TextButton(
              onPressed: () {},
              child: const Text('Google Drive'),
            ),
          ),
          // Centered action buttons
          Center(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    child: Padding(
                      padding: defaultPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Почати роботу:',
                            style: Theme.of(ctx).textTheme.titleMedium,
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            separatorBuilder:
                                (_, _) => const Divider(height: 1),
                            itemCount: items.length,
                            itemBuilder: (ctx, index) {
                              final item = items[index];
                              return ListTile(
                                title: Text(item.title),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                ),
                                onTap: item.onTap,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final Function()? onTap;

  const _MenuItem({required this.title, this.onTap});
}
