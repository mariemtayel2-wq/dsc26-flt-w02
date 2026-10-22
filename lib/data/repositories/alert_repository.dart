import '../../domain/models/stock_alert.dart';

abstract class AlertRepository {
  Future<List<StockAlert>> fetchAlerts();
  Future<void> acknowledge(String id);
}

class InMemoryAlertRepository implements AlertRepository {
  final List<StockAlert> _alerts;

  InMemoryAlertRepository({List<StockAlert>? initialAlerts})
    : _alerts = List<StockAlert>.of(initialAlerts ?? _defaultAlerts);

  static const List<StockAlert> _defaultAlerts = [
    StockAlert(
      id: 'insulin',
      medicineNameEn: 'Insulin',
      medicineNameAr: 'إنسولين',
      severity: Severity.critical,
      daysOfCover: 1.5,
      branchCode: 'CAI-01',
    ),
    StockAlert(
      id: 'amlodipine',
      medicineNameEn: 'Amlodipine',
      medicineNameAr: 'أملوديبين',
      severity: Severity.high,
      daysOfCover: 4,
      branchCode: 'CAI-01',
    ),
    StockAlert(
      id: 'metformin',
      medicineNameEn: 'Metformin',
      medicineNameAr: 'ميتفورمين',
      severity: Severity.medium,
      daysOfCover: 9,
      branchCode: 'CAI-01',
    ),
    StockAlert(
      id: 'atorvastatin',
      medicineNameEn: 'Atorvastatin',
      medicineNameAr: 'أتورفاستاتين',
      severity: Severity.low,
      daysOfCover: 21,
      branchCode: 'CAI-01',
    ),
  ];

  @override
  Future<List<StockAlert>> fetchAlerts() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<StockAlert>.unmodifiable(_alerts);
  }

  @override
  Future<void> acknowledge(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final index = _alerts.indexWhere((alert) => alert.id == id);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(acknowledged: true);
    }
  }
}
