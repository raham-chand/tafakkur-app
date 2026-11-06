import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  var db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  await db.execute('CREATE TABLE ayats(id INTEGER PRIMARY KEY, no TEXT)');
  
  await db.insert('ayats', {'id': 1, 'no': '২ : ১'});
  await db.insert('ayats', {'id': 10, 'no': '২ : ১০'});
  await db.insert('ayats', {'id': 182, 'no': '২ : ১৮২'});
  await db.insert('ayats', {'id': 20, 'no': '২ : ২০'});
  await db.insert('ayats', {'id': 2, 'no': '২ : ২'});
  
  var result = await db.query('ayats', orderBy: 'CAST(no AS INTEGER) ASC');
  for (var row in result) {
    print('id: ${row['id']}, no: ${row['no']}, cast: ${row['no']}'); // we will cast in sqlite next
  }

  var castResult = await db.rawQuery('SELECT id, no, CAST(no AS INTEGER) as c FROM ayats ORDER BY CAST(no AS INTEGER) ASC');
  print('With CAST:');
  for (var row in castResult) {
    print('id: ${row['id']}, no: ${row['no']}, cast: ${row['c']}');
  }

  // wait, what if `no` is actually just the ayat number (e.g. '১', '২', '১৮২')?
  await db.execute('CREATE TABLE ayats2(id INTEGER PRIMARY KEY, no TEXT)');
  await db.insert('ayats2', {'id': 1, 'no': '১'});
  await db.insert('ayats2', {'id': 10, 'no': '১০'});
  await db.insert('ayats2', {'id': 182, 'no': '১৮২'});
  await db.insert('ayats2', {'id': 20, 'no': '২০'});
  await db.insert('ayats2', {'id': 2, 'no': '২'});

  var castResult2 = await db.rawQuery('SELECT id, no, CAST(no AS INTEGER) as c FROM ayats2 ORDER BY CAST(no AS INTEGER) ASC');
  print('With just ayat no:');
  for (var row in castResult2) {
    print('id: ${row['id']}, no: ${row['no']}, cast: ${row['c']}');
  }
  
  await db.close();
}
