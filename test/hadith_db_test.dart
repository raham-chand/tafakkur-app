import 'package:flutter_test/flutter_test.dart';
import 'package:hello_app/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('DatabaseHelper Hadith tables and queries test', () async {
    final dbHelper = DatabaseHelper();
    
    final categories = await dbHelper.getHadithCategories();
    expect(categories.isNotEmpty, true);
    expect(categories.first['title'], 'একজন নামাজির আচরণ কেমন হওয়া উচিত');

    final hadiths = await dbHelper.getAllHadiths();
    expect(hadiths.isNotEmpty, true);
    expect(hadiths.first['hadith'].toString().contains('একজন নামাজির আচরণ কেমন হওয়া উচিত'), true);
  });
}
