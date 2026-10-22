import 'package:flutter/material.dart';

import '../../../domain/models/stock_alert.dart';
import '../view_models/alerts_view_model.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key, required this.viewModel});

  final AlertsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NourShelf Alerts')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final alerts = viewModel.visibleAlerts;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: TextField(
                  key: const Key('search-field'),
                  onChanged: viewModel.setQuery,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    for (final severity in Severity.values)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          key: Key('filter-${severity.name}'),
                          label: Text(severity.name),
                          selected: viewModel.activeFilters.contains(severity),
                          onSelected: (_) => viewModel.toggleFilter(severity),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  alerts.length == 1 ? '1 alert' : '${alerts.length} alerts',
                  key: const Key('alerts-count'),
                ),
              ),
              Expanded(child: _buildBody(alerts)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(List<StockAlert> alerts) {
    if (viewModel.loading) {
      return const Center(
        child: CircularProgressIndicator(key: Key('alerts-loading')),
      );
    }
    if (alerts.isEmpty) {
      return const Center(child: Text('No alerts', key: Key('alerts-empty')));
    }
    return ListView.builder(
      key: const Key('alerts-list'),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Card(
          key: Key('alert-${alert.id}'),
          child: ListTile(
            title: Text(alert.medicineNameEn),
            subtitle: Text(
              '${alert.medicineNameAr} · ${alert.severity.name} · '
              '${alert.daysOfCover} days · ${alert.branchCode}',
            ),
            trailing: alert.acknowledged
                ? const Icon(Icons.check_circle)
                : IconButton(
                    key: Key('ack-${alert.id}'),
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () => viewModel.acknowledge(alert.id),
                  ),
          ),
        );
      },
    );
  }
}
