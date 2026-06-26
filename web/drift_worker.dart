import 'package:drift/web/worker.dart';
import 'package:drift_flutter/drift_flutter.dart';

void main() {
  driftWorkerMain(() => driftDatabase(name: 'marksmanmate_db'));
}
