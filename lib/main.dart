import 'package:aw_flutter/app.dart';
import 'package:aw_flutter/features/workload_distribution/presentation/bloc/import_bloc.dart';
import 'package:aw_flutter/src/rust/frb_generated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => ImportBloc())],
      child: const MyApp(),
    ),
  );
  // writeExcelFile(filePath: filePath, exportedTables: exportedTables);
}

// import 'package:flutter/material.dart';
// import 'package:aw_flutter/src/rust/api/simple.dart';
// import 'package:aw_flutter/src/rust/frb_generated.dart';

// Future<void> main() async {
//   await RustLib.init();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
//         body: Center(
//           child: Text(
//             'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`',
//           ),
//         ),
//       ),
//     );
//   }
// }
