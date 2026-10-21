import '../../domain/models/stock_alert.dart';

abstract class AlertRepository{
  Future<List<StockAlert>> fetchAlerts();
  Future<void> acknowledgeAlert(String id);

}
class InMemoryAlertRepository implements AlertRepository {
  final List<StockAlert> _alerts;

  InMemoryAlertRepository({List<StockAlert>? initialAlerts})
      : _alerts = initialAlerts ?? _defaultDummyAlerts;

  static final List<StockAlert> _defaultDummyAlerts = [
    StockAlert(
      id: '1',
      title: 'نقص حاد في المخزون',
      message: 'المنتج أوشك على الانتهاء في الفرع الرئيسي',
      severity: Severity.critical,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isAcknowledged: false,
      sku: 'SKU-1001',
    ),
    StockAlert(
      id: '2',
      title: 'تنبيه انتهاء الصلاحية',
      message: 'شحنة الحليب تنتهي صلاحيتها خلال أسبوع',
      severity: Severity.high,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isAcknowledged: false,
      sku: 'SKU-1002',
    ),
    StockAlert(
      id: '3',
      title: 'إعادة الطلب المستحسنة',
      message: 'الوصول للحد الأدنى من المخزون',
      severity: Severity.medium,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isAcknowledged: true,
      sku: 'SKU-1003',
    ),
  ];

  @override
  Future<List<StockAlert>> fetchAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_alerts);
  }

  @override
  Future<void> acknowledgeAlert(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _alerts.indexWhere((alert) => alert.id == id);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isAcknowledged: true);
    }
  }

}