enum Severity { critical, high, medium, low }

class StockAlert {
  final String id;
  final String medicineNameEn;
  final String medicineNameAr;
  final Severity severity;
  final double daysOfCover;
  final String branchCode;
  final bool acknowledged;

  const StockAlert({
    required this.id,
    required this.medicineNameEn,
    required this.medicineNameAr,
    required this.severity,
    required this.daysOfCover,
    required this.branchCode,
    this.acknowledged = false,
  });

  factory StockAlert.fromJson(Map<String, Object?> json) {
    return StockAlert(
      id: _requireString(json, 'id'),
      medicineNameEn: _requireString(json, 'medicineNameEn'),
      medicineNameAr: _requireString(json, 'medicineNameAr'),
      severity: _parseSeverity(json['severity']),
      daysOfCover: _parseDaysOfCover(json['daysOfCover']),
      branchCode: _requireString(json, 'branchCode'),
      acknowledged: _parseAcknowledged(json['acknowledged']),
    );
  }

  StockAlert copyWith({
    String? id,
    String? medicineNameEn,
    String? medicineNameAr,
    Severity? severity,
    double? daysOfCover,
    String? branchCode,
    bool? acknowledged,
  }) {
    return StockAlert(
      id: id ?? this.id,
      medicineNameEn: medicineNameEn ?? this.medicineNameEn,
      medicineNameAr: medicineNameAr ?? this.medicineNameAr,
      severity: severity ?? this.severity,
      daysOfCover: daysOfCover ?? this.daysOfCover,
      branchCode: branchCode ?? this.branchCode,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockAlert &&
          other.runtimeType == runtimeType &&
          other.id == id &&
          other.medicineNameEn == medicineNameEn &&
          other.medicineNameAr == medicineNameAr &&
          other.severity == severity &&
          other.daysOfCover == daysOfCover &&
          other.branchCode == branchCode &&
          other.acknowledged == acknowledged;

  @override
  int get hashCode => Object.hash(
        id,
        medicineNameEn,
        medicineNameAr,
        severity,
        daysOfCover,
        branchCode,
        acknowledged,
      );

}

String _requireString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException(
      'Field "$key" must be a non-empty string, got: ${value.runtimeType}',
      value,
    );
  }
  return value;
}

Severity _parseSeverity(Object? value) {
  if (value is! String) {
    throw FormatException(
      'Field "severity" must be a string, got: ${value.runtimeType}',
      value,
    );
  }
  final normalized = value.trim().toLowerCase();
  for (final s in Severity.values) {
    if (s.name == normalized) return s;
  }
  throw FormatException(
    'Field "severity" must be one of '
    '${Severity.values.map((s) => s.name).join(', ')}, got: "$value"',
    value,
  );
}

double _parseDaysOfCover(Object? value) {
  if (value is! num) {
    throw FormatException(
      'Field "daysOfCover" must be a number, got: ${value.runtimeType}',
      value,
    );
  }
  final d = value.toDouble();

  if (!d.isFinite || d < 0) {
    throw FormatException(
      'Field "daysOfCover" must be a finite number >= 0, got: $value',
      value,
    );
  }
  return d;
}

bool _parseAcknowledged(Object? value) {
  if (value == null) return false; 
  if (value is bool) return value;
  throw FormatException(
    'Field "acknowledged" must be a bool, got: ${value.runtimeType}',
    value,
  );
}