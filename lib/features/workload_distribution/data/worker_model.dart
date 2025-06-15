import 'package:uuid/uuid.dart';

enum WorkerRank { head, professor, associate, lecturer, assistant }

class WorkerModel {
  final String id = const Uuid().v4();
  final String firstName;
  final String middleName;
  final String lastName;
  final WorkerRank rank;

  WorkerModel({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.rank,
  });
}
