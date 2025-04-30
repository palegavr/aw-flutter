part of 'import_bloc.dart';

abstract class ImportState {}

class ImportInitialState extends ImportState {}

class ImportLoadingState extends ImportState {}

class ImportReadyState extends ImportState {
  final List<String> files;

  ImportReadyState({required this.files});
}
