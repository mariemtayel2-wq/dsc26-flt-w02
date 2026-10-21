import 'package:flutter/material.dart';
import '../../../domain/models/stock_alert.dart';
import '../view_models/alerts_view_model.dart';

class AlertsScreen extends StatelessWidget {
  final AlertsViewModel viewModel;

  const AlertsScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NourShelf Alerts'),
        actions: [
          ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              final count = viewModel.visibleAlerts.length;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    count == 1 ? '1 alert' : '$count alerts',
                    key: const Key('alerts-count'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              key: const Key('search-field'),
              decoration: const InputDecoration(
                hintText: 'Search alerts...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: viewModel.setQuery,
            ),
          ),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: Severity.values.map((severity) {
                return ListenableBuilder(
                  listenable: viewModel,
                  builder: (context, _) {
                    final isSelected = viewModel.activeFilters.contains(severity);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: FilterChip(
                        key: Key('filter-${severity.name}'),
                        label: Text(severity.name.toUpperCase()),
                        selected: isSelected,
                        onSelected: (_) => viewModel.toggleFilter(severity),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                if (viewModel.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      key: Key('alerts-loading'),
                    ),
                  );
                }

                final alerts = viewModel.visibleAlerts;

                if (alerts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No alerts found',
                      key: Key('alerts-empty'),
                    ),
                  );
                }

                return ListView.builder(
                  key: const Key('alerts-list'),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return Card(
                      key: Key('alert-${alert.id}'),
                      child: ListTile(
                        title: Text(
                          alert.medicineNameEn,
                          style: TextStyle(
                            decoration: alert.acknowledged
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          '${alert.medicineNameAr} | Cover: ${alert.daysOfCover} days | Branch: ${alert.branchCode}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(label: Text(alert.severity.name)),
                            if (!alert.acknowledged)
                              IconButton(
                                key: Key('ack-${alert.id}'),
                                icon: const Icon(Icons.check_circle_outline),
                                onPressed: () => viewModel.acknowledge(alert.id),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}