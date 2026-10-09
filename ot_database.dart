import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/ot_entry.dart';

class OtDatabase {
  OtDatabase._();
  static final OtDatabase instance = OtDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'ot_plus.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE ot_entries(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          hours INTEGER NOT NULL,
          minutes INTEGER NOT NULL,
          hourly_rate REAL NOT NULL,
          note TEXT NOT NULL DEFAULT ''
        )
      ''');
      await db.execute('CREATE INDEX idx_ot_date ON ot_entries(date)');
    });
    return _db!;
  }

  Future<int> insert(OtEntry entry) async =>
      (await database).insert('ot_entries', entry.toMap()..remove('id'));

  Future<int> update(OtEntry entry) async =>
      (await database).update('ot_entries', entry.toMap(),
          where: 'id = ?', whereArgs: [entry.id]);

  Future<int> delete(int id) async =>
      (await database).delete('ot_entries', where: 'id = ?', whereArgs: [id]);

  Future<List<OtEntry>> all() async {
    final rows = await (await database).query('ot_entries', orderBy: 'date DESC, id DESC');
    return rows.map(OtEntry.fromMap).toList();
  }

  Future<List<OtEntry>> forMonth(String yyyyMm) async {
    final rows = await (await database).query(
      'ot_entries',
      where: 'date LIKE ?',
      whereArgs: ['$yyyyMm-%'],
      orderBy: 'date ASC',
    );
    return rows.map(OtEntry.fromMap).toList();
  }

  Future<double> monthlyAmount(String yyyyMm) async =>
      (await forMonth(yyyyMm)).fold(0.0, (sum, e) => sum + e.amount);

  Future<int> monthlyMinutes(String yyyyMm) async =>
      (await forMonth(yyyyMm)).fold(0, (sum, e) => sum + e.totalMinutes);
}
