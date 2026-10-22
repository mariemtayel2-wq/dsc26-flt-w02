import 'package:flutter/foundation.dart';

import '../../../data/repositories/alert_repository.dart';
import '../../../domain/models/stock_alert.dart';

class AlertsViewModel extends ChangeNotifier {
  AlertsViewModel({required AlertRepository repository})
    : _repository = repository;

  final AlertRepository _repository;

  List<StockAlert> _alerts = const [];
  final Set<Severity> _activeFilters = {};
  String _normalizedQuery = '';
  bool _loading = false;
  bool _disposed = false;

  bool get loading => _loading;

  Set<Severity> get activeFilters => Set<Severity>.unmodifiable(_activeFilters);

  List<StockAlert> get visibleAlerts {
    final result = _alerts.where(_isVisible).toList()..sort(_compare);
    return List<StockAlert>.unmodifiable(result);
  }

  int get unacknowledgedCriticalCount => _alerts
      .where((a) => a.severity == Severity.critical && !a.acknowledged)
      .length;

  Future<void> load() async {
    _loading = true;
    _safeNotify();
    try {
      final fetched = await _repository.fetchAlerts();
      _alerts = List<StockAlert>.of(fetched);
    } catch (_) {
      _alerts = const [];
    } finally {
      _loading = false;
      _safeNotify();
    }
  }

  void toggleFilter(Severity s) {
    if (!_activeFilters.remove(s)) {
      _activeFilters.add(s);
    }
    _safeNotify();
  }

  void setQuery(String q) {
    final normalized = _normalize(q);
    if (normalized == _normalizedQuery) return;
    _normalizedQuery = normalized;
    _safeNotify();
  }

  Future<void> acknowledge(String id) async {
    if (!_alerts.any((a) => a.id == id)) return;
    await _repository.acknowledge(id);
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final updated = List<StockAlert>.of(_alerts);
    updated[index] = updated[index].copyWith(acknowledged: true);
    _alerts = updated;
    _safeNotify();
  }

  bool _isVisible(StockAlert alert) {
    if (_activeFilters.isNotEmpty && !_activeFilters.contains(alert.severity)) {
      return false;
    }
    if (_normalizedQuery.isEmpty) return true;
    return _normalize(alert.medicineNameEn).contains(_normalizedQuery) ||
        _normalize(alert.medicineNameAr).contains(_normalizedQuery);
  }

  int _compare(StockAlert a, StockAlert b) {
    if (a.acknowledged != b.acknowledged) {
      return a.acknowledged ? 1 : -1;
    }
    final bySeverity = a.severity.index.compareTo(b.severity.index);
    if (bySeverity != 0) return bySeverity;
    final byCover = a.daysOfCover.compareTo(b.daysOfCover);
    if (byCover != 0) return byCover;
    return a.medicineNameEn.toLowerCase().compareTo(
      b.medicineNameEn.toLowerCase(),
    );
  }

  static final RegExp _marks = RegExp('[ً-ْـ]');
  static final RegExp _alef = RegExp('[أإآ]');

  static String _normalize(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(_marks, '')
        .replaceAll(_alef, 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
