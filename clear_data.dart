import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

void main() async {
  sqfliteFfiInit();
  var dbFactory = databaseFactoryFfi;
  String path = join(await dbFactory.getDatabasesPath(), 'user_database.db');
  
  print('Deleting database at $path');
  if (await File(path).exists()) {
    await dbFactory.deleteDatabase(path);
    print('Database deleted.');
  } else {
    print('Database does not exist.');
  }

  // To delete SharedPreferences in a pure Dart script without Flutter bindings,
  // we might have to manually delete the file if on Windows.
  // On Windows, SharedPreferences are usually stored in 
  // %APPDATA%\Roaming\com.example\hello_app\shared_preferences.json
  // But since we might not know the exact path, we'll try to use standard means.
}
