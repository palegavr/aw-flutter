import 'package:aw_flutter/features/workload_distribution/data/worker_model.dart';
import 'package:aw_flutter/features/workload_distribution/data/workload_output_model.dart';

class WorkloadService {
  // Should return result
  void loadInputWorkloadFromFile(String filePath) {}
  void createNewWorker(
    String firstName,
    String middleName,
    String lastName,
    WorkerRank rank,
  ) {}
  void createNewGroup(
    String speciality,
    String name,
    int course,
    int students,
  ) {}
  void getInputWorkloadForSemester(int semester) {
    assert(semester == 1 || semester == 2);
  }

  String createWorkloadTableForWorker(
    String workerId,
    WorkerOutputTableType tableType,
  ) {
    return '';
  }
}
