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

  // ============================================================
  // DATABASE
  // ============================================================

  Future<Database?> get database async {
    if (kIsWeb) return null;

    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String path = join(
      await getDatabasesPath(),
      'user_database.db',
    );

    return await openDatabase(
      path,

      // ==========================================================
      // VERSION 6 → 7
      // ==========================================================

      version: 7,

      // ==========================================================
      // DATABASE UPGRADE
      // ==========================================================

      onUpgrade: (db, oldVersion, newVersion) async {
        // --------------------------------------------------------
        // Version 2
        // --------------------------------------------------------

        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE users ADD COLUMN fullname TEXT',
          );
        }

        // --------------------------------------------------------
        // Version 3
        // --------------------------------------------------------

        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS surahs(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              no INTEGER UNIQUE,
              name TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS ayats(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              surah_no INTEGER,
              no TEXT,
              arabic TEXT,
              pronunciation TEXT,
              meaning TEXT,
              wordMeaning TEXT,
              notes TEXT
            )
          ''');
        }

        // --------------------------------------------------------
        // Version 4
        // --------------------------------------------------------

        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS salat_guide(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT UNIQUE,
              content TEXT,
              references_text TEXT
            )
          ''');
        }

        // --------------------------------------------------------
        // Version 5
        // --------------------------------------------------------

        if (oldVersion < 5) {
          await _createHadithTables(db);
          await _insertInitialHadithData(db);
        }

        // --------------------------------------------------------
        // Version 6
        // --------------------------------------------------------

        if (oldVersion < 6) {
          await db.execute(
            'ALTER TABLE ayats ADD COLUMN tafsir TEXT',
          );
        }

        // --------------------------------------------------------
        // Version 7
        // প্রসঙ্গভেদে শব্দের অর্থ
        // --------------------------------------------------------

        if (oldVersion < 7) {
          await _createContextualMeaningTables(db);
          await _insertInitialContextualMeaningData(db);
        }
      },

      // ==========================================================
      // DATABASE CREATE
      // ==========================================================

      onCreate: (db, version) async {
        // --------------------------------------------------------
        // Users
        // --------------------------------------------------------

        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            fullname TEXT
          )
        ''');

        // --------------------------------------------------------
        // Surahs
        // --------------------------------------------------------

        await db.execute('''
          CREATE TABLE surahs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            no INTEGER UNIQUE,
            name TEXT
          )
        ''');

        // --------------------------------------------------------
        // Ayats
        // --------------------------------------------------------

        await db.execute('''
          CREATE TABLE ayats(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            surah_no INTEGER,
            no TEXT,
            arabic TEXT,
            pronunciation TEXT,
            meaning TEXT,
            wordMeaning TEXT,
            notes TEXT,
            tafsir TEXT
          )
        ''');

        // --------------------------------------------------------
        // Salat Guide
        // --------------------------------------------------------

        await db.execute('''
          CREATE TABLE salat_guide(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT UNIQUE,
            content TEXT,
            references_text TEXT
          )
        ''');

        // --------------------------------------------------------
        // Hadith
        // --------------------------------------------------------

        await _createHadithTables(db);

        // --------------------------------------------------------
        // Contextual Meaning
        // --------------------------------------------------------

        await _createContextualMeaningTables(db);

        // --------------------------------------------------------
        // Initial Data
        // --------------------------------------------------------

        await _insertInitialSalatData(db);
        await _insertInitialHadithData(db);
        await _insertInitialContextualMeaningData(db);
      },
    );
  }

  // ============================================================
  // HADITH TABLES
  // ============================================================

  Future<void> _createHadithTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hadith_categories(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL
      )
    ''');

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

  // ============================================================
  // INITIAL HADITH DATA
  // ============================================================

  Future<void> _insertInitialHadithData(Database db) async {
    await db.execute('''
      INSERT OR IGNORE INTO hadith_categories
      (id, title)
      VALUES
      (1, 'একজন নামাজির আচরণ কেমন হওয়া উচিত')
    ''');
  }

  // ============================================================
  // INITIAL SALAT DATA
  // ============================================================

  Future<void> _insertInitialSalatData(Database db) async {
    await db.execute('''
      INSERT OR IGNORE INTO salat_guide
      (title, content, references_text)
      VALUES
      (
        'নামাজির সাধারণ আচরণ',
        'সালাত আদায়ের সময় একজন মুমিনের বিনয় ও একাগ্রতা বজায় রাখা জরুরি।',
        '১. তাফসীরে মাআরিফুল কুরআন
২. ফাতাওয়া শামী'
      )
    ''');

    await db.execute('''
      INSERT OR IGNORE INTO salat_guide
      (title, content, references_text)
      VALUES
      (
        'মসজিদে যাওয়ার আদব',
        '১. শান্ত ও ধীরস্থিরভাবে মসজিদে যাওয়া।
২. আগে থেকে ওজু করে নেওয়া।
৩. মসজিদে প্রবেশের সময় ডান পা আগে দেওয়া এবং দোয়া পড়া।
৪. পরিষ্কার ও মার্জিত পোশাক পরিধান করা।',
        '১. সহীহ বুখারী
২. রিয়াদুস সালিহীন'
      )
    ''');

    await db.execute('''
      INSERT OR IGNORE INTO salat_guide
      (title, content, references_text)
      VALUES
      (
        'মসজিদের ভেতরের আদব',
        '১. অপ্রয়োজনীয় কথা না বলা।
২. মোবাইল ফোন বন্ধ রাখা বা সাইলেন্ট করা।
৩. কাতার সোজা করে দাঁড়ানো।
৪. ইবাদতে মশগুল থাকা এবং অন্যদের ডিস্টার্ব না করা।',
        '১. সহীহ মুসলিম
২. আল-ফিকহুল ইসলামী'
      )
    ''');

    await db.execute('''
      INSERT OR IGNORE INTO salat_guide
      (title, content, references_text)
      VALUES
      (
        'নামাজ শেষের আমল',
        'সালাত শেষে জিকির ও দোয়া করার গুরুত্ব অনেক বেশি।',
        '১. হিসনুল মুসলিম
২. সহীহ ইবনে হিব্বান'
      )
    ''');

    await db.execute('''
      INSERT OR IGNORE INTO salat_guide
      (title, content, references_text)
      VALUES
      (
        'সালাতের সঠিক পদ্ধতি',
        'রাসূলুল্লাহ (সা.) যেভাবে সালাত আদায় করেছেন তার বিস্তারিত নিয়ম।',
        '১. রাসূলুল্লাহ (সা.)-এর সালাত
২. ফিকহুস সুন্নাহ'
      )
    ''');

    await db.execute('''
      INSERT OR IGNORE INTO salat_guide
      (title, content, references_text)
      VALUES
      (
        'আর্থিক অনুদান',
        'আস-সালামু আলাইকুম। এই অ্যাপটি সম্পূর্ণ ফ্রি এবং দাওয়াহর উদ্দেশ্যে তৈরি করা হয়েছে। অ্যাপটির মেইনটেইনেন্স এবং নতুন নতুন ফিচার যোগ করার কাজে আপনি চাইলে আর্থিক অনুদান দিয়ে আমাদের সহযোগিতা করতে পারেন। জাযাকাল্লাহু খাইরান।',
        'বিকাশ/নগদ: ০১৭০০-০০০০০০
ব্যাংক: ১২৩.৪৫৬.৭৮৯ (ইসলামী ব্যাংক)'
      )
    ''');
  }

  // ============================================================
  // CONTEXTUAL MEANING TABLES
  // ============================================================

  Future<void> _createContextualMeaningTables(Database db) async {
    // ----------------------------------------------------------
    // Main contextual words
    // ----------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS contextual_words(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        color INTEGER NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // ----------------------------------------------------------
    // Contextual usages
    // ----------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS contextual_word_usages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER NOT NULL,
        meaning TEXT NOT NULL,
        grammatical_function TEXT NOT NULL,
        pronunciation TEXT NOT NULL,
        translation TEXT NOT NULL,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        reference TEXT NOT NULL,
        context_explanation TEXT NOT NULL,
        source_note TEXT DEFAULT '',
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(word_id)
          REFERENCES contextual_words(id)
          ON DELETE CASCADE
      )
    ''');

    // ----------------------------------------------------------
    // Index
    // ----------------------------------------------------------

    await db.execute('''
      CREATE INDEX IF NOT EXISTS
      idx_contextual_usages_word_id
      ON contextual_word_usages(word_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS
      idx_contextual_words_sort
      ON contextual_words(sort_order)
    ''');
  }

  // ============================================================
  // INSERT CONTEXTUAL DATA
  // ============================================================

  Future<void> _insertInitialContextualMeaningData(
    Database db,
  ) async {
    // ==========================================================
    // মা
    // ==========================================================

    final maId = await _insertContextualWord(
      db,
      word: 'মা',
      subtitle: 'প্রশ্ন, নাকচ ও “যা / যা কিছু” অর্থে ব্যবহার',
      color: 0xFF2196F3,
      sortOrder: 1,
    );

    await _insertContextualUsage(
      db,
      wordId: maId,
      meaning: 'কী?',
      grammaticalFunction: 'প্রশ্নবোধক',
      pronunciation: 'মা হিয়া',
      translation: 'এটা কী?',
      surahNumber: 2,
      ayahNumber: 68,
      reference: 'সূরা আল-বাকারা — ২:৬৮',
      contextExplanation:
          'এখানে “মা” কোনো বিষয় সম্পর্কে প্রশ্ন করার জন্য ব্যবহৃত হয়েছে।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 1,
    );

    await _insertContextualUsage(
      db,
      wordId: maId,
      meaning: 'যা / যা কিছু',
      grammaticalFunction: 'মাওসূলাহ — সম্পর্কবাচক সর্বনাম',
      pronunciation: 'মা ফিস সামাওয়াতি',
      translation: 'আসমানসমূহে যা কিছু আছে, তা আল্লাহরই।',
      surahNumber: 2,
      ayahNumber: 284,
      reference: 'সূরা আল-বাকারা — ২:২৮৪',
      contextExplanation:
          'এখানে “মা” “যা কিছু” অর্থে ব্যবহৃত হয়েছে এবং আসমানসমূহে বিদ্যমান বিষয়সমূহকে ব্যাপকভাবে বোঝাচ্ছে।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 2,
    );

    await _insertContextualUsage(
      db,
      wordId: maId,
      meaning: 'না / নয়',
      grammaticalFunction: 'নাকচকারী',
      pronunciation: 'ওয়া মা হুম বিমুমিনীন',
      translation: 'আর তারা মুমিন নয়।',
      surahNumber: 2,
      ayahNumber: 8,
      reference: 'সূরা আল-বাকারা — ২:৮',
      contextExplanation:
          'এখানে “মা” দ্বারা একটি বক্তব্যকে নাকচ করা হয়েছে। অর্থাৎ তারা প্রকৃত মুমিন নয়।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 3,
    );

    // ==========================================================
    // মান
    // ==========================================================

    final manId = await _insertContextualWord(
      db,
      word: 'মান',
      subtitle: 'কে, যে ব্যক্তি ও সংশ্লিষ্ট ব্যক্তি বোঝাতে ব্যবহার',
      color: 0xFF4CAF50,
      sortOrder: 2,
    );

    await _insertContextualUsage(
      db,
      wordId: manId,
      meaning: 'কে?',
      grammaticalFunction: 'প্রশ্নবোধক',
      pronunciation: 'মান যাল্লাযি ইউক্রিদুল্লাহা কারদান হাসানান',
      translation: 'কে আল্লাহকে উত্তম ঋণ দেবে?',
      surahNumber: 2,
      ayahNumber: 245,
      reference: 'সূরা আল-বাকারা — ২:২৪৫',
      contextExplanation:
          'এখানে “মান” কোনো ব্যক্তি বা সত্তা সম্পর্কে প্রশ্ন করার জন্য ব্যবহৃত হয়েছে।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 1,
    );

    await _insertContextualUsage(
      db,
      wordId: manId,
      meaning: 'যে / যে ব্যক্তি',
      grammaticalFunction: 'মাওসূলাহ — সম্পর্কবাচক সর্বনাম',
      pronunciation: 'ওয়া মিনান নাসি মান ইয়াকূলু',
      translation: 'আর মানুষের মধ্যে কেউ কেউ বলে...',
      surahNumber: 2,
      ayahNumber: 8,
      reference: 'সূরা আল-বাকারা — ২:৮',
      contextExplanation:
          'এখানে “মান” এমন ব্যক্তিদের বোঝাচ্ছে যারা পরবর্তী বক্তব্যটি বলে।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 2,
    );

    // ==========================================================
    // গাইর
    // ==========================================================

    final ghairId = await _insertContextualWord(
      db,
      word: 'গাইর',
      subtitle: 'ছাড়া, ব্যতীত, অন্য বা ভিন্ন অর্থে ব্যবহার',
      color: 0xFFFF9800,
      sortOrder: 3,
    );

    await _insertContextualUsage(
      db,
      wordId: ghairId,
      meaning: 'ছাড়া / ব্যতীত',
      grammaticalFunction: 'ইসম',
      pronunciation: 'গাইরিল মাগদূবি আলাইহিম',
      translation: 'যাদের ওপর ক্রোধ করা হয়েছে তাদের ছাড়া।',
      surahNumber: 1,
      ayahNumber: 7,
      reference: 'সূরা আল-ফাতিহা — ১:৭',
      contextExplanation:
          'এখানে “গাইর” দ্বারা একটি নির্দিষ্ট শ্রেণি থেকে অন্যদের বাদ দেওয়ার অর্থ প্রকাশ হয়েছে।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 1,
    );

    await _insertContextualUsage(
      db,
      wordId: ghairId,
      meaning: 'অন্য / ভিন্ন',
      grammaticalFunction: 'ইসম',
      pronunciation: 'গাইরাল্লাযি কিলা লাহুম',
      translation: 'তাদেরকে যা বলা হয়েছিল তা ছাড়া অন্য কিছু।',
      surahNumber: 2,
      ayahNumber: 59,
      reference: 'সূরা আল-বাকারা — ২:৫৯',
      contextExplanation:
          'এখানে “গাইর” পূর্বে উল্লেখিত বিষয় থেকে ভিন্ন বা অন্য বিষয় বোঝাচ্ছে।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 2,
    );

    await _insertContextualUsage(
      db,
      wordId: ghairId,
      meaning: 'বিনা / ছাড়া',
      grammaticalFunction: 'ইসম — পূর্ববর্তী হরফের সঙ্গে',
      pronunciation: 'বিগাইরিল হক্ক',
      translation: 'অন্যায়ভাবে / অধিকার ছাড়া।',
      surahNumber: 2,
      ayahNumber: 61,
      reference: 'সূরা আল-বাকারা — ২:৬১',
      contextExplanation:
          'এখানে “গাইর” কোনো বৈধতা বা অধিকারের অনুপস্থিতি বোঝাতে ব্যবহৃত হয়েছে।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 3,
    );

    // ==========================================================
    // ওয়ালী
    // ==========================================================

    final waliId = await _insertContextualWord(
      db,
      word: 'ওয়ালী',
      subtitle: 'অভিভাবক, রক্ষক ও ঘনিষ্ঠ সহায়ক অর্থে ব্যবহার',
      color: 0xFF9C27B0,
      sortOrder: 4,
    );

    await _insertContextualUsage(
      db,
      wordId: waliId,
      meaning: 'অভিভাবক / রক্ষক',
      grammaticalFunction: 'ইসম',
      pronunciation: 'আল্লাহু ওয়ালিয়্যুল্লাযীনা আমানু',
      translation: 'আল্লাহ মুমিনদের অভিভাবক।',
      surahNumber: 2,
      ayahNumber: 257,
      reference: 'সূরা আল-বাকারা — ২:২৫৭',
      contextExplanation:
          'এখানে “ওয়ালী” দ্বারা এমন অভিভাবক ও রক্ষক বোঝানো হয়েছে যিনি মুমিনদের হেফাজত ও পরিচালনার দায়িত্ব নেন।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 1,
    );

    await _insertContextualUsage(
      db,
      wordId: waliId,
      meaning: 'রক্ষক / অভিভাবক',
      grammaticalFunction: 'ইসম',
      pronunciation: 'মিন ওয়ালিয়্যিন ওয়া লা নাসীর',
      translation: 'কোনো অভিভাবক নেই এবং কোনো সাহায্যকারীও নেই।',
      surahNumber: 2,
      ayahNumber: 107,
      reference: 'সূরা আল-বাকারা — ২:১০৭',
      contextExplanation:
          'এখানে “ওয়ালী” এমন একজন রক্ষক বা অভিভাবককে বোঝায় যিনি বিপদ থেকে রক্ষা করতে পারেন।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 2,
    );

    // ==========================================================
    // ফিতনা
    // ==========================================================

    final fitnahId = await _insertContextualWord(
      db,
      word: 'ফিতনাহ',
      subtitle: 'পরীক্ষা, নিপীড়ন ও বিভ্রান্তির প্রসঙ্গে ব্যবহার',
      color: 0xFFF44336,
      sortOrder: 5,
    );

    await _insertContextualUsage(
      db,
      wordId: fitnahId,
      meaning: 'পরীক্ষা',
      grammaticalFunction: 'ইসম',
      pronunciation:
          'ওয়া নাবলুকুম বিশ শাররি ওয়াল খাইরি ফিতনাতান',
      translation: 'আমি তোমাদের মন্দ ও ভালো দ্বারা পরীক্ষা করি।',
      surahNumber: 21,
      ayahNumber: 35,
      reference: 'সূরা আল-আম্বিয়া — ২১:৩৫',
      contextExplanation:
          'এখানে “ফিতনাহ” ভালো ও মন্দ উভয়ের মাধ্যমে মানুষের পরীক্ষা বা যাচাই বোঝাচ্ছে।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 1,
    );

    await _insertContextualUsage(
      db,
      wordId: fitnahId,
      meaning: 'নির্যাতন / নিপীড়ন',
      grammaticalFunction: 'ইসম',
      pronunciation: 'ওয়াল ফিতনাতু আশাদ্দু মিনাল কাতল',
      translation: 'নির্যাতন হত্যার চেয়েও কঠিন।',
      surahNumber: 2,
      ayahNumber: 217,
      reference: 'সূরা আল-বাকারা — ২:২১৭',
      contextExplanation:
          'এখানে “ফিতনাহ” ঈমান থেকে ফিরিয়ে দেওয়ার জন্য নির্যাতন ও নিপীড়নের প্রসঙ্গে ব্যবহৃত হয়েছে।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 2,
    );

    // ==========================================================
    // দীন
    // ==========================================================

    final deenId = await _insertContextualWord(
      db,
      word: 'দীন',
      subtitle: 'ধর্ম ও প্রতিফল/বিচারের অর্থে প্রসঙ্গভেদে ব্যবহার',
      color: 0xFF009688,
      sortOrder: 6,
    );

    await _insertContextualUsage(
      db,
      wordId: deenId,
      meaning: 'বিচার / প্রতিফল',
      grammaticalFunction: 'ইসম',
      pronunciation: 'মালিকি ইয়াওমিদ্দীন',
      translation: 'বিচার দিনের মালিক।',
      surahNumber: 1,
      ayahNumber: 4,
      reference: 'সূরা আল-ফাতিহা — ১:৪',
      contextExplanation:
          'এখানে “দীন” ধর্ম অর্থে নয়; বিচার, প্রতিফল ও হিসাবের দিনের অর্থে ব্যবহৃত হয়েছে।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 1,
    );

    await _insertContextualUsage(
      db,
      wordId: deenId,
      meaning: 'ধর্ম',
      grammaticalFunction: 'ইসম',
      pronunciation: 'লা ইকরাহা ফিদ্দীন',
      translation: 'দ্বীনের ব্যাপারে কোনো জবরদস্তি নেই।',
      surahNumber: 2,
      ayahNumber: 256,
      reference: 'সূরা আল-বাকারা — ২:২৫৬',
      contextExplanation:
          'এখানে “দীন” দ্বারা ধর্ম ও জীবনব্যবস্থাকে বোঝানো হয়েছে।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 2,
    );

    // ==========================================================
    // আমর
    // ==========================================================

    final amrId = await _insertContextualWord(
      db,
      word: 'আমর',
      subtitle: 'আদেশ, বিষয়, ব্যাপার বা সিদ্ধান্তের প্রসঙ্গে ব্যবহার',
      color: 0xFF3F51B5,
      sortOrder: 7,
    );

    await _insertContextualUsage(
      db,
      wordId: amrId,
      meaning: 'আদেশ / নির্দেশ',
      grammaticalFunction: 'ইসম',
      pronunciation: 'বিআমরিহি',
      translation: 'তাঁর আদেশে।',
      surahNumber: 2,
      ayahNumber: 109,
      reference: 'সূরা আল-বাকারা — ২:১০৯',
      contextExplanation:
          'এখানে “আমর” আল্লাহর নির্দেশ বা আদেশের অর্থে ব্যবহৃত হয়েছে।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 1,
    );

    await _insertContextualUsage(
      db,
      wordId: amrId,
      meaning: 'বিষয় / ব্যাপার',
      grammaticalFunction: 'ইসম',
      pronunciation: 'ইযা কাদা আমরান',
      translation: 'যখন তিনি কোনো বিষয় নির্ধারণ করেন।',
      surahNumber: 2,
      ayahNumber: 117,
      reference: 'সূরা আল-বাকারা — ২:১১৭',
      contextExplanation:
          'এখানে “আমর” কোনো বিষয় বা ব্যাপারকে বোঝাচ্ছে যা আল্লাহ নির্ধারণ করেন।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 2,
    );

    await _insertContextualUsage(
      db,
      wordId: amrId,
      meaning: 'সিদ্ধান্ত / বিষয়',
      grammaticalFunction: 'ইসম',
      pronunciation: 'লাইসা লাকা মিনাল আমরি শাইউন',
      translation: 'এই বিষয়ে আপনার কোনো সিদ্ধান্তের অধিকার নেই।',
      surahNumber: 3,
      ayahNumber: 128,
      reference: 'সূরা আলে ইমরান — ৩:১২৮',
      contextExplanation:
          'এখানে “আমর” একটি নির্দিষ্ট বিষয় বা সিদ্ধান্তের প্রসঙ্গে ব্যবহৃত হয়েছে।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 3,
    );

    // ==========================================================
    // আয়াত
    // ==========================================================

    final ayahId = await _insertContextualWord(
      db,
      word: 'আয়াত',
      subtitle: 'নিদর্শন ও কুরআনের আয়াত—দুই প্রসঙ্গে ব্যবহার',
      color: 0xFF795548,
      sortOrder: 8,
    );

    await _insertContextualUsage(
      db,
      wordId: ayahId,
      meaning: 'নিদর্শন / প্রমাণ',
      grammaticalFunction: 'ইসম',
      pronunciation: 'বিআয়াতিনা',
      translation: 'আমাদের নিদর্শনসমূহের প্রতি।',
      surahNumber: 2,
      ayahNumber: 39,
      reference: 'সূরা আল-বাকারা — ২:৩৯',
      contextExplanation:
          'এখানে “আয়াত” আল্লাহর নিদর্শন ও প্রমাণসমূহ বোঝাতে ব্যবহৃত হয়েছে।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 1,
    );

    await _insertContextualUsage(
      db,
      wordId: ayahId,
      meaning: 'আয়াত / বিধানসম্বলিত আয়াত',
      grammaticalFunction: 'ইসম',
      pronunciation: 'আয়াতুন মুহকামাত',
      translation: 'সুস্পষ্ট আয়াতসমূহ।',
      surahNumber: 3,
      ayahNumber: 7,
      reference: 'সূরা আলে ইমরান — ৩:৭',
      contextExplanation:
          'এখানে “আয়াত” কুরআনের আয়াত বা ওহির নির্দিষ্ট অংশ বোঝাতে ব্যবহৃত হয়েছে।',
      sourceNote: 'Quranic Arabic Corpus',
      sortOrder: 2,
    );
  }

  // ============================================================
  // INSERT MAIN CONTEXTUAL WORD
  // ============================================================

  Future<int> _insertContextualWord(
    Database db, {
    required String word,
    required String subtitle,
    required int color,
    required int sortOrder,
  }) async {
    // আগে আছে কিনা দেখি
    final existing = await db.query(
      'contextual_words',
      where: 'word = ?',
      whereArgs: [word],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }

    return await db.insert(
      'contextual_words',
      {
        'word': word,
        'subtitle': subtitle,
        'color': color,
        'sort_order': sortOrder,
        'is_active': 1,
      },
    );
  }

  // ============================================================
  // INSERT CONTEXTUAL USAGE
  // ============================================================

  Future<int> _insertContextualUsage(
    Database db, {
    required int wordId,
    required String meaning,
    required String grammaticalFunction,
    required String pronunciation,
    required String translation,
    required int surahNumber,
    required int ayahNumber,
    required String reference,
    required String contextExplanation,
    String sourceNote = '',
    required int sortOrder,
  }) async {
    // Duplicate usage prevent করার জন্য
    final existing = await db.query(
      'contextual_word_usages',
      where: '''
        word_id = ?
        AND surah_number = ?
        AND ayah_number = ?
        AND meaning = ?
      ''',
      whereArgs: [
        wordId,
        surahNumber,
        ayahNumber,
        meaning,
      ],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }

    return await db.insert(
      'contextual_word_usages',
      {
        'word_id': wordId,
        'meaning': meaning,
        'grammatical_function': grammaticalFunction,
        'pronunciation': pronunciation,
        'translation': translation,
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
        'reference': reference,
        'context_explanation': contextExplanation,
        'source_note': sourceNote,
        'sort_order': sortOrder,
      },
    );
  }

  // ============================================================
  // GET CONTEXTUAL WORDS
  // ============================================================

  Future<List<Map<String, dynamic>>> getContextualWords() async {
    final db = await database;

    if (db == null) return [];

    return await db.query(
      'contextual_words',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'sort_order ASC, id ASC',
    );
  }

  // ============================================================
  // GET CONTEXTUAL WORD USAGES
  // ============================================================

  Future<List<Map<String, dynamic>>> getContextualUsages(
    int wordId,
  ) async {
    final db = await database;

    if (db == null) return [];

    return await db.query(
      'contextual_word_usages',
      where: 'word_id = ?',
      whereArgs: [wordId],
      orderBy: 'sort_order ASC, id ASC',
    );
  }

  // ============================================================
  // GET ALL CONTEXTUAL DATA
  // একবারে সব word + usage
  // ============================================================

  Future<List<Map<String, dynamic>>> getAllContextualMeanings() async {
    final db = await database;

    if (db == null) return [];

    final words = await db.query(
      'contextual_words',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'sort_order ASC, id ASC',
    );

    final List<Map<String, dynamic>> result = [];

    for (final word in words) {
      final usages = await db.query(
        'contextual_word_usages',
        where: 'word_id = ?',
        whereArgs: [word['id']],
        orderBy: 'sort_order ASC, id ASC',
      );

      result.add({
        ...word,
        'meanings': usages,
        'count': usages.length,
      });
    }

    return result;
  }

  // ============================================================
  // GET CONTEXTUAL WORDS WITH USAGES
  // Alias method
  // ============================================================

  Future<List<Map<String, dynamic>>>
      getContextualWordsWithUsages() async {
    return await getAllContextualMeanings();
  }

  // ============================================================
  // ADD NEW CONTEXTUAL WORD
  // ভবিষ্যতে Admin/API থেকে data যোগ করার জন্য
  // ============================================================

  Future<int> addContextualWord({
    required String word,
    required String subtitle,
    required int color,
    int sortOrder = 0,
  }) async {
    final db = await database;

    if (db == null) return 0;

    return await db.insert(
      'contextual_words',
      {
        'word': word,
        'subtitle': subtitle,
        'color': color,
        'sort_order': sortOrder,
        'is_active': 1,
      },
    );
  }

  // ============================================================
  // ADD NEW CONTEXTUAL USAGE
  // ============================================================

  Future<int> addContextualUsage({
    required int wordId,
    required String meaning,
    required String grammaticalFunction,
    required String pronunciation,
    required String translation,
    required int surahNumber,
    required int ayahNumber,
    required String reference,
    required String contextExplanation,
    String sourceNote = '',
    int sortOrder = 0,
  }) async {
    final db = await database;

    if (db == null) return 0;

    return await db.insert(
      'contextual_word_usages',
      {
        'word_id': wordId,
        'meaning': meaning,
        'grammatical_function': grammaticalFunction,
        'pronunciation': pronunciation,
        'translation': translation,
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
        'reference': reference,
        'context_explanation': contextExplanation,
        'source_note': sourceNote,
        'sort_order': sortOrder,
      },
    );
  }

  // ============================================================
  // QURAN DATA
  // ============================================================

  Future<void> initQuranData() async {
    final db = await database;

    if (db == null) return;

    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM surahs',
      ),
    );

    if (count != null && count > 0) {
      return;
    }

    final String response = await rootBundle.loadString(
      'assets/quran_data.json',
    );

    final List<dynamic> data = json.decode(response);

    final List<Map<String, dynamic>> surahData =
        List<Map<String, dynamic>>.from(data);

    await db.transaction((txn) async {
      for (var surah in surahData) {
        await txn.insert(
          'surahs',
          {
            'no': surah['no'],
            'name': surah['name'],
          },
        );

        for (var ayat in surah['ayats']) {
          await txn.insert(
            'ayats',
            {
              'surah_no': surah['no'],
              'no': ayat['no'],
              'arabic': ayat['arabic'],
              'pronunciation': ayat['pronunciation'],
              'meaning': ayat['meaning'],
              'wordMeaning': ayat['wordMeaning'],
              'notes': ayat['notes'],
              'tafsir': ayat['tafsir'],
            },
          );
        }
      }
    });
  }

  // ============================================================
  // GET SURAHS
  // ============================================================

  Future<List<Map<String, dynamic>>> getSurahs() async {
    final db = await database;

    if (db == null) return [];

    return await db.query(
      'surahs',
      orderBy: 'no ASC',
    );
  }

  // ============================================================
  // GET AYATS BY SURAH
  // ============================================================

  Future<List<Map<String, dynamic>>> getAyatsBySurah(
    int surahNo,
  ) async {
    final db = await database;

    if (db == null) return [];

    final ayats = await db.query(
      'ayats',
      where: 'surah_no = ?',
      whereArgs: [surahNo],
    );

    final Map<int, Map<String, dynamic>> uniqueAyats = {};

    for (var ayat in ayats) {
      final int ayatNum =
          _extractAyatNo(ayat['no'].toString());

      if (!uniqueAyats.containsKey(ayatNum)) {
        uniqueAyats[ayatNum] = ayat;
      } else {
        final int currentId =
            int.tryParse(ayat['id'].toString()) ?? 0;

        final int existingId =
            int.tryParse(
                  uniqueAyats[ayatNum]!['id'].toString(),
                ) ??
                0;

        if (currentId > existingId) {
          uniqueAyats[ayatNum] = ayat;
        }
      }
    }

    final modifiableAyats =
        uniqueAyats.values.toList();

    modifiableAyats.sort((a, b) {
      final int numA =
          _extractAyatNo(a['no'].toString());

      final int numB =
          _extractAyatNo(b['no'].toString());

      return numA.compareTo(numB);
    });

    return modifiableAyats;
  }

  // ============================================================
  // GET AYAT BY ID
  // ============================================================

  Future<Map<String, dynamic>?> getAyatById(
    int id,
  ) async {
    final db = await database;

    if (db == null) return null;

    final maps = await db.query(
      'ayats',
      where: 'id = ?',
      whereArgs: [id],
    );

    return maps.isNotEmpty ? maps.first : null;
  }

  // ============================================================
  // EXTRACT AYAT NUMBER
  // ============================================================

  int _extractAyatNo(String noText) {
    String text = noText;

    if (text.contains(':')) {
      text = text.split(':').last.trim();
    }

    const bengali = [
      '০',
      '১',
      '২',
      '৩',
      '৪',
      '৫',
      '৬',
      '৭',
      '৮',
      '৯',
    ];

    const english = [
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
    ];

    for (int i = 0; i < bengali.length; i++) {
      text = text.replaceAll(
        bengali[i],
        english[i],
      );
    }

    return int.tryParse(text) ?? 0;
  }

  // ============================================================
  // GET SALAT TOPIC
  // ============================================================

  Future<Map<String, dynamic>?> getSalatTopicByTitle(
    String title,
  ) async {
    final db = await database;

    if (db == null) return null;

    final List<Map<String, dynamic>> topics =
        await db.query('salat_guide');

    if (topics.isEmpty) {
      await _insertInitialSalatData(db);
    }

    final maps = await db.query(
      'salat_guide',
      where: 'title = ?',
      whereArgs: [title],
    );

    return maps.isNotEmpty ? maps.first : null;
  }

  // ============================================================
  // UPDATE SALAT TOPIC
  // ============================================================

  Future<int> updateSalatTopic(
    String title,
    Map<String, dynamic> data,
  ) async {
    final db = await database;

    if (db == null) return 0;

    return await db.update(
      'salat_guide',
      data,
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  // ============================================================
  // SERVER SYNC
  // ============================================================

  Future<Map<String, dynamic>> syncWithServer(
    String apiUrl, {
    bool forceFullSync = false,
  }) async {
    final db = await database;

    if (db == null) {
      return {
        'status': 'error',
        'message': 'Database not initialized',
        'local_db_updated': false,
        'server_confirmed': false,
      };
    }

    try {
      // ==========================================================
      // Shared Preferences
      // ==========================================================

      final prefs = await SharedPreferences.getInstance();

      final String lastSync = forceFullSync
          ? '2000-01-01 00:00:00'
          : (
              prefs.getString('last_sync_time') ??
              '2000-01-01 00:00:00'
            );

      debugPrint('==========================================');
      debugPrint('🔄 Quran Sync Started');
      debugPrint('📅 Last Sync: $lastSync');
      debugPrint('🌐 API: $apiUrl');
      debugPrint('==========================================');

      // ==========================================================
      // SERVER REQUEST
      // ==========================================================

      final uri = Uri.parse(
        '$apiUrl?last_sync=${Uri.encodeQueryComponent(lastSync)}',
      );

      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
          );

      debugPrint(
        '🌐 Server Status Code: ${response.statusCode}',
      );

      // ==========================================================
      // HTTP ERROR
      // ==========================================================

      if (response.statusCode != 200) {
        debugPrint(
          '❌ Server returned status code: '
          '${response.statusCode}',
        );

        return {
          'status': 'error',
          'message':
              'Server returned status code ${response.statusCode}',
          'local_db_updated': false,
          'server_confirmed': false,
        };
      }

      // ==========================================================
      // JSON DECODE
      // ==========================================================

      Map<String, dynamic> result;

      try {
        final decoded = json.decode(response.body);

        if (decoded is! Map<String, dynamic>) {
          throw const FormatException(
            'Response is not a JSON object',
          );
        }

        result = decoded;
      } catch (e) {
        debugPrint('❌ Invalid JSON response');
        debugPrint(response.body);

        return {
          'status': 'error',
          'message': 'Invalid JSON response from server',
          'local_db_updated': false,
          'server_confirmed': false,
        };
      }

      debugPrint(
        '📦 Server Response Status: ${result['status']}',
      );

      // ==========================================================
      // NO UPDATE
      // ==========================================================

      if (result['status'] == 'no_update') {
        debugPrint('✅ No Quran update available');

        return {
          'status': 'no_update',
          'message': 'No updates required',
          'local_db_updated': false,
          'server_confirmed': true,
        };
      }

      // ==========================================================
      // SERVER ERROR
      // ==========================================================

      if (result['status'] != 'success') {
        debugPrint(
          '❌ Server sync error: ${result['message']}',
        );

        return {
          'status': 'error',
          'message':
              result['message'] ??
              'Unknown server error',
          'local_db_updated': false,
          'server_confirmed': false,
        };
      }

      // ==========================================================
      // DATA
      // ==========================================================

      final Map<String, dynamic> data =
          result['data'] is Map<String, dynamic>
              ? result['data'] as Map<String, dynamic>
              : {};

      final List<dynamic> surahs =
          data['surahs'] is List
              ? data['surahs'] as List<dynamic>
              : [];

      final List<dynamic> ayats =
          data['ayats'] is List
              ? data['ayats'] as List<dynamic>
              : [];

      final List<dynamic> updateIds =
          result['update_ids'] is List
              ? result['update_ids'] as List<dynamic>
              : [];

      debugPrint(
        '📖 Surahs received: ${surahs.length}',
      );

      debugPrint(
        '📜 Ayats received: ${ayats.length}',
      );

      debugPrint(
        '🆔 Update IDs: $updateIds',
      );

      // ==========================================================
      // VALIDATION
      // ==========================================================

      if (surahs.isEmpty && ayats.isEmpty) {
        debugPrint(
          '⚠️ Server said success but no data received',
        );

        return {
          'status': 'error',
          'message': 'No Quran data received from server',
          'local_db_updated': false,
          'server_confirmed': false,
        };
      }

      // ==========================================================
      // LOCAL SQLITE TRANSACTION
      // ==========================================================

      try {
        await db.transaction(
          (txn) async {
            // ======================================================
            // FORCE FULL SYNC
            // ======================================================

            if (forceFullSync) {
              debugPrint(
                '🧹 Force Full Sync: Clearing Quran tables',
              );

              await txn.delete('ayats');
              await txn.delete('surahs');
            }

            // ======================================================
            // SURAH SYNC
            // ======================================================

            for (final item in surahs) {
              if (item is! Map) {
                continue;
              }

              final surah =
                  Map<String, dynamic>.from(item);

              final int? id = int.tryParse(
                surah['id']?.toString() ?? '',
              );

              final int? no = int.tryParse(
                surah['no']?.toString() ?? '',
              );

              final String name = _sanitizeText(
                surah['name']?.toString() ?? '',
              );

              if (id == null || no == null) {
                debugPrint(
                  '⚠️ Invalid Surah data: $surah',
                );
                continue;
              }

              debugPrint(
                '📖 Sync Surah: '
                'id=$id, no=$no, name=$name',
              );

              // ----------------------------------------------------
              // Surah identity = no
              //
              // Existing local row থাকলে UPDATE হবে।
              // না থাকলে INSERT হবে।
              // ----------------------------------------------------

              final existingSurah =
                  await txn.query(
                'surahs',
                where: 'no = ?',
                whereArgs: [no],
                limit: 1,
              );

              if (existingSurah.isNotEmpty) {
                final int localId =
                    existingSurah.first['id'] as int;

                await txn.update(
                  'surahs',
                  {
                    'no': no,
                    'name': name,
                  },
                  where: 'id = ?',
                  whereArgs: [localId],
                );

                debugPrint(
                  '🔄 Surah updated: '
                  'no=$no, localId=$localId',
                );
              } else {
                await txn.insert(
                  'surahs',
                  {
                    'no': no,
                    'name': name,
                  },
                );

                debugPrint(
                  '➕ Surah inserted: no=$no',
                );
              }
            }

            // ======================================================
            // PRELOAD EXISTING AYATS
            //
            // খুব গুরুত্বপূর্ণ:
            //
            // Local DB-তে যদি duplicate থাকে,
            // সেগুলোও আমরা detect করব।
            //
            // Key:
            // surah_no : actual ayat number
            // ======================================================

            final List<Map<String, dynamic>>
                existingAyatRows =
                await txn.query(
              'ayats',
              columns: [
                'id',
                'surah_no',
                'no',
              ],
            );

            final Map<String, List<int>>
                localAyatIds = {};

            for (final row in existingAyatRows) {
              final int? localSurahNo =
                  int.tryParse(
                row['surah_no']?.toString() ?? '',
              );

              final String localNo =
                  row['no']?.toString() ?? '';

              final int localAyatNo =
                  _extractAyatNo(localNo);

              final int? localId =
                  int.tryParse(
                row['id']?.toString() ?? '',
              );

              if (localSurahNo == null ||
                  localId == null ||
                  localAyatNo <= 0) {
                continue;
              }

              final String key =
                  '$localSurahNo:$localAyatNo';

              localAyatIds
                  .putIfAbsent(
                    key,
                    () => [],
                  )
                  .add(localId);
            }

            debugPrint(
              '📦 Existing local ayat rows: '
              '${existingAyatRows.length}',
            );

            // ======================================================
            // AYAT SYNC
            // ======================================================

            int insertedAyats = 0;
            int updatedAyats = 0;

            for (final item in ayats) {
              if (item is! Map) {
                continue;
              }

              final ayat =
                  Map<String, dynamic>.from(item);

              // ----------------------------------------------------
              // SERVER ID
              //
              // Existing local row update করার সময় server ID
              // ব্যবহার করছি না।
              //
              // কারণ local bookmark ID preserve করতে হবে।
              // ----------------------------------------------------

              final int? serverId =
                  int.tryParse(
                ayat['id']?.toString() ?? '',
              );

              // ----------------------------------------------------
              // SURAH NUMBER
              // ----------------------------------------------------

              final int? surahNo =
                  int.tryParse(
                (
                  ayat['surah_no'] ??
                  ayat['sura_id']
                )?.toString() ?? '',
              );

              // ----------------------------------------------------
              // AYAT NUMBER
              // ----------------------------------------------------

              final String ayatNo =
                  (
                    ayat['no'] ??
                    ayat['ayat_no'] ??
                    ''
                  ).toString().trim();

              final int ayatNumber =
                  _extractAyatNo(ayatNo);

              // ----------------------------------------------------
              // TEXT DATA
              // ----------------------------------------------------

              final String arabic =
                  _sanitizeText(
                (
                  ayat['arabic'] ??
                  ayat['ayat_arabic'] ??
                  ''
                ).toString(),
              );

              final String pronunciation =
                  _sanitizeText(
                (
                  ayat['pronunciation'] ??
                  ayat['bn_uchharon'] ??
                  ''
                ).toString(),
              );

              final String meaning =
                  _sanitizeText(
                (
                  ayat['meaning'] ??
                  ayat['ayat_meaning'] ??
                  ''
                ).toString(),
              );

              final String wordMeaning =
                  _sanitizeText(
                (
                  ayat['wordMeaning'] ??
                  ayat['word_meaning'] ??
                  ''
                ).toString(),
              );

              final String notes =
                  _sanitizeText(
                (
                  ayat['notes'] ??
                  ayat['tika'] ??
                  ''
                ).toString(),
              );

              final String tafsir =
                  _sanitizeText(
                ayat['tafsir']?.toString() ?? '',
              );

              // ----------------------------------------------------
              // VALIDATION
              // ----------------------------------------------------

              if (serverId == null ||
                  surahNo == null ||
                  ayatNumber <= 0) {
                debugPrint(
                  '⚠️ Invalid Ayat data: $ayat',
                );
                continue;
              }

              debugPrint(
                '📜 Sync Ayat: '
                'serverId=$serverId, '
                'surah=$surahNo, '
                'ayat=$ayatNumber',
              );

              final Map<String, dynamic>
                  updateData = {
                'surah_no': surahNo,
                'no': ayatNo,
                'arabic': arabic,
                'pronunciation': pronunciation,
                'meaning': meaning,
                'wordMeaning': wordMeaning,
                'notes': notes,
                'tafsir': tafsir,
              };

              // ====================================================
              // IMPORTANT FIX
              //
              // Ayat identity:
              //
              //     surah_no + ayat number
              //
              // NOT:
              //
              //     SQLite id
              // ====================================================

              final String key =
                  '$surahNo:$ayatNumber';

              final List<int> matchingLocalIds =
                  localAyatIds[key] ?? [];

              if (matchingLocalIds.isNotEmpty) {
                // --------------------------------------------------
                // EXISTING AYAT
                //
                // Duplicate থাকলেও সব local row update করছি।
                //
                // এর ফলে:
                //
                // 1. নতুন data পাওয়া যাবে
                // 2. existing bookmark ID থাকবে
                // 3. duplicate থাকার কারণে old data দেখাবে না
                // --------------------------------------------------

                for (final localId
                    in matchingLocalIds) {
                  await txn.update(
                    'ayats',
                    updateData,
                    where: 'id = ?',
                    whereArgs: [localId],
                  );

                  updatedAyats++;

                  debugPrint(
                    '🔄 Ayat updated: '
                    'localId=$localId '
                    'serverId=$serverId '
                    'surah=$surahNo '
                    'ayat=$ayatNumber',
                  );
                }
              } else {
                // --------------------------------------------------
                // NEW AYAT
                //
                // এখানে server ID ব্যবহার করছি না।
                //
                // SQLite নিজে local ID তৈরি করবে।
                //
                // এতে existing local bookmark বা ID collision
                // হওয়ার ঝুঁকি থাকবে না।
                // --------------------------------------------------

                final int newLocalId =
                    await txn.insert(
                  'ayats',
                  {
                    'surah_no': surahNo,
                    'no': ayatNo,
                    'arabic': arabic,
                    'pronunciation': pronunciation,
                    'meaning': meaning,
                    'wordMeaning': wordMeaning,
                    'notes': notes,
                    'tafsir': tafsir,
                  },
                );

                insertedAyats++;

                debugPrint(
                  '➕ Ayat inserted: '
                  'localId=$newLocalId '
                  'serverId=$serverId '
                  'surah=$surahNo '
                  'ayat=$ayatNumber',
                );

                // --------------------------------------------------
                // Map update
                //
                // একই sync response-এ একই ayat আবার এলে
                // duplicate insert হবে না।
                // --------------------------------------------------

                localAyatIds
                    .putIfAbsent(
                      key,
                      () => [],
                    )
                    .add(newLocalId);
              }
            }

            debugPrint(
              '==========================================',
            );

            debugPrint(
              '📊 SQLite Ayat Sync Summary',
            );

            debugPrint(
              '🔄 Updated: $updatedAyats',
            );

            debugPrint(
              '➕ Inserted: $insertedAyats',
            );

            debugPrint(
              '==========================================',
            );
          },
        );

        debugPrint(
          '✅ SQLite transaction completed successfully',
        );
      } catch (e, stackTrace) {
        // ========================================================
        // SQLITE ERROR
        //
        // IMPORTANT:
        // এখানে return করলে confirm_sync.php call হবে না।
        //
        // ফলে:
        //
        // check_update.is_update = 1
        //
        // থাকবে এবং পরেরবার আবার sync হবে।
        // ========================================================

        debugPrint(
          '❌ SQLite transaction failed',
        );

        debugPrint('Error: $e');
        debugPrint('$stackTrace');

        return {
          'status': 'error',
          'message':
              'Local SQLite update failed: $e',
          'local_db_updated': false,
          'server_confirmed': false,
        };
      }

      // ==========================================================
      // SQLITE SUCCESS
      // ==========================================================

      debugPrint(
        '✅ Local SQLite database updated successfully',
      );

      // ==========================================================
      // SAVE LAST SYNC TIME
      //
      // SQLite success হওয়ার পরেই save হবে।
      // ==========================================================

      final String? serverTime =
          result['server_time']?.toString();

      if (serverTime != null &&
          serverTime.isNotEmpty) {
        await prefs.setString(
          'last_sync_time',
          serverTime,
        );

        debugPrint(
          '🕒 Last sync time saved: $serverTime',
        );
      }

      // ==========================================================
      // CONFIRM SERVER SYNC
      //
      // ONLY AFTER SQLITE SUCCESS
      // ==========================================================

      bool serverConfirmed = false;

      if (updateIds.isNotEmpty) {
        try {
          final String confirmUrl =
              apiUrl.replaceFirst(
            'sync_quran.php',
            'confirm_sync.php',
          );

          debugPrint(
            '📤 Sending sync confirmation...',
          );

          debugPrint(
            '🌐 Confirm URL: $confirmUrl',
          );

          final confirmResponse = await http
              .post(
                Uri.parse(confirmUrl),
                headers: {
                  'Content-Type':
                      'application/json',
                  'Accept':
                      'application/json',
                },
                body: json.encode({
                  'update_ids': updateIds,
                }),
              )
              .timeout(
                const Duration(seconds: 30),
              );

          debugPrint(
            '📥 Confirm status: '
            '${confirmResponse.statusCode}',
          );

          if (confirmResponse.statusCode == 200) {
            try {
              final decodedConfirm =
                  json.decode(
                confirmResponse.body,
              );

              if (decodedConfirm
                  is Map<String, dynamic>) {
                final Map<String, dynamic>
                    confirmResult =
                    decodedConfirm;

                if (confirmResult['status'] ==
                    'success') {
                  serverConfirmed = true;

                  debugPrint(
                    '✅ Server sync confirmed',
                  );

                  debugPrint(
                    '🔄 check_update.is_update '
                    'should now be 0',
                  );
                } else {
                  debugPrint(
                    '⚠️ Server confirmation error: '
                    '${confirmResult['message']}',
                  );
                }
              } else {
                debugPrint(
                  '⚠️ Invalid confirmation JSON',
                );
              }
            } catch (e) {
              debugPrint(
                '⚠️ Invalid confirmation response: $e',
              );
            }
          } else {
            debugPrint(
              '⚠️ Confirmation failed with status '
              '${confirmResponse.statusCode}',
            );
          }
        } catch (e, stackTrace) {
          // ======================================================
          // Local DB already updated.
          //
          // Server confirmation failed.
          //
          // Therefore:
          // local data = updated
          // server flag = may remain 1
          //
          // Next sync safely updates the same rows again.
          // ======================================================

          debugPrint(
            '⚠️ Server confirmation failed: $e',
          );

          debugPrint('$stackTrace');
        }
      } else {
        serverConfirmed = true;

        debugPrint(
          'ℹ️ No update IDs received; confirmation skipped',
        );
      }

      // ==========================================================
      // FINAL RESULT
      // ==========================================================

      debugPrint('==========================================');
      debugPrint('✅ Quran Sync Finished');

      debugPrint(
        '📖 Surahs: ${surahs.length}',
      );

      debugPrint(
        '📜 Ayats: ${ayats.length}',
      );

      debugPrint(
        '💾 Local DB: SUCCESS',
      );

      debugPrint(
        '🌐 Server Confirmed: $serverConfirmed',
      );

      debugPrint('==========================================');

      return {
        'status': 'success',
        'surahs_count': surahs.length,
        'ayats_count': ayats.length,
        'is_full_sync': forceFullSync,
        'local_db_updated': true,
        'server_confirmed': serverConfirmed,
        'update_ids': updateIds,
      };
    } catch (e, stackTrace) {
      // ==========================================================
      // GENERAL ERROR
      // ==========================================================

      debugPrint(
        '❌ Quran Sync Failed',
      );

      debugPrint('Error: $e');
      debugPrint('$stackTrace');

      return {
        'status': 'error',
        'message': e.toString(),
        'local_db_updated': false,
        'server_confirmed': false,
      };
    }
  }

  // ============================================================
  // SANITIZE TEXT
  // ============================================================

  String _sanitizeText(String text) {
    return text
        .replaceAll('<br />', '\n')
        .replaceAll('<br/>', '\n')
        .replaceAll('<br>', '\n')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  // ============================================================
  // CLEAR AYAT DATA
  // ============================================================

  Future<void> clearAllDataExceptSurahIds() async {
    final db = await database;

    if (db == null) return;

    await db.transaction((txn) async {
      await txn.delete('ayats');

      // surahs table untouched
    });

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('last_sync_time');
  }
}