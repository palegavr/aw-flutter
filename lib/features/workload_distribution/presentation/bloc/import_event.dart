part of 'import_bloc.dart';

abstract class ImportEvent {}

class ImportNewFileEvent extends ImportEvent {}

class ImportRemoveFileEvent extends ImportEvent {
  final String filePath;

  ImportRemoveFileEvent(this.filePath);
}
