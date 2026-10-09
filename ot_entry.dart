class OtEntry {
  final int? id;
  final String date; // ISO yyyy-MM-dd
  final int hours;
  final int minutes;
  final double hourlyRate;
  final String note;

  const OtEntry({
    this.id,
    required this.date,
    required this.hours,
    required this.minutes,
    required this.hourlyRate,
    this.note = '',
  });

  int get totalMinutes => hours * 60 + minutes;
  double get amount => totalMinutes / 60.0 * hourlyRate;

  Map<String, Object?> toMap() => {
    'id': id,
    'date': date,
    'hours': hours,
    'minutes': minutes,
    'hourly_rate': hourlyRate,
    'note': note,
  };

  factory OtEntry.fromMap(Map<String, Object?> map) => OtEntry(
    id: map['id'] as int?,
    date: map['date'] as String,
    hours: map['hours'] as int,
    minutes: map['minutes'] as int,
    hourlyRate: (map['hourly_rate'] as num).toDouble(),
    note: (map['note'] as String?) ?? '',
  );
}
