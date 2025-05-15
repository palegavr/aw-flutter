enum WorkerRank { head, professor, associate, lecturer, assistant }

class WorkerModel {
  final String firstName;
  final String middleName;
  final String lastName;
  final WorkerRank rank;

  const WorkerModel({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.rank,
  });
}
