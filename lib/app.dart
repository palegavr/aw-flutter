import 'package:aw_flutter/features/import_tables/presentation/view/distribute_screen.dart';
import 'package:aw_flutter/features/import_tables/presentation/view/import_screen.dart';
import 'package:aw_flutter/features/initial/presentation/view/initial_screen.dart';
import 'package:aw_flutter/theme.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      title: 'Academic Workload',
      theme: theme,
      darkTheme: darkTheme,
      initialRoute: InitialScreen.routeName,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case InitialScreen.routeName:
            return MaterialPageRoute(builder: (_) => const InitialScreen());
          case ImportScreen.routeName:
            return MaterialPageRoute(builder: (_) => const ImportScreen());
          case DistributeScreen.routeName:
            return MaterialPageRoute(builder: (_) => const DistributeScreen());
        }
        return null;
      },
    );
  }
}
