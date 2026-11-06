import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() async {
  sqfliteFfiInit();
  var factory = databaseFactoryFfi;
  var path = join(await factory.getDatabasesPath(), 'user_database.db');
  var db = await factory.openDatabase(path);
  var result = await db.query('ayats', where: 'surah_no = ?', whereArgs: [2], orderBy: 'CAST(no AS INTEGER) ASC', limit: 10);
  for (var row in result) {
    print('id: ${row['id']}, no: ${row['no']}');
  }
  await db.close();
}
