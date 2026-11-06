import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    String path = join(await getDatabasesPath(), 'user_database.db');
    return await openDatabase(
      path,
      version: 6,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN fullname TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('CREATE TABLE surahs(id INTEGER PRIMARY KEY AUTOINCREMENT, no INTEGER UNIQUE, name TEXT)');
          await db.execute('CREATE TABLE ayats(id INTEGER PRIMARY KEY AUTOINCREMENT, surah_no INTEGER, no TEXT, arabic TEXT, pronunciation TEXT, meaning TEXT, wordMeaning TEXT, notes TEXT)');
        }
        if (oldVersion < 4) {
          await db.execute('CREATE TABLE salat_guide(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT UNIQUE, content TEXT, references_text TEXT)');
        }
        if (oldVersion < 5) {
          await _createHadithTables(db);
          await _insertInitialHadithData(db);
        }
        if (oldVersion < 6) {
          await db.execute('ALTER TABLE ayats ADD COLUMN tafsir TEXT');
        }
      },
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT, fullname TEXT)');
        await db.execute('CREATE TABLE surahs(id INTEGER PRIMARY KEY AUTOINCREMENT, no INTEGER UNIQUE, name TEXT)');
        await db.execute('CREATE TABLE ayats(id INTEGER PRIMARY KEY AUTOINCREMENT, surah_no INTEGER, no TEXT, arabic TEXT, pronunciation TEXT, meaning TEXT, wordMeaning TEXT, notes TEXT, tafsir TEXT)');
        await db.execute('CREATE TABLE salat_guide(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT UNIQUE, content TEXT, references_text TEXT)');
        await _createHadithTables(db);
        await _insertInitialSalatData(db);
        await _insertInitialHadithData(db);
      },
    );
  }

  Future<void> _createHadithTables(Database db) async {
    await db.execute('CREATE TABLE IF NOT EXISTS hadith_categories(id INTEGER PRIMARY KEY, title TEXT NOT NULL)');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hadiths(
        id INTEGER PRIMARY KEY,
        category_id INTEGER NOT NULL,
        hadith TEXT,
        created_by INTEGER,
        updated_by INTEGER,
        deleted_at TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<void> _insertInitialHadithData(Database db) async {
    await db.execute("INSERT OR IGNORE INTO hadith_categories (id, title) VALUES (1, 'একজন নামাজির আচরণ কেমন হওয়া উচিত')");
  }

  Future<void> _insertInitialSalatData(Database db) async {
    await db.execute("INSERT OR IGNORE INTO salat_guide (title, content, references_text) VALUES ('নামাজির সাধারণ আচরণ', 'সালাত আদায়ের সময় একজন মুমিনের বিনয় ও একাগ্রতা বজায় রাখা জরুরি।', '১. তাফসীরে মাআরিফুল কুরআন\n২. ফাতাওয়া শামী')");
    await db.execute("INSERT OR IGNORE INTO salat_guide (title, content, references_text) VALUES ('মসজিদে যাওয়ার আদব', '১. শান্ত ও ধীরস্থিরভাবে মসজিদে যাওয়া।\n২. আগে থেকে ওজু করে নেওয়া।\n৩. মসজিদে প্রবেশের সময় ডান পা আগে দেওয়া এবং দোয়া পড়া।\n৪. পরিষ্কার ও মার্জিত পোশাক পরিধান করা।', '১. সহীহ বুখারী\n২. রিয়াদুস সালিহীন')");
    await db.execute("INSERT OR IGNORE INTO salat_guide (title, content, references_text) VALUES ('মসজিদের ভেতরের আদব', '১. অপ্রয়োজনীয় কথা না বলা।\n২. মোবাইল ফোন বন্ধ রাখা বা সাইলেন্ট করা।\n৩. কাতার সোজা করে দাঁড়ানো।\n৪. ইবাদতে মশগুল থাকা এবং অন্যদের ডিস্টার্ব না করা।', '১. সহীহ মুসলিম\n২. আল-ফিকহুল ইসলামী')");
    await db.execute("INSERT OR IGNORE INTO salat_guide (title, content, references_text) VALUES ('নামাজ শেষের আমল', 'সালাত শেষে জিকির ও দোয়া করার গুরুত্ব অনেক বেশি।', '১. হিসনুল মুসলিম\n২. সহীহ ইবনে হিব্বান')");
    await db.execute("INSERT OR IGNORE INTO salat_guide (title, content, references_text) VALUES ('সালাতের সঠিক পদ্ধতি', 'রাসূলুল্লাহ (সা.) যেভাবে সালাত আদায় করেছেন তার বিস্তারিত নিয়ম।', '১. রাসূলুল্লাহ (সা.)-এর সালাত\n২. ফিকহুস সুন্নাহ')");
    await db.execute("INSERT OR IGNORE INTO salat_guide (title, content, references_text) VALUES ('আর্থিক অনুদান', 'আস-সালামু আলাইকুম। এই অ্যাপটি সম্পূর্ণ ফ্রি এবং দাওয়াহর উদ্দেশ্যে তৈরি করা হয়েছে। অ্যাপটির মেইনটেইনেন্স এবং নতুন নতুন ফিচার যোগ করার কাজে আপনি চাইলে আর্থিক অনুদান দিয়ে আমাদের সহযোগিতা করতে পারেন। জাযাকাল্লাহু খাইরান।', 'বিকাশ/নগদ: ০১৭০০-০০০০০০\nব্যাংক: ১২৩.৪৫৬.৭৮৯ (ইসলামী ব্যাংক)')");
  }

  Future<void> initQuranData() async {
    final db = await database;
    if (db == null) return;

    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM surahs'));
    if (count != null && count > 0) return;

    final String response = await rootBundle.loadString('assets/quran_data.json');
    final List<dynamic> data = json.decode(response);
    final List<Map<String, dynamic>> surahData = List<Map<String, dynamic>>.from(data);

    await db.transaction((txn) async {
      for (var surah in surahData) {
        await txn.insert('surahs', {
          'no': surah['no'],
          'name': surah['name'],
        });

        for (var ayat in surah['ayats']) {
          await txn.insert('ayats', {
            'surah_no': surah['no'],
            'no': ayat['no'],
            'arabic': ayat['arabic'],
            'pronunciation': ayat['pronunciation'],
            'meaning': ayat['meaning'],
            'wordMeaning': ayat['wordMeaning'],
            'notes': ayat['notes'],
            'tafsir': ayat['tafsir'],
          });
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> getSurahs() async {
    final db = await database;
    if (db == null) return [];
    return await db.query('surahs', orderBy: 'no ASC');
  }

  Future<List<Map<String, dynamic>>> getAyatsBySurah(int surahNo) async {
    final db = await database;
    if (db == null) return [];
    
    final ayats = await db.query('ayats', where: 'surah_no = ?', whereArgs: [surahNo]);
    
    final Map<int, Map<String, dynamic>> uniqueAyats = {};
    for (var ayat in ayats) {
      int ayatNum = _extractAyatNo(ayat['no'].toString());
      if (!uniqueAyats.containsKey(ayatNum)) {
        uniqueAyats[ayatNum] = ayat;
      } else {
        int currentId = int.tryParse(ayat['id'].toString()) ?? 0;
        int existingId = int.tryParse(uniqueAyats[ayatNum]!['id'].toString()) ?? 0;
        if (currentId > existingId) {
          uniqueAyats[ayatNum] = ayat;
        }
      }
    }
    
    var modifiableAyats = uniqueAyats.values.toList();
    modifiableAyats.sort((a, b) {
      int numA = _extractAyatNo(a['no'].toString());
      int numB = _extractAyatNo(b['no'].toString());
      return numA.compareTo(numB);
    });
    
    return modifiableAyats;
  }

  Future<Map<String, dynamic>?> getAyatById(int id) async {
    final db = await database;
    if (db == null) return null;
    final maps = await db.query(
      'ayats',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  int _extractAyatNo(String noText) {
    String text = noText;
    if (text.contains(':')) {
      text = text.split(':').last.trim();
    }
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < bengali.length; i++) {
      text = text.replaceAll(bengali[i], english[i]);
    }
    return int.tryParse(text) ?? 0;
  }

  Future<Map<String, dynamic>?> getSalatTopicByTitle(String title) async {
    final db = await database;
    if (db == null) return null;
    
    final List<Map<String, dynamic>> topics = await db.query('salat_guide');
    if (topics.isEmpty) {
      await _insertInitialSalatData(db);
    }

    final maps = await db.query('salat_guide', where: 'title = ?', whereArgs: [title]);
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<int> updateSalatTopic(String title, Map<String, dynamic> data) async {
    final db = await database;
    if (db == null) return 0;
    return await db.update(
      'salat_guide',
      data,
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  Future<Map<String, dynamic>> syncWithServer(String apiUrl, {bool forceFullSync = false}) async {
    final db = await database;
    if (db == null) return {'status': 'error', 'message': 'Database not initialized'};

    try {
      final prefs = await SharedPreferences.getInstance();
      String lastSync = forceFullSync ? '2000-01-01 00:00:00' : (prefs.getString('last_sync_time') ?? '2000-01-01 00:00:00');

      final response = await http.get(Uri.parse('$apiUrl?last_sync=$lastSync'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);

        if (result['status'] == 'no_update') {
          return {'status': 'no_update', 'message': 'No updates required'};
        }

        if (result['status'] == 'success') {
          final List<dynamic> surahs = result['data']['surahs'] ?? [];
          final List<dynamic> ayats = result['data']['ayats'] ?? [];

          await db.transaction((txn) async {
            if (forceFullSync) {
              await txn.delete('surahs');
              await txn.delete('ayats');
            }

            for (var surah in surahs) {
              await txn.insert(
                'surahs',
                {
                  'id': surah['id'],
                  'no': surah['no'],
                  'name': _sanitizeText(surah['name'] ?? ''),
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }

            for (var ayat in ayats) {
              final existingAyat = await txn.query(
                'ayats',
                where: 'surah_no = ? AND no = ?',
                whereArgs: [ayat['surah_no'], ayat['no']],
              );

              if (existingAyat.isNotEmpty) {
                await txn.update(
                  'ayats',
                  {
                    'arabic': _sanitizeText(ayat['arabic'] ?? ''),
                    'pronunciation': _sanitizeText(ayat['pronunciation'] ?? ''),
                    'meaning': _sanitizeText(ayat['meaning'] ?? ''),
                    'wordMeaning': _sanitizeText(ayat['wordMeaning'] ?? ''),
                    'notes': _sanitizeText(ayat['notes'] ?? ''),
                    'tafsir': _sanitizeText(ayat['tafsir'] ?? ''),
                  },
                  where: 'surah_no = ? AND no = ?',
                  whereArgs: [ayat['surah_no'], ayat['no']],
                );
              } else {
                await txn.insert(
                  'ayats',
                  {
                    'id': ayat['id'],
                    'surah_no': ayat['surah_no'],
                    'no': ayat['no'],
                    'arabic': _sanitizeText(ayat['arabic'] ?? ''),
                    'pronunciation': _sanitizeText(ayat['pronunciation'] ?? ''),
                    'meaning': _sanitizeText(ayat['meaning'] ?? ''),
                    'wordMeaning': _sanitizeText(ayat['wordMeaning'] ?? ''),
                    'notes': _sanitizeText(ayat['notes'] ?? ''),
                    'tafsir': _sanitizeText(ayat['tafsir'] ?? ''),
                  },
                  conflictAlgorithm: ConflictAlgorithm.replace,
                );
              }
            }
          });

          if (result.containsKey('server_time')) {
            await prefs.setString('last_sync_time', result['server_time']);
          }
          
          return {
            'status': 'success', 
            'surahs_count': surahs.length, 
            'ayats_count': ayats.length,
            'is_full_sync': forceFullSync
          };
        } else {
          return {'status': 'error', 'message': result['message']};
        }
      } else {
        return {'status': 'error', 'message': 'Server returned status code ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  String _sanitizeText(String text) {
    return text.replaceAll('<br />', '\n').replaceAll('<br>', '\n').replaceAll('&nbsp;', ' ');
  }

  // ডেটা ডিলিট করে শুধু সূরার আইডি (surahs table) রেখে দেওয়ার জন্য
  Future<void> clearAllDataExceptSurahIds() async {
    final db = await database;
    if (db == null) return;
    
    await db.transaction((txn) async {
      // আয়াতের সমস্ত ডেটা মুছে ফেলা হবে
      await txn.delete('ayats');
      // surahs টেবিল থেকে কিছু ডিলিট হবে না, তাই আইডিগুলো থেকে যাবে
    });

    // সিঙ্কের সময় রিসেট করা
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_sync_time');
  }
}