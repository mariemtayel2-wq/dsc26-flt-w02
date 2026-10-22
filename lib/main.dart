import 'package:flutter/material.dart';

import 'data/repositories/alert_repository.dart';
import 'ui/alerts/view_models/alerts_view_model.dart';
import 'ui/alerts/widgets/alerts_screen.dart';

void main() {
  runApp(NourShelfApp(repository: InMemoryAlertRepository()));
}

class NourShelfApp extends StatefulWidget {
  const NourShelfApp({Key? key, required this.repository}) : super(key: key);

  final AlertRepository repository;

  @override
  State<NourShelfApp> createState() => _NourShelfAppState();
}

class _NourShelfAppState extends State<NourShelfApp> {
  late final AlertsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AlertsViewModel(repository: widget.repository);
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NourShelf Alerts',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: AlertsScreen(viewModel: _viewModel),
    );
  }
}
