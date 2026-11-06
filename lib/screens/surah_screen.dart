import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../database/database_helper.dart';
import '../main.dart';
import 'arabic_grammar_screen.dart';
import 'contextual_meaning_screen.dart';

class SurahScreen extends StatefulWidget {
  final String username;

  const SurahScreen({
    super.key,
    required this.username,
  });

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  static bool _isDisclaimerShown = false;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> _surahData = [];
  List<Map<String, dynamic>> _ayatData = [];

  int? _selectedSurahNo;
  int? _selectedAyatId;

  List<int> _bookmarkedAyatIds = [];

  // Expand / Collapse states
  bool _isNotesExpanded = false;
  bool _isTafsirExpanded = false;
  bool _isGrammarExpanded = false; // ব্যাকরণ পরিচিতির টগল স্টেট

  // Font size multipliers
  double _arabicFontScale = 1.0;
  double _textFontScale = 1.0;

  // Username controller
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController(
      text: widget.username,
    );

    _loadPreferences();
    _loadInitialData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (!_isDisclaimerShown) {
        _showDisclaimerDialog();
        _isDisclaimerShown = true;
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // ============================================================
  // PREFERENCES
  // ============================================================

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _arabicFontScale =
            prefs.getDouble('arabic_font_scale') ?? 1.0;

        _textFontScale =
            prefs.getDouble('text_font_scale') ?? 1.0;
      });

      await _loadBookmarks();
    } catch (e) {
      debugPrint('❌ Error loading preferences: $e');
    }
  }

  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<String> bks =
          prefs.getStringList('bookmarks') ?? [];

      final List<int> bookmarkIds = [];

      for (final item in bks) {
        final id = int.tryParse(item);

        if (id != null) {
          bookmarkIds.add(id);
        }
      }

      if (!mounted) return;

      setState(() {
        _bookmarkedAyatIds = bookmarkIds;
      });
    } catch (e) {
      debugPrint('❌ Error loading bookmarks: $e');
    }
  }

  // ============================================================
  // BOOKMARK
  // ============================================================

  Future<void> _toggleBookmark(int ayatId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        if (_bookmarkedAyatIds.contains(ayatId)) {
          _bookmarkedAyatIds.remove(ayatId);
        } else {
          _bookmarkedAyatIds.add(ayatId);
        }
      });

      await prefs.setStringList(
        'bookmarks',
        _bookmarkedAyatIds
            .map((e) => e.toString())
            .toList(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _bookmarkedAyatIds.contains(ayatId)
                ? 'বুকমার্কে যুক্ত করা হয়েছে!'
                : 'বুকমার্ক থেকে সরানো হয়েছে!',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      debugPrint('❌ Bookmark error: $e');
    }
  }

  // ============================================================
  // LAST READ
  // ============================================================

  Future<void> _saveLastRead(
    int surahNo,
    int ayatId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(
        'last_surah',
        surahNo,
      );

      await prefs.setInt(
        'last_ayat',
        ayatId,
      );
    } catch (e) {
      debugPrint('❌ Error saving last read: $e');
    }
  }

  // ============================================================
  // INITIAL DATA
  // ============================================================

  Future<void> _loadInitialData() async {
    try {
      final surahs = await _dbHelper.getSurahs();

      if (surahs.isEmpty) {
        debugPrint('⚠️ No Surah data found in SQLite.');
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      int targetSurahNo;

      final savedSurah =
          prefs.getInt('last_surah');

      if (savedSurah != null &&
          surahs.any(
            (s) =>
                int.tryParse(
                  s['no'].toString(),
                ) ==
                savedSurah,
          )) {
        targetSurahNo = savedSurah;
      } else {
        targetSurahNo =
            int.tryParse(
              surahs.first['no'].toString(),
            ) ??
            1;
      }

      final int? targetAyatId =
          prefs.getInt('last_ayat');

      final ayats =
          await _dbHelper.getAyatsBySurah(
        targetSurahNo,
      );

      int? selectedAyat;

      if (targetAyatId != null &&
          ayats.any(
            (a) =>
                int.tryParse(
                  a['id'].toString(),
                ) ==
                targetAyatId,
          )) {
        selectedAyat = targetAyatId;
      } else if (ayats.isNotEmpty) {
        selectedAyat =
            int.tryParse(
              ayats.first['id'].toString(),
            );
      }

      if (!mounted) return;

      // প্রথম আয়াত চেক করে ব্যাকরণ সেকশনের ডিফল্ট স্টেট সেট করা
      bool isFirstAyat = false;
      if (ayats.isNotEmpty && selectedAyat != null) {
        isFirstAyat = int.tryParse(ayats.first['id'].toString()) == selectedAyat;
      }

      setState(() {
        _surahData = surahs;
        _ayatData = ayats;
        _selectedSurahNo = targetSurahNo;
        _selectedAyatId = selectedAyat;
        _isGrammarExpanded = isFirstAyat; // প্রথম আয়াতে বাই-ডিফল্ট ওপেন
      });

      if (selectedAyat != null) {
        await _saveLastRead(
          targetSurahNo,
          selectedAyat,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading initial data: $e');
      debugPrint(stackTrace.toString());
    }
  }

  // ============================================================
  // CHANGE SURAH
  // ============================================================

  Future<void> _onSurahChanged(
    int surahNo,
  ) async {
    try {
      final ayats =
          await _dbHelper.getAyatsBySurah(
        surahNo,
      );

      int? selectedAyat;

      if (ayats.isNotEmpty) {
        selectedAyat =
            int.tryParse(
              ayats.first['id'].toString(),
            );
      }

      if (!mounted) return;

      setState(() {
        _selectedSurahNo = surahNo;
        _ayatData = ayats;
        _selectedAyatId = selectedAyat;

        _isNotesExpanded = false;
        _isTafsirExpanded = false;
        _isGrammarExpanded = true; // নতুন সূরার প্রথম আয়াতে ডিফল্ট ওপেন
      });

      if (selectedAyat != null) {
        await _saveLastRead(
          surahNo,
          selectedAyat,
        );
      }
    } catch (e) {
      debugPrint('❌ Error changing Surah: $e');
    }
  }

  // ============================================================
  // DISCLAIMER
  // ============================================================

  void _showDisclaimerDialog() {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ZoomIn(
        duration:
            const Duration(milliseconds: 400),
        child: AlertDialog(
          backgroundColor: isDark
              ? const Color(0xFF1A1C2C)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(25),
            side: BorderSide(
              color:
                  Colors.amberAccent.withAlpha(50),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Colors.amberAccent,
                size: 28,
              ),
              const SizedBox(width: 15),
              Text(
                'জরুরি বার্তা',
                style: GoogleFonts.hindSiliguri(
                  color: isDark
                      ? Colors.amberAccent
                      : Colors.black87,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          content:
              SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'আস-সালামু আলাইকুম,',
                  style:
                      GoogleFonts.hindSiliguri(
                    color: isDark
                        ? Colors.white
                        : Colors.black87,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '১. বাংলায় আরবি উচ্চারণ পুরোপুরি নির্ভুলভাবে করা সম্ভব নয়, তাই উচ্চারণে কিছু সীমাবদ্ধতা বা ভুল থাকতে পারে।\n\n'
                  '২. আমাদের মূল লক্ষ্য হলো কুরআনের প্রতিটি শব্দের সঠিক অর্থ তুলে ধরা, যাতে আমরা যারা আরবি জানি না তারা পবিত্র কুরআন যথাসম্ভব বুঝে পড়তে পারি।\n\n'
                  '৩. আমাদের অনিচ্ছাকৃত ভুল-ত্রুটিগুলো ক্ষমাসুন্দর দৃষ্টিতে দেখবেন।',
                  style:
                      GoogleFonts.hindSiliguri(
                    color: isDark
                        ? Colors.white70
                        : Colors.black54,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.amberAccent,
                  foregroundColor:
                      Colors.black87,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                ),
                onPressed: () =>
                    Navigator.pop(context),
                child: Text(
                  'বুঝেছি',
                  style:
                      GoogleFonts.hindSiliguri(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  void _showSettingsBottomSheet(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    _usernameController.text =
        widget.username;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? const Color(0xFF1A1C2C)
          : Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 25,
                right: 25,
                top: 25,
                bottom:
                    MediaQuery.of(context)
                            .viewInsets
                            .bottom +
                        35,
              ),
              child:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration:
                            BoxDecoration(
                          color: isDark
                              ? Colors.white24
                              : Colors.black26,
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'প্রফেশনাল সেটিংস',
                      style:
                          GoogleFonts.hindSiliguri(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Colors.amberAccent,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Divider(
                      color: isDark
                          ? Colors.white10
                          : Colors.black12,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'ইউজারনেম পরিবর্তন',
                      style:
                          GoogleFonts.hindSiliguri(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                        color: isDark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller:
                          _usernameController,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : Colors.black87,
                      ),
                      decoration:
                          InputDecoration(
                        hintText:
                            'আপনার নাম লিখুন',
                        filled: true,
                        fillColor: isDark
                            ? Colors.white
                                .withAlpha(10)
                            : Colors.black
                                .withAlpha(5),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                      onSubmitted:
                          (value) async {
                        final name =
                            value.trim();

                        if (name.isNotEmpty) {
                          MyApp.of(context)
                              ?.updateUsername(
                            name,
                          );

                          Navigator.pop(context);
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'থিম মোড',
                      style:
                          GoogleFonts.hindSiliguri(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                        color: isDark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        _buildThemeButton(
                          'লাইট',
                          ThemeMode.light,
                          isDark,
                        ),
                        _buildThemeButton(
                          'ডার্ক',
                          ThemeMode.dark,
                          isDark,
                        ),
                        _buildThemeButton(
                          'সিস্টেম',
                          ThemeMode.system,
                          isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'আরবি ফন্ট সাইজ: ${(_arabicFontScale * 100).toInt()}%',
                      style:
                          GoogleFonts.hindSiliguri(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                        color: isDark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),

                    Slider(
                      value: _arabicFontScale,
                      min: 0.8,
                      max: 1.8,
                      divisions: 5,
                      activeColor:
                          Colors.amberAccent,
                      onChanged:
                          (val) async {
                        if (!mounted) return;

                        setState(() {
                          _arabicFontScale =
                              val;
                        });

                        setModalState(() {});

                        final prefs =
                            await SharedPreferences
                                .getInstance();

                        await prefs.setDouble(
                          'arabic_font_scale',
                          val,
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'টেক্সট/অনুবাদ ফন্ট সাইজ: ${(_textFontScale * 100).toInt()}%',
                      style:
                          GoogleFonts.hindSiliguri(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                        color: isDark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),

                    Slider(
                      value: _textFontScale,
                      min: 0.8,
                      max: 1.5,
                      divisions: 4,
                      activeColor:
                          Colors.amberAccent,
                      onChanged:
                          (val) async {
                        if (!mounted) return;

                        setState(() {
                          _textFontScale =
                              val;
                        });

                        setModalState(() {});

                        final prefs =
                            await SharedPreferences
                                .getInstance();

                        await prefs.setDouble(
                          'text_font_scale',
                          val,
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.amberAccent,
                          foregroundColor:
                              Colors.black87,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 12,
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pop(
                          context,
                        ),
                        child: Text(
                          'সংরক্ষণ করুন',
                          style:
                              GoogleFonts
                                  .hindSiliguri(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeButton(
    String title,
    ThemeMode mode,
    bool isDark,
  ) {
    final currentTheme =
        Theme.of(context).brightness ==
                Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light;

    final isSelected =
        currentTheme == mode;

    return Expanded(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        child: ElevatedButton(
          style:
              ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Colors.amberAccent
                : (isDark
                    ? Colors.white
                        .withAlpha(15)
                    : Colors.black
                        .withAlpha(10)),
            foregroundColor: isSelected
                ? Colors.black87
                : (isDark
                    ? Colors.white
                    : Colors.black87),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            MyApp.of(context)
                ?.updateThemeMode(mode);

            Navigator.pop(context);
          },
          child: Text(
            title,
            style:
                GoogleFonts.hindSiliguri(
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOOKMARK BOTTOM SHEET
  // ============================================================

  Future<void> _showBookmarksBottomSheet(
    BuildContext context,
  ) async {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final List<
        Map<String, dynamic>> bookmarkedAyats =
        [];

    for (final id in _bookmarkedAyatIds) {
      final ayat =
          await _dbHelper.getAyatById(id);

      if (ayat != null) {
        bookmarkedAyats.add(ayat);
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? const Color(0xFF1A1C2C)
          : Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) =>
          Container(
        height:
            MediaQuery.of(context)
                    .size
                    .height *
                0.6,
        padding:
            const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration:
                    BoxDecoration(
                  color: isDark
                      ? Colors.white24
                      : Colors.black26,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              'বুকমার্ক করা আয়াতসমূহ',
              style:
                  GoogleFonts.hindSiliguri(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
                color:
                    Colors.amberAccent,
              ),
            ),

            const Divider(),

            const SizedBox(height: 10),

            Expanded(
              child:
                  bookmarkedAyats.isEmpty
                      ? Center(
                          child: Text(
                            'কোনো বুকমার্ক নেই',
                            style:
                                GoogleFonts
                                    .hindSiliguri(
                              color: isDark
                                  ? Colors.white54
                                  : Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              bookmarkedAyats
                                  .length,
                          itemBuilder:
                              (context,
                                  index) {
                            final item =
                                bookmarkedAyats[
                                    index];

                            final int? itemId =
                                int.tryParse(
                              item['id']
                                  .toString(),
                            );

                            final int? itemSurahNo =
                                int.tryParse(
                              item['surah_no']
                                  .toString(),
                            );

                            if (itemId ==
                                    null ||
                                itemSurahNo ==
                                    null) {
                              return const SizedBox();
                            }

                            return ListTile(
                              title: Text(
                                item['arabic']
                                        ?.toString() ??
                                    '',
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    GoogleFonts
                                        .amiri(
                                  color: isDark
                                      ? Colors
                                          .tealAccent
                                      : Colors
                                          .teal
                                          .shade800,
                                ),
                              ),
                              subtitle: Text(
                                item['meaning']
                                        ?.toString() ??
                                    '',
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    GoogleFonts
                                        .hindSiliguri(
                                  color: isDark
                                      ? Colors
                                          .white70
                                      : Colors
                                          .black87,
                                ),
                              ),
                              trailing:
                                  IconButton(
                                icon:
                                    const Icon(
                                  Icons
                                      .delete_outline,
                                  color: Colors
                                      .redAccent,
                                ),
                                onPressed:
                                    () async {
                                  await _toggleBookmark(
                                    itemId,
                                  );

                                  if (context
                                      .mounted) {
                                    Navigator.pop(
                                        context);

                                    _showBookmarksBottomSheet(
                                      context,
                                    );
                                  }
                                },
                              ),
                              onTap:
                                  () async {
                                Navigator.pop(
                                  context,
                                );

                                await _onSurahChanged(
                                  itemSurahNo,
                                );

                                if (!mounted)
                                  return;

                                setState(() {
                                  _selectedAyatId =
                                      itemId;

                                  _isNotesExpanded =
                                      false;

                                  _isTafsirExpanded =
                                      false;
                                });

                                await _saveLastRead(
                                  itemSurahNo,
                                  itemId,
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration:
            BoxDecoration(
          gradient:
              LinearGradient(
            begin:
                Alignment.topCenter,
            end:
                Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF1A1C2C),
                    Color(0xFF232538),
                  ]
                : const [
                    Color(0xFFF8F9FA),
                    Color(0xFFE9ECEF),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: FadeInDown(
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'আস-সালামু আলাইকুম,',
                            style:
                                GoogleFonts.outfit(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white60
                                  : Colors.black54,
                            ),
                          ),
                          Text(
                            widget.username,
                            style:
                                GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                _showBookmarksBottomSheet(
                              context,
                            ),
                            child: Container(
                              padding:
                                  const EdgeInsets
                                      .all(8),
                              decoration:
                                  BoxDecoration(
                                color: isDark
                                    ? Colors.white
                                        .withAlpha(
                                            20)
                                    : Colors.black
                                        .withAlpha(
                                            10),
                                shape:
                                    BoxShape.circle,
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .bookmark_rounded,
                                color: Colors
                                    .amberAccent,
                                size: 22,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          GestureDetector(
                            onTap: () =>
                                _showSettingsBottomSheet(
                              context,
                            ),
                            child: Container(
                              padding:
                                  const EdgeInsets
                                      .all(8),
                              decoration:
                                  BoxDecoration(
                                color: isDark
                                    ? Colors.white
                                        .withAlpha(
                                            20)
                                    : Colors.black
                                        .withAlpha(
                                            10),
                                shape:
                                    BoxShape.circle,
                              ),
                              child: Icon(
                                Icons
                                    .settings_rounded,
                                color: isDark
                                    ? Colors
                                        .amberAccent
                                    : Colors
                                        .deepPurple,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // MENU
              // ==================================================

              FadeInRight(
                child: SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection:
                        Axis.horizontal,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 20,
                    ),
                    children: [
                      _buildMenuBarItem(
                        context,
                        Icons
                            .volunteer_activism_outlined,
                        'অনুদান',
                        isHighlighted: true,
                      ),
                      _buildMenuBarItem(
                        context,
                        Icons
                            .info_outline_rounded,
                        'ব্যাকরণ',
                      ),
                      _buildMenuBarItem(
                        context,
                        Icons
                            .info_outline_rounded,
                        'প্রসঙ্গভেদে শব্দের অর্থ',
                      ),
                      _buildMenuBarItem(
                        context,
                        Icons
                            .info_outline_rounded,
                        'আমাদের সম্পর্কে',
                      ),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // SURAH / AYAT DROPDOWN
              // ==================================================

              Container(
                padding:
                    const EdgeInsets.all(
                  12,
                ),
                margin:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                decoration:
                    BoxDecoration(
                  color: isDark
                      ? Colors.white
                          .withAlpha(10)
                      : Colors.black
                          .withAlpha(5),
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                  border:
                      Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child:
                          DropdownButton<int>(
                        isExpanded:
                            true,
                        value:
                            _selectedSurahNo,
                        hint: Text(
                          'সূরা নির্বাচন',
                          style: TextStyle(
                            color: isDark
                                ? Colors
                                    .white54
                                : Colors
                                    .black54,
                          ),
                        ),
                        dropdownColor:
                            isDark
                                ? const Color(
                                    0xFF232538)
                                : Colors.white,
                        underline:
                            const SizedBox(),
                        style:
                            GoogleFonts
                                .hindSiliguri(
                          color: isDark
                              ? Colors.white
                              : Colors.black87,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                        items:
                            _surahData
                                .map(
                          (surah) {
                            final int sNo =
                                int.tryParse(
                                      surah['no']
                                          .toString(),
                                    ) ??
                                    0;

                            return DropdownMenuItem<
                                int>(
                              value: sNo,
                              child: Text(
                                '${_toBengali(sNo.toString())}. ${surah['name'] ?? ''}',
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                            );
                          },
                        ).toList(),
                        onChanged:
                            (val) {
                          if (val != null) {
                            _onSurahChanged(
                              val,
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child:
                          DropdownButton<int>(
                        isExpanded:
                            true,
                        value:
                            _selectedAyatId,
                        hint: Text(
                          'আয়াত নং',
                          style: TextStyle(
                            color: isDark
                                ? Colors
                                    .white54
                                : Colors
                                    .black54,
                          ),
                        ),
                        dropdownColor:
                            isDark
                                ? const Color(
                                    0xFF232538)
                                : Colors.white,
                        underline:
                            const SizedBox(),
                        style:
                            GoogleFonts
                                .hindSiliguri(
                          color: isDark
                              ? Colors.white
                              : Colors.black87,
                          fontSize: 16,
                        ),
                        items:
                            _ayatData
                                .map(
                          (ayat) {
                            final int? aId =
                                int.tryParse(
                              ayat['id']
                                  .toString(),
                            );

                            if (aId == null) {
                              return null;
                            }

                            return DropdownMenuItem<
                                int>(
                              value: aId,
                              child: Text(
                                '${_toBengali((_selectedSurahNo ?? 0).toString())}:${_toBengali(_getAyatNoOnly(ayat['no']?.toString() ?? ''))}',
                                style:
                                    GoogleFonts
                                        .hindSiliguri(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                            );
                          },
                        )
                                .whereType<
                                    DropdownMenuItem<
                                        int>>()
                                .toList(),
                        onChanged:
                            (val) {
                          if (val != null &&
                              _selectedSurahNo !=
                                  null) {
                            // চেক করুন নতুন সিলেক্ট করা আয়াতটি প্রথম আয়াত কিনা
                            bool isFirst = false;
                            if (_ayatData.isNotEmpty) {
                              isFirst = int.tryParse(_ayatData.first['id'].toString()) == val;
                            }

                            setState(() {
                              _selectedAyatId =
                                  val;

                              _isNotesExpanded =
                                  false;

                              _isTafsirExpanded =
                                  false;

                              _isGrammarExpanded = isFirst; // প্রথম আয়াতে ওপেন, অন্যথায় বন্ধ
                            });

                            _saveLastRead(
                              _selectedSurahNo!,
                              val,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // SURAH TITLE
              // ==================================================

              if (_selectedSurahNo != null)
                FadeInDown(
                  child: Center(
                    child: Text(
                      '${_toBengali(_selectedSurahNo.toString())}. ${_getSelectedSurahName()}',
                      style:
                          GoogleFonts.hindSiliguri(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                        color: isDark
                            ? Colors.amberAccent
                            : Colors.amber.shade900,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 5),

              // ==================================================
              // AYAT CONTENT
              // ==================================================

              if (_selectedAyatId != null &&
                  _getSelectedAyat() != null)
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 20,
                    ),
                    child: Builder(
                      builder: (context) {
                        final ayat =
                            _getSelectedAyat()!;

                        final int? ayatId =
                            int.tryParse(
                          ayat['id']
                              .toString(),
                        );

                        if (ayatId == null) {
                          return const SizedBox();
                        }

                        final isBookmarked =
                            _bookmarkedAyatIds
                                .contains(
                          ayatId,
                        );

                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Align(
                              alignment:
                                  Alignment
                                      .centerRight,
                              child:
                                  IconButton(
                                icon: Icon(
                                  isBookmarked
                                      ? Icons
                                          .bookmark_rounded
                                      : Icons
                                          .bookmark_border_rounded,
                                  color: isBookmarked
                                      ? Colors
                                          .amberAccent
                                      : (isDark
                                          ? Colors
                                              .white70
                                          : Colors
                                              .black54),
                                  size: 26,
                                ),
                                onPressed:
                                    () =>
                                        _toggleBookmark(
                                  ayatId,
                                ),
                              ),
                            ),

                            _buildDataRow(
                              'আয়াত',
                              ayat['arabic']
                                      ?.toString() ??
                                  '',
                              Icons
                                  .auto_awesome_rounded,
                              isArabic: true,
                              isDark: isDark,
                            ),

                            _buildDataRow(
                              'উচ্চারণ',
                              ayat['pronunciation']
                                      ?.toString() ??
                                  '',
                              Icons
                                  .volume_up_rounded,
                              isDark: isDark,
                            ),

                            _buildDataRow(
                              'অর্থ',
                              ayat['meaning']
                                      ?.toString() ??
                                  '',
                              Icons
                                  .translate_rounded,
                              isDark: isDark,
                            ),

                            _buildWordMeaningSection(
                              ayat['wordMeaning']
                                      ?.toString() ??
                                  '',
                              isDark: isDark,
                            ),

                            // ব্যাকরণ পরিচিতি (টগল ও ডিফল্ট ওপেন লজিক সহ)
                            _buildGrammarTermsCollapsible(isDark: isDark),

                            _buildNoteSection(
                              ayat['notes']
                                      ?.toString() ??
                                  '',
                              isDark: isDark,
                            ),

                            _buildTafsirSection(
                              ayat['tafsir']
                                      ?.toString() ??
                                  '',
                              isDark: isDark,
                            ),

                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text(
                      'কোনো আয়াত পাওয়া যায়নি',
                    ),
                  ),
                ),

              // ==================================================
              // PREVIOUS / NEXT
              // ==================================================

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration:
                    BoxDecoration(
                  color: isDark
                      ? const Color(
                          0xFF1A1C2C)
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withAlpha(
                        isDark ? 50 : 15,
                      ),
                      blurRadius: 10,
                      offset:
                          const Offset(
                        0,
                        -5,
                      ),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            isDark
                                ? Colors
                                    .white
                                    .withAlpha(
                                        20)
                                : Colors
                                    .black
                                    .withAlpha(
                                        10),
                        foregroundColor:
                            isDark
                                ? Colors.white
                                : Colors.black87,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                      ),
                      onPressed:
                          _getPreviousAyat() !=
                                  null
                              ? () {
                                  final prev =
                                      _getPreviousAyat();

                                  if (prev !=
                                      null) {
                                    final id =
                                        int.tryParse(
                                      prev['id']
                                          .toString(),
                                    );

                                    if (id ==
                                        null) {
                                      return;
                                    }

                                    setState(
                                      () {
                                        _selectedAyatId =
                                            id;

                                        _isNotesExpanded =
                                            false;

                                        _isTafsirExpanded =
                                            false;

                                        _isGrammarExpanded = false; // পরের/আগের আয়াতে যাওয়ার পর এটি ডিফল্ট বন্ধ থাকবে
                                      },
                                    );

                                    if (_selectedSurahNo !=
                                        null) {
                                      _saveLastRead(
                                        _selectedSurahNo!,
                                        id,
                                      );
                                    }
                                  }
                                }
                              : null,
                      icon:
                          const Icon(
                        Icons
                            .arrow_back_ios_new,
                        size: 16,
                      ),
                      label: Text(
                        'আগের আয়াত',
                        style: GoogleFonts
                            .hindSiliguri(),
                      ),
                    ),

                    ElevatedButton(
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.tealAccent
                                .withAlpha(
                                    30),
                        foregroundColor:
                            isDark
                                ? Colors
                                    .tealAccent
                                : Colors
                                    .teal
                                    .shade800,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                      ),
                      onPressed:
                          _getNextAyat() !=
                                  null
                              ? () {
                                  final next =
                                      _getNextAyat();

                                  if (next !=
                                      null) {
                                    final id =
                                        int.tryParse(
                                      next['id']
                                          .toString(),
                                    );

                                    if (id ==
                                        null) {
                                      return;
                                    }

                                    setState(
                                      () {
                                        _selectedAyatId =
                                            id;

                                        _isNotesExpanded =
                                            false;

                                        _isTafsirExpanded =
                                            false;

                                        _isGrammarExpanded = false; // পরের আয়াতে বন্ধ থাকবে
                                      },
                                    );

                                    if (_selectedSurahNo !=
                                        null) {
                                      _saveLastRead(
                                        _selectedSurahNo!,
                                        id,
                                      );
                                    }
                                  }
                                }
                              : null,
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Text(
                            'পরের আয়াত',
                            style:
                                GoogleFonts
                                    .hindSiliguri(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                              width: 8),
                          const Icon(
                            Icons
                                .arrow_forward_ios,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SELECTED SURAH NAME
  // ============================================================

  String _getSelectedSurahName() {
    if (_selectedSurahNo == null) {
      return '';
    }

    for (final surah in _surahData) {
      final no =
          int.tryParse(
        surah['no'].toString(),
      );

      if (no == _selectedSurahNo) {
        return surah['name']?.toString() ??
            '';
      }
    }

    return '';
  }

  // ============================================================
  // SELECTED AYAT
  // ============================================================

  Map<String, dynamic>?
      _getSelectedAyat() {
    if (_selectedAyatId == null) {
      return null;
    }

    for (final ayat in _ayatData) {
      final id =
          int.tryParse(
        ayat['id'].toString(),
      );

      if (id == _selectedAyatId) {
        return ayat;
      }
    }

    return null;
  }

  // ============================================================
  // PREVIOUS AYAT
  // ============================================================

  Map<String, dynamic>?
      _getPreviousAyat() {
    if (_ayatData.isEmpty ||
        _selectedAyatId == null) {
      return null;
    }

    final currentIndex =
        _ayatData.indexWhere(
      (a) =>
          int.tryParse(
            a['id'].toString(),
          ) ==
          _selectedAyatId,
    );

    if (currentIndex > 0) {
      return _ayatData[
          currentIndex - 1];
    }

    return null;
  }

  // ============================================================
  // NEXT AYAT
  // ============================================================

  Map<String, dynamic>?
      _getNextAyat() {
    if (_ayatData.isEmpty ||
        _selectedAyatId == null) {
      return null;
    }

    final currentIndex =
        _ayatData.indexWhere(
      (a) =>
          int.tryParse(
            a['id'].toString(),
          ) ==
          _selectedAyatId,
    );

    if (currentIndex != -1 &&
        currentIndex <
            _ayatData.length - 1) {
      return _ayatData[
          currentIndex + 1];
    }

    return null;
  }

  // ============================================================
  // NUMBER CONVERSION
  // ============================================================

  String _toBengali(
    String input,
  ) {
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

    String result = input;

    for (int i = 0;
        i < english.length;
        i++) {
      result = result.replaceAll(
        english[i],
        bengali[i],
      );
    }

    return result;
  }

  String _toEnglish(
    String input,
  ) {
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

    String result = input;

    for (int i = 0;
        i < bengali.length;
        i++) {
      result = result.replaceAll(
        bengali[i],
        english[i],
      );
    }

    return result;
  }

  String _getAyatNoOnly(
    String noText,
  ) {
    String text = noText;

    if (text.contains(':')) {
      text =
          text.split(':').last.trim();
    }

    return _toEnglish(text);
  }

  // ============================================================
  // CLEAN HTML TEXT
  // ============================================================

  String _cleanText(
    String text,
  ) {
    if (text.isEmpty) {
      return '';
    }

    return text
        .replaceAll(
          '<br />',
          '\n',
        )
        .replaceAll(
          '<br>',
          '\n',
        )
        .replaceAll(
          '<ul>',
          '\n',
        )
        .replaceAll(
          '</ul>',
          '\n',
        )
        .replaceAll(
          '<li>',
          '• ',
        )
        .replaceAll(
          '</li>',
          '\n',
        )
        .replaceAll(
          '&nbsp;',
          ' ',
        )
        .replaceAll(
          RegExp(r'<[^>]*>'),
          '',
        )
        .trim();
  }

  // ============================================================
  // DATA ROW
  // ============================================================

  Widget _buildDataRow(
    String label,
    String content,
    IconData icon, {
    bool isArabic = false,
    required bool isDark,
  }) {
    return FadeInLeft(
      duration:
          const Duration(
        milliseconds: 500,
      ),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets
                    .symmetric(
              vertical: 12,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: Colors
                            .amberAccent
                            .withAlpha(
                          150,
                        ),
                      ),
                      const SizedBox(
                          width: 8),
                      Expanded(
                        child: Text(
                          label,
                          style:
                              GoogleFonts
                                  .hindSiliguri(
                            color: isDark
                                ? Colors
                                    .amberAccent
                                    .withAlpha(
                                        180)
                                : Colors
                                    .amber
                                    .shade900,
                            fontSize: 14,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),
                      Text(
                        ':',
                        style:
                            TextStyle(
                          color: Colors
                              .amberAccent
                              .withAlpha(
                            150,
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: 5),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        _cleanText(
                          content,
                        ),
                        textAlign:
                            TextAlign.left,
                        textDirection:
                            isArabic
                                ? TextDirection
                                    .rtl
                                : TextDirection
                                    .ltr,
                        style: isArabic
                            ? GoogleFonts
                                .amiri(
                                fontSize:
                                    18 *
                                        _arabicFontScale,
                                color: isDark
                                    ? Colors
                                        .tealAccent
                                    : Colors
                                        .black87,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                height: 1.6,
                              )
                            : GoogleFonts
                                .hindSiliguri(
                                fontSize:
                                    18 *
                                        _textFontScale,
                                color: isDark
                                    ? Colors
                                        .white
                                    : Colors
                                        .black87,
                                height: 1.5,
                              ),
                      ),

                      if (label ==
                          'অর্থ') ...[
                        const SizedBox(
                            height: 5),
                        Align(
                          alignment:
                              Alignment
                                  .centerRight,
                          child: Text(
                            '— আল-বায়ান',
                            style: GoogleFonts
                                .hindSiliguri(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white
                                      .withAlpha(
                                          150)
                                  : Colors
                                      .black54,
                              fontStyle:
                                  FontStyle
                                      .italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: isDark
                ? Colors.white10
                : Colors.black12,
            height: 1,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WORD MEANING
  // ============================================================

  Widget _buildWordMeaningSection(
    String content, {
    required bool isDark,
  }) {
    if (content.trim().isEmpty) {
      return const SizedBox();
    }

    return FadeInLeft(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(
              vertical: 6, // Ekhane padding ektu komiye dewa holo
            ),
            child: Row(
              children: [
                Icon(
                  Icons
                      .format_list_bulleted_rounded,
                  size: 18,
                  color: Colors
                      .amberAccent
                      .withAlpha(
                    150,
                  ),
                ),
                const SizedBox(
                    width: 8),
                Text(
                  'শব্দার্থ :',
                  style: GoogleFonts
                      .hindSiliguri(
                    color: isDark
                        ? Colors
                            .amberAccent
                            .withAlpha(
                                180)
                        : Colors
                            .amber
                            .shade900,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8, // Container-er nicher/uporer internal padding komanor jonno
            ),
            decoration:
                BoxDecoration(
              color: isDark
                  ? Colors.white
                      .withAlpha(5)
                  : Colors.black
                      .withAlpha(5),
              borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
              border: Border.all(
                color: isDark
                    ? Colors.white10
                    : Colors.black12,
              ),
            ),
            child: _buildHtmlContent(
              content,
              isDark: isDark,
              baseFontSize: 16,
            ),
          ),

          const SizedBox(height: 5), // Ekhane space bar-bar komiye dewa holo

          Divider(
            color: isDark
                ? Colors.white10
                : Colors.black12,
            height: 1,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GRAMMAR TERMS COLLAPSIBLE (ইসম, ফেল, ইত্যাদি - টগল ও ডিফল্ট ওপেন সহ)
  // ============================================================

  Widget _buildGrammarTermsCollapsible({required bool isDark}) {
    final terms = [
      {
        'title': 'ইসম (اِسْم)',
        'meaning': 'নাম',
        'desc': 'যা কোনো ব্যক্তি, বস্তু, স্থান, গুণ বা প্রজননের নাম বোঝায় (যেমন: Zayd, Kitab)।',
      },
      {
        'title': 'ফেল (فِعْل)',
        'meaning': 'ক্রিয়া / কাজ',
        'desc': 'যা কোনো কাজ করা বা হওয়া বোঝায় এবং এর সাথে কাল বা সময় (অতীত, বর্তমান, ভবিষ্যৎ) জড়িত থাকে।',
      },
      {
        'title': 'হারফ (حَرْف)',
        'meaning': 'হরফ / অব্যয়',
        'desc': 'যে শব্দ নিজের অর্থ নিজে পুরোপুরি প্রকাশ করতে পারে না, অন্য শব্দের সাহায্য নেয় (যেমন: preposition, conjunction)।',
      },
      {
        'title': 'যমীর (ضَمِيْر)',
        'meaning': 'সর্বনাম',
        'desc': 'যা ইসমের পরিবর্তে ব্যবহৃত হয় (যেমন: হুয়া, আনতা, নাহনু ইত্যাদি)।',
      },
    ];

    return FadeInLeft(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isGrammarExpanded = !_isGrammarExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 18,
                    color: Colors.amberAccent.withAlpha(180),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'আরবি ব্যাকরণ পরিচিতি (ইসম, ফেল, ইত্যাদি) :',
                      style: GoogleFonts.hindSiliguri(
                        color: isDark
                            ? Colors.amberAccent.withAlpha(180)
                            : Colors.amber.shade900,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isGrammarExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: isDark
                          ? Colors.amberAccent.withAlpha(180)
                          : Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.amberAccent.withAlpha(isDark ? 10 : 20),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.amberAccent.withAlpha(50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...terms.map((term) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Colors.amberAccent, fontSize: 16)),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 14,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${term['title']} = ${term['meaning']} ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.tealAccent : Colors.teal.shade800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '— ${term['desc']}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white54 : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            crossFadeState: _isGrammarExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ============================================================
  // HTML CONTENT RENDERER (WORD MEANING, NOTES, TAFSIR)
  // ============================================================

  String _prepareHtmlContent(String text) {
    if (text.isEmpty) return '';

    String res = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
    final lines = res.split('\n');
    final formatted = <String>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        formatted.add('<br/>');
      } else if (line.startsWith('<ul') ||
          line.startsWith('</ul') ||
          line.startsWith('<ol') ||
          line.startsWith('</ol') ||
          line.startsWith('<li') ||
          line.endsWith('</li>') ||
          line.endsWith('</ul>') ||
          line.endsWith('</ol>') ||
          line.endsWith('<br>') ||
          line.endsWith('<br/>') ||
          line.endsWith('<br />')) {
        formatted.add(lines[i]);
      } else {
        formatted.add('$line<br/>');
      }
    }

    return formatted.join('\n');
  }

  Widget _buildHtmlContent(
    String content, {
    required bool isDark,
    double baseFontSize = 16.0,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    final formattedHtml = _prepareHtmlContent(content);

    return HtmlWidget(
      formattedHtml,
      textStyle: GoogleFonts.hindSiliguri(
        fontSize: baseFontSize * _textFontScale,
        color: isDark ? Colors.white70 : Colors.black87,
        height: 1.6,
        fontStyle: fontStyle,
      ),
      customStylesBuilder: (element) {
        // লিস্ট বা ইউএল (ul, ol) এর জন্য বামপাশে নির্দিষ্ট ইনডেন্টেশন এবং ওপর-নিচে সঠিক স্পেস
        if (element.localName == 'ul' || element.localName == 'ol') {
          return {
            'padding-left': '24px', // ডানপাশে বা ভেতর দিকে একটু সরিয়ে নেওয়ার জন্য
            'margin-top': '4px',    // ওপরের আয়াতের সাথে স্পেস কমানোর জন্য
            'margin-bottom': '8px', // প্রতিটি ইউএল ব্লকের মাঝখানের দূরত্ব
          };
        }
        // প্রতিটি লিস্ট আইটেম (li) এর নিজস্ব স্টাইল
        if (element.localName == 'li') {
          return {
            'margin-bottom': '6px', // লাইনের মাঝখানের দূরত্ব
            'line-height': '1.5',
          };
        }
        return null;
      },
    );
  }

  // ============================================================
  // NOTES
  // ============================================================

  Widget _buildNoteSection(
    String content, {
    required bool isDark,
  }) {
    if (content.trim().isEmpty) {
      return const SizedBox();
    }

    return FadeInLeft(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isNotesExpanded =
                    !_isNotesExpanded;
              });
            },
            child: Padding(
              padding:
                  const EdgeInsets
                      .symmetric(
                vertical: 15,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons
                        .lightbulb_outline_rounded,
                    size: 18,
                    color: Colors
                        .amberAccent
                        .withAlpha(
                      150,
                    ),
                  ),
                  const SizedBox(
                      width: 8),
                  Expanded(
                    child: Text(
                      'ব্যাকরণিক টিকা :',
                      style:
                          GoogleFonts
                              .hindSiliguri(
                        color: isDark
                            ? Colors
                                .amberAccent
                                .withAlpha(
                                    180)
                            : Colors
                                .amber
                                .shade900,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns:
                        _isNotesExpanded
                            ? 0.5
                            : 0.0,
                    duration:
                        const Duration(
                      milliseconds: 200,
                    ),
                    child: Icon(
                      Icons
                          .keyboard_arrow_down_rounded,
                      size: 22,
                      color: isDark
                          ? Colors
                              .amberAccent
                              .withAlpha(
                                  180)
                          : Colors
                              .amber
                              .shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild:
                const SizedBox.shrink(),

            secondChild:
                Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets
                      .all(15),
              decoration:
                  BoxDecoration(
                color: Colors
                    .amberAccent
                    .withAlpha(
                  isDark ? 5 : 20,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
                border:
                    Border.all(
                  color: Colors
                      .amberAccent
                      .withAlpha(50),
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors
                        .amberAccent,
                    size: 18,
                  ),
                  const SizedBox(
                      width: 10),
                  Expanded(
                    child: _buildHtmlContent(
                      content,
                      isDark: isDark,
                      baseFontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            crossFadeState:
                _isNotesExpanded
                    ? CrossFadeState
                        .showSecond
                    : CrossFadeState
                        .showFirst,

            duration:
                const Duration(
              milliseconds: 250,
            ),
          ),

          const SizedBox(
              height: 10),
        ],
      ),
    );
  }

  // ============================================================
  // TAFSIR
  // ============================================================

  Widget _buildTafsirSection(
    String content, {
    required bool isDark,
  }) {
    if (content.trim().isEmpty) {
      return const SizedBox();
    }

    return FadeInLeft(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isTafsirExpanded =
                    !_isTafsirExpanded;
              });
            },
            child: Padding(
              padding:
                  const EdgeInsets
                      .symmetric(
                vertical: 15,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons
                        .menu_book_rounded,
                    size: 18,
                    color: Colors
                        .tealAccent
                        .withAlpha(
                      180,
                    ),
                  ),
                  const SizedBox(
                      width: 8),
                  Expanded(
                    child: Text(
                      'তাফসীর :',
                      style:
                          GoogleFonts
                              .hindSiliguri(
                        color: isDark
                            ? Colors
                                .tealAccent
                                .withAlpha(
                                    200)
                            : Colors
                                .teal
                                .shade800,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns:
                        _isTafsirExpanded
                            ? 0.5
                            : 0.0,
                    duration:
                        const Duration(
                      milliseconds: 200,
                    ),
                    child: Icon(
                      Icons
                          .keyboard_arrow_down_rounded,
                      size: 22,
                      color: isDark
                          ? Colors
                              .tealAccent
                              .withAlpha(
                                  200)
                          : Colors
                              .teal
                              .shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild:
                const SizedBox.shrink(),

            secondChild:
                Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets
                      .all(15),
              decoration:
                  BoxDecoration(
                color: Colors
                    .tealAccent
                    .withAlpha(
                  isDark ? 5 : 15,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
                border:
                    Border.all(
                  color: Colors
                      .tealAccent
                      .withAlpha(50),
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Icon(
                    Icons
                        .chrome_reader_mode_outlined,
                    color: Colors
                        .tealAccent,
                    size: 18,
                  ),
                  const SizedBox(
                      width: 10),
                  Expanded(
                    child: _buildHtmlContent(
                      content,
                      isDark: isDark,
                      baseFontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            crossFadeState:
                _isTafsirExpanded
                    ? CrossFadeState
                        .showSecond
                    : CrossFadeState
                        .showFirst,

            duration:
                const Duration(
              milliseconds: 250,
            ),
          ),

          const SizedBox(
              height: 10),
        ],
      ),
    );
  }

  // ============================================================
  // MENU BAR
  // ============================================================

  Widget _buildMenuBarItem(
    BuildContext context,
    IconData icon,
    String title, {
    bool isHighlighted = false,
  }) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (title == 'অনুদান') {
          _showDonationBottomSheet(
            context,
          );
        } else if (title == 'ব্যাকরণ') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const ArabicGrammarScreen(),
            ),
          );
        } else if (title ==
            'প্রসঙ্গভেদে শব্দের অর্থ') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const ContextualMeaningScreen(),
            ),
          );
        } else if (title ==
            'আমাদের সম্পর্কে') {
          _showAboutBottomSheet(
            context,
          );
        }
      },
      child: Container(
        margin:
            const EdgeInsets.only(
          right: 12,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration:
            BoxDecoration(
          color: isHighlighted
              ? Colors.amberAccent
              : (isDark
                  ? Colors.white
                      .withAlpha(15)
                  : Colors.black
                      .withAlpha(10)),
          borderRadius:
              BorderRadius.circular(
            20,
          ),
          border:
              Border.all(
            color: isHighlighted
                ? Colors.amberAccent
                : (isDark
                    ? Colors.white24
                    : Colors.black12),
          ),
          boxShadow:
              isHighlighted
                  ? [
                      BoxShadow(
                        color: Colors
                            .amberAccent
                            .withAlpha(
                          100,
                        ),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isHighlighted
                  ? Colors.black87
                  : (isDark
                      ? Colors.white
                      : Colors.black87),
              size: 18,
            ),
            const SizedBox(
                width: 8),
            Text(
              title,
              style:
                  GoogleFonts.hindSiliguri(
                color: isHighlighted
                    ? Colors.black87
                    : (isDark
                        ? Colors.white
                        : Colors.black87),
                fontSize: 14,
                fontWeight:
                    isHighlighted
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DONATION
  // ============================================================

  Future<void> _showDonationBottomSheet(
    BuildContext context,
  ) async {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    const String donationContent =
        'আস-সালামু আলাইকুম। এই অ্যাপটি সম্পূর্ণ ফ্রি এবং দাওয়াহর উদ্দেশ্যে তৈরি করা হয়েছে। '
        'অ্যাপটির মেইনটেইনেন্স এবং নতুন নতুন ফিচার যোগ করার কাজে আপনি চাইলে আর্থিক অনুদান দিয়ে '
        'আমাদের সহযোগিতা করতে পারেন। জাযাকাল্লাহু খাইরান।';

    const String paymentDetails =
        'বিকাশ/নগদ: ০১৭০০-০০০০০০\n'
        'ব্যাংক: ১২৩.৪৫৬.৭৮৯ (ইসলামী ব্যাংক)';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDark ? const Color(0xFF1A1C2C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'আর্থিক অনুদান',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                ),
              ),

              const Divider(),

              const SizedBox(height: 15),

              Text(
                donationContent,
                style: GoogleFonts.hindSiliguri(
                  color: isDark
                      ? Colors.white70
                      : Colors.black87,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withAlpha(
                    isDark ? 10 : 30,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.tealAccent.withAlpha(50),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'পেমেন্ট ডিটেইলস:',
                      style: GoogleFonts.hindSiliguri(
                        color: isDark
                            ? Colors.tealAccent
                            : Colors.teal.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      paymentDetails,
                      style: GoogleFonts.hindSiliguri(
                        color: isDark
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 15,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.white.withAlpha(20)
                        : Colors.black.withAlpha(10),
                    foregroundColor: isDark
                        ? Colors.white
                        : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('বন্ধ করুন'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  void _showAboutBottomSheet(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? const Color(0xFF1A1C2C)
          : Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding:
                EdgeInsets.only(
              left: 30,
              right: 30,
              top: 30,
              bottom:
                  MediaQuery.of(context)
                          .viewInsets
                          .bottom +
                      40,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white24,
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                    height: 25),

                Text(
                  'অ্যাপ সম্পর্কে',
                  style:
                      GoogleFonts.hindSiliguri(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                    color: isDark
                        ? Colors
                            .amberAccent
                        : Colors
                            .amber
                            .shade900,
                  ),
                ),

                const SizedBox(
                    height: 10),

                Divider(
                  color: isDark
                      ? Colors.white10
                      : Colors.black12,
                ),

                const SizedBox(
                    height: 15),

                Text(
                  'উৎস ও তথ্যসূত্র:',
                  style:
                      GoogleFonts.hindSiliguri(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),

                const SizedBox(
                    height: 10),

                _buildAboutItem(
                  Icons.source,
                  'শব্দ বিশ্লেষণ (ইংরেজি):',
                  'প্রতিটি শব্দের ইংরেজি অর্থ "Quranic Arabic Corpus (corpus.quran.com)" থেকে সংগৃহীত।',
                ),

                _buildAboutItem(
                  Icons
                      .verified_user_outlined,
                  'যাচাইকরণ পদ্ধতি:',
                  'ইংরেজি অর্থগুলোকে বাংলায় রূপান্তর করার পর আয়াতের মূল ভাবার্থের সাথে মিলিয়ে অত্যন্ত সতর্কতার সাথে ম্যানুয়ালি যাচাই করা হয়েছে।',
                ),

                _buildAboutItem(
                  Icons.translate,
                  'বাংলা অনুবাদ ও গবেষণা:',
                  'মূল অনুবাদটি প্রধানত "আল-বায়ান ফাউন্ডেশন" থেকে সংগৃহীত। বিষয়ভিত্তিক আলোচনা ও সঠিক দিকনির্দেশনার জন্য শায়খ মতিউর রহমান মাদানীর লেকচার থেকে সহায়তা নেওয়া হয়েছে।',
                ),

                const SizedBox(
                    height: 20),

                Container(
                  padding:
                      const EdgeInsets
                          .all(15),
                  decoration:
                      BoxDecoration(
                    color: (isDark
                            ? Colors
                                .amberAccent
                            : Colors
                                .amber
                                .shade900)
                        .withAlpha(
                      20,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                    border:
                        Border.all(
                      color: (isDark
                              ? Colors
                                  .amberAccent
                              : Colors
                                  .amber
                                  .shade900)
                          .withAlpha(
                        50,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons
                                .info_outline,
                            color: isDark
                                ? Colors
                                    .amberAccent
                                : Colors
                                    .amber
                                    .shade900,
                            size: 20,
                          ),
                          const SizedBox(
                              width: 10),
                          Text(
                            'সতর্কবার্তা ও সীমাবদ্ধতা',
                            style: GoogleFonts
                                .hindSiliguri(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color: isDark
                                  ? Colors
                                      .amberAccent
                                  : Colors
                                      .amber
                                      .shade900,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                          height: 10),

                      Text(
                        'এই অ্যাপের শব্দে শব্দে অর্থগুলো একটি সিস্টেমেটিক প্রক্রিয়ায় (ইংরেজি সোর্স -> বাংলা অনুবাদ -> ম্যানুয়াল যাচাইকরণ) তৈরি করা হয়েছে। সর্বোচ্চ সতর্কতা অবলম্বন করা সত্ত্বেও মানুষের সীমাবদ্ধতার কারণে অনিচ্ছাকৃত ভুল থাকতে পারে। কোনো অসামঞ্জস্যতা নজরে পড়লে আমাদের জানানোর অনুরোধ রইল। গভীর গবেষণার জন্য মূল তাফসীর পাঠ করা উত্তম।',
                        style: GoogleFonts
                            .hindSiliguri(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white70
                              : Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                    height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          isDark
                              ? Colors.white
                                  .withAlpha(
                                      20)
                              : Colors.black
                                  .withAlpha(
                                      10),
                      foregroundColor:
                          isDark
                              ? Colors.white
                              : Colors.black87,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          15,
                        ),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.pop(
                      context,
                    ),
                    child:
                        const Text(
                      'বন্ধ করুন',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ABOUT ITEM
  // ============================================================

  Widget _buildAboutItem(
    IconData icon,
    String title,
    String desc,
  ) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 15,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Icon(
            icon,
            color: isDark
                ? Colors.tealAccent
                : Colors.teal.shade800,
            size: 20,
          ),

          const SizedBox(
              width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      TextStyle(
                    color: isDark
                        ? Colors.white
                        : Colors.black87,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  desc,
                  style:
                      TextStyle(
                    color: isDark
                        ? Colors.white54
                        : Colors.black54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}