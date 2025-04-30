import 'package:aw_flutter/app.dart';
import 'package:aw_flutter/features/import_tables/presentation/bloc/import_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => ImportBloc())],
      child: const MyApp(),
    ),
  );
}
