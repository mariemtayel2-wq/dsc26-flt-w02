import 'package:flutter/material.dart';
import 'data/repositories/alert_repository.dart';
import 'ui/alerts/view_models/alerts_view_model.dart';
import 'ui/alerts/widgets/alerts_screen.dart';

void main() {
  final repository = InMemoryAlertRepository();
  runApp(NourShelfApp(repository: repository));
}

class NourShelfApp extends StatefulWidget {
  final AlertRepository repository;

  const NourShelfApp({super.key, required this.repository});

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: AlertsScreen(viewModel: _viewModel),
    );
  }
}