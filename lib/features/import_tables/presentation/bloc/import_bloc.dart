import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';

part 'import_event.dart';
part 'import_state.dart';

class ImportBloc extends Bloc<ImportEvent, ImportState> {
  ImportBloc() : super(ImportInitialState()) {
    on<ImportNewFileEvent>(_onImportNewFileEvent);
    on<ImportRemoveFileEvent>(_onImportRemoveFileEvent);
  }

  Future<void> _onImportNewFileEvent(
    ImportNewFileEvent event,
    Emitter<ImportState> emit,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Виберіть Excel файли',
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result == null) {
      return;
    }
    final files = <String>[];
    if (state is ImportReadyState) {
      files.addAll((state as ImportReadyState).files);
    }
    files.addAll(result.files.map((f) => f.name));
    emit(ImportReadyState(files: files));
  }

  Future<void> _onImportRemoveFileEvent(
    ImportRemoveFileEvent event,
    Emitter<ImportState> emit,
  ) async {
    if (state is! ImportReadyState) {
      return;
    }
    final files =
        (state as ImportReadyState).files
            .where((f) => f != event.filePath)
            .toList();
    emit(ImportReadyState(files: files));
  }
}
