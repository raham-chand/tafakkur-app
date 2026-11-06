import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import '../database/database_helper.dart';

class ContextualMeaningScreen extends StatefulWidget {
  const ContextualMeaningScreen({super.key});

  @override
  State<ContextualMeaningScreen> createState() =>
      _ContextualMeaningScreenState();
}

class _ContextualMeaningScreenState
    extends State<ContextualMeaningScreen> {
  List<Map<String, dynamic>> _words = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContextualWords();
  }

  /// SQLite থেকে প্রসঙ্গভেদে শব্দের সম্পূর্ণ ডেটা লোড
  Future<void> _loadContextualWords() async {
    try {
      final words =
          await DatabaseHelper().getContextualWordsWithUsages();

      if (!mounted) return;

      setState(() {
        _words = words;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF11131F)
          : const Color(0xFFF7F8FA),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark
            ? const Color(0xFF11131F)
            : const Color(0xFFF7F8FA),

        title: Text(
          'প্রসঙ্গভেদে শব্দের অর্থ',
          style: GoogleFonts.hindSiliguri(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),

            Expanded(
              child: _buildContent(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    // Loading
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: isDark
                    ? Colors.tealAccent
                    : Colors.teal.shade700,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              'শব্দের তথ্য লোড হচ্ছে...',
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                color: isDark
                    ? Colors.white60
                    : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    // Error
    if (_errorMessage != null) {
      return _buildErrorState(isDark);
    }

    // No data
    if (_words.isEmpty) {
      return _buildNoDataState(isDark);
    }

    // Data
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        5,
        16,
        30,
      ),
      itemCount: _words.length,
      itemBuilder: (context, index) {
        final word = _words[index];

        return FadeInUp(
          delay: Duration(
            milliseconds: index * 70,
          ),
          child: _buildWordCard(
            word,
            isDark,
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        14,
      ),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: isDark
              ? const [
                  Color(0xFF263238),
                  Color(0xFF18242A),
                ]
              : const [
                  Color(0xFFE8F5F3),
                  Color(0xFFF2F8F7),
                ],
        ),

        border: Border.all(
          color: isDark
              ? Colors.tealAccent.withAlpha(35)
              : Colors.teal.withAlpha(30),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,

            decoration: BoxDecoration(
              color: isDark
                  ? Colors.tealAccent.withAlpha(20)
                  : Colors.teal.withAlpha(20),
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.translate_rounded,
              color: isDark
                  ? Colors.tealAccent
                  : Colors.teal.shade700,
              size: 29,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'প্রসঙ্গভেদে শব্দের অর্থ',

                  style: GoogleFonts.hindSiliguri(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'একটি শব্দ, প্রসঙ্গ অনুযায়ী ভিন্ন অর্থ',

                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13.5,
                    height: 1.5,
                    color: isDark
                        ? Colors.white60
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(
    Map<String, dynamic> word,
    bool isDark,
  ) {
    final int colorValue =
        int.tryParse(
              word['color'].toString(),
            ) ??
            Colors.teal.value;

    final Color color = Color(colorValue);

    final List<dynamic> meanings =
        word['meanings'] ?? [];

    final String wordName =
        word['word']?.toString() ?? '';

    final String subtitle =
        word['subtitle']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1C2C)
            : Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: color.withAlpha(
            isDark ? 35 : 30,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              isDark ? 15 : 8,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: color.withAlpha(10),
          highlightColor: color.withAlpha(6),
        ),

        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 7,
          ),

          childrenPadding:
              const EdgeInsets.fromLTRB(
            14,
            0,
            14,
            15,
          ),

          leading: Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color: color.withAlpha(
                isDark ? 22 : 15,
              ),
              borderRadius:
                  BorderRadius.circular(15),
            ),

            child: Icon(
              Icons.translate_rounded,
              color: color,
              size: 24,
            ),
          ),

          title: Row(
            children: [
              Expanded(
                child: Text(
                  wordName,

                  style:
                      GoogleFonts.hindSiliguri(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),

                decoration: BoxDecoration(
                  color: color.withAlpha(
                    isDark ? 22 : 15,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Text(
                  '${meanings.length}টি ব্যবহার',

                  style:
                      GoogleFonts.hindSiliguri(
                    fontSize: 11.5,
                    fontWeight:
                        FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),

          subtitle: Padding(
            padding:
                const EdgeInsets.only(top: 3),

            child: Text(
              subtitle,

              style:
                  GoogleFonts.hindSiliguri(
                fontSize: 12.5,
                color: isDark
                    ? Colors.white54
                    : Colors.black54,
              ),
            ),
          ),

          children: [
            ...List.generate(
              meanings.length,
              (index) {
                final meaning =
                    Map<String, dynamic>.from(
                  meanings[index],
                );

                return _buildMeaningItem(
                  meaning: meaning,
                  index: index,
                  color: color,
                  isDark: isDark,
                  isLast:
                      index == meanings.length - 1,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeaningItem({
    required Map<String, dynamic> meaning,
    required int index,
    required Color color,
    required bool isDark,
    required bool isLast,
  }) {
    final String meaningText =
        meaning['meaning']?.toString() ?? '';

    final String type =
        meaning['grammatical_function']
                ?.toString() ??
            '';

    final String pronunciation =
        meaning['pronunciation']?.toString() ??
            '';

    final String translation =
        meaning['translation']?.toString() ?? '';

    final String reference =
        meaning['reference']?.toString() ?? '';

    final String explanation =
        meaning['context_explanation']
                ?.toString() ??
            '';

    return Container(
      width: double.infinity,

      margin: EdgeInsets.only(
        bottom: isLast ? 0 : 10,
      ),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: color.withAlpha(
          isDark ? 8 : 6,
        ),

        borderRadius:
            BorderRadius.circular(15),

        border: Border.all(
          color: color.withAlpha(
            isDark ? 25 : 20,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // Number + Meaning + Type
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Container(
                width: 30,
                height: 30,

                alignment: Alignment.center,

                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  shape: BoxShape.circle,
                ),

                child: Text(
                  '${index + 1}',

                  style:
                      GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w800,
                    color: color,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      meaningText,

                      style:
                          GoogleFonts.hindSiliguri(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),

                      decoration: BoxDecoration(
                        color:
                            color.withAlpha(15),
                        borderRadius:
                            BorderRadius.circular(
                          8,
                        ),
                      ),

                      child: Text(
                        type,

                        style:
                            GoogleFonts
                                .hindSiliguri(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Pronunciation + Translation
          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withAlpha(15)
                  : Colors.black.withAlpha(4),

              borderRadius:
                  BorderRadius.circular(11),
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'উদাহরণ',

                  style:
                      GoogleFonts.hindSiliguri(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    color: color,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  pronunciation,

                  style:
                      GoogleFonts.hindSiliguri(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w700,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  translation,

                  style:
                      GoogleFonts.hindSiliguri(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark
                        ? Colors.white70
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Reference
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 17,
                color: isDark
                    ? Colors.white38
                    : Colors.black45,
              ),

              const SizedBox(width: 7),

              Expanded(
                child: Text(
                  reference,

                  style:
                      GoogleFonts.hindSiliguri(
                    fontSize: 12.5,
                    fontWeight:
                        FontWeight.w600,
                    color: isDark
                        ? Colors.white54
                        : Colors.black54,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          // Explanation
          Text(
            explanation,

            style:
                GoogleFonts.hindSiliguri(
              fontSize: 13.5,
              height: 1.6,
              color: isDark
                  ? Colors.white60
                  : Colors.black.withValues(
                      alpha: 0.60,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 55,
            color: isDark
                ? Colors.white24
                : Colors.black26,
          ),

          const SizedBox(height: 12),

          Text(
            'কোনো তথ্য পাওয়া যায়নি',

            style:
                GoogleFonts.hindSiliguri(
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
              color: isDark
                  ? Colors.white54
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 55,
              color: isDark
                  ? Colors.redAccent
                  : Colors.red.shade400,
            ),

            const SizedBox(height: 12),

            Text(
              'তথ্য লোড করতে সমস্যা হয়েছে',

              textAlign: TextAlign.center,

              style:
                  GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight:
                    FontWeight.w700,
                color: isDark
                    ? Colors.white70
                    : Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _errorMessage ?? '',

              textAlign: TextAlign.center,

              style:
                  GoogleFonts.hindSiliguri(
                fontSize: 12,
                height: 1.5,
                color: isDark
                    ? Colors.white38
                    : Colors.black45,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });

                _loadContextualWords();
              },

              icon: const Icon(
                Icons.refresh_rounded,
              ),

              label: Text(
                'আবার চেষ্টা করুন',

                style:
                    GoogleFonts.hindSiliguri(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}