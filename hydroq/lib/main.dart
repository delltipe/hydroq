import 'package:flutter/widgets.dart';

import 'app/hydroq_app.dart';
import 'core/data/mock_hydro_repository.dart';
import 'core/state/hydroq_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final HydroQController controller = HydroQController(repository: MockHydroRepository());
  runApp(HydroQApp(controller: controller));
}
