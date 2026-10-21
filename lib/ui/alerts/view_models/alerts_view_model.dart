import 'package:flutter/foundation.dart';
import '../../../data/repositories/alert_repository.dart';
import '../../../domain/models/stock_alert.dart';

class _SearchEntry {
  final String title;
  final String message;
  final String sku;
  const _SearchEntry(this.title, this.message, this.sku);
}

class AlertsViewModel extends ChangeNotifier {
  final AlertRepository _repository;

  AlertsViewModel({required AlertRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<StockAlert> _allAlerts = [];
  final Map<String, _SearchEntry> _searchIndex = {};

  final Set<Severity> _activeFilters = {};
  Set<Severity> get activeFilters => Set.unmodifiable(_activeFilters);
  bool get hasActiveFilters => _activeFilters.isNotEmpty;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  final Set<String> _acknowledgingIds = {};
  bool isAcknowledging(String id) => _acknowledgingIds.contains(id);

  List<StockAlert> _visibleAlerts = const [];
  List<StockAlert> get visibleAlerts => _visibleAlerts;

  bool get isEmpty => _visibleAlerts.isEmpty;

  int get unacknowledgedCriticalCount => _allAlerts
      .where((a) => a.severity == Severity.critical && !a.isAcknowledged)
      .length;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _notify();

    try {
      final fetched = await _repository.fetchAlerts();
      _allAlerts = List<StockAlert>.of(fetched);
      _rebuildSearchIndex();
      _recompute();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  void toggleFilter(Severity severity) {
    if (!_activeFilters.remove(severity)) {
      _activeFilters.add(severity);
    }
    _recompute();
    _notify();
  }

  void clearFilters() {
    if (_activeFilters.isEmpty) return;
    _activeFilters.clear();
    _recompute();
    _notify();
  }

  void setQuery(String query) {
    if (query == _searchQuery) return;
    _searchQuery = query;
    _recompute();
    _notify();
  }

  Future<void> acknowledge(String id) async {
    if (_acknowledgingIds.contains(id)) return;

    final index = _allAlerts.indexWhere((a) => a.id == id);
    if (index == -1 || _allAlerts[index].isAcknowledged) return;

    _acknowledgingIds.add(id);
    _error = null;
    _notify();

    try {
      await _repository.acknowledgeAlert(id);

      final current = _allAlerts.indexWhere((a) => a.id == id);
      if (current != -1) {
        _allAlerts[current] = _allAlerts[current].copyWith(isAcknowledged: true);
      }
      _recompute();
    } catch (e) {
      _error = e.toString();
    } finally {
      _acknowledgingIds.remove(id);
      _notify();
    }
  }

  static const Map<Severity, int> _severityRank = {
    Severity.critical: 0,
    Severity.high: 1,
    Severity.medium: 2,
    Severity.low: 3,
  };

  static int _rank(Severity s) => _severityRank[s] ?? 99;

  void _rebuildSearchIndex() {
    _searchIndex
      ..clear()
      ..addEntries(_allAlerts.map((a) => MapEntry(
            a.id,
            _SearchEntry(
              _normalizeArabic(a.title),
              _normalizeArabic(a.message),
              a.sku != null ? _normalizeArabic(a.sku!) : '',
            ),
          )));
  }

  void _recompute() {
    final query = _normalizeArabic(_searchQuery.trim());

    final list = _allAlerts.where((alert) {
      if (_activeFilters.isNotEmpty && !_activeFilters.contains(alert.severity)) {
        return false;
      }

      if (query.isNotEmpty) {
        final entry = _searchIndex[alert.id];
        if (entry == null) return false;
        final matches = entry.title.contains(query) ||
            entry.message.contains(query) ||
            entry.sku.contains(query);
        if (!matches) return false;
      }

      return true;
    }).toList();

    list.sort((a, b) {
      if (a.isAcknowledged != b.isAcknowledged) {
        return a.isAcknowledged ? 1 : -1;
      }

      final rankComparison = _rank(a.severity).compareTo(_rank(b.severity));
      if (rankComparison != 0) return rankComparison;

      final dateComparison = b.createdAt.compareTo(a.createdAt);
      if (dateComparison != 0) return dateComparison;

      return a.id.compareTo(b.id);
    });

    _visibleAlerts = List.unmodifiable(list);
  }

  static final RegExp _diacritics = RegExp(r'[\u064B-\u065F\u0670]'); 
  static final RegExp _tatweel = RegExp(r'\u0640'); 
  static final RegExp _alef = RegExp(r'[أإآٱ]');

  static const Map<String, String> _digits = {
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
    '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
    '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
  };

  static String _normalizeArabic(String text) {
    var result = text.toLowerCase();
    result = result.replaceAll(_diacritics, ''); 
    result = result.replaceAll(_tatweel, ''); 
    result = result.replaceAll(_alef, 'ا'); 
    result = result.replaceAll('ى', 'ي'); 
    result = result.replaceAll('ة', 'ه'); 
    result = result.replaceAll('ؤ', 'و').replaceAll('ئ', 'ي'); 
    if (_digits.keys.any(result.contains)) {
      result = result.split('').map((c) => _digits[c] ?? c).join();
    }
    return result;
  }
}