import 'package:aw_flutter/features/workload_distribution/data/workload_output_model.dart';

abstract class DistributionAction {}

abstract class TableAction extends DistributionAction {}

class CreateTableAction extends TableAction {
  final String workerId;
  final WorkerOutputTableType tableType;

  CreateTableAction({required this.workerId, required this.tableType});
}

class EditTableAction extends TableAction {}

class DeleteTableAction extends TableAction {}

abstract class TableEntryAction extends DistributionAction {}

class CreateTableEntryAction extends TableEntryAction {}

class EditTableEntryAction extends TableEntryAction {}

class DeleteTableEntryAction extends TableEntryAction {}

/*

what actions could be?

create new main table
modify main table
delete main table

create new secondary table
delete secondary table
edit secondary table

create new entry in table
edit entry in table
remove entry from table

*/
