import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'arabic_grammar_detail_screen.dart';

class ArabicGrammarScreen extends StatelessWidget {
  const ArabicGrammarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            isDark ? const Color(0xFF1A1C2C) : const Color(0xFFF8F9FA),
        foregroundColor: isDark ? Colors.white : Colors.black87,
        title: Text(
          'কুরআনের আরবি ব্যাকরণ',
          style: GoogleFonts.hindSiliguri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1C2C),
                    const Color(0xFF232538),
                  ]
                : [
                    const Color(0xFFF8F9FA),
                    const Color(0xFFE9ECEF),
                  ],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Header
                FadeInDown(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withAlpha(10)
                          : Colors.white.withAlpha(180),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white10
                            : Colors.black12,
                      ),
                    ),
                    child: Column(
                      children: [

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.amberAccent.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.amberAccent,
                            size: 34,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'কুরআনের আরবি ব্যাকরণ',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'কুরআনের শব্দ বুঝতে আরবি ব্যাকরণের মৌলিক ধারণা',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 14,
                            height: 1.5,
                            color: isDark
                                ? Colors.white60
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Section title
                FadeInLeft(
                  child: Text(
                    'প্রাথমিক ধারণা',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.amberAccent
                          : Colors.amber.shade900,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 1. ISM
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: _buildGrammarCard(
                    context: context,
                    isDark: isDark,
                    icon: Icons.category_outlined,
                    title: 'ইসম',
                    description:
                        'যে শব্দ দ্বারা কোনো ব্যক্তি, বস্তু, স্থান, গুণ বা বিষয় বোঝায়।',
                    examples: 'উদাহরণ: আল্লাহ, রব, কিতাব',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ArabicGrammarDetailScreen(
                            categoryId: 'ism',
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // 2. FAIL
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _buildGrammarCard(
                    context: context,
                    isDark: isDark,
                    icon: Icons.play_circle_outline_rounded,
                    title: 'ফে‘ল',
                    description:
                        'যে শব্দ দ্বারা কোনো কাজ সংঘটিত হওয়া বা করা বোঝায়।',
                    examples:
                        'উদাহরণ: খালাকা — সৃষ্টি করল, জাআ — এলো',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ArabicGrammarDetailScreen(
                            categoryId: 'fail',
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // 3. HARF
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: _buildGrammarCard(
                    context: context,
                    isDark: isDark,
                    icon: Icons.link_rounded,
                    title: 'হরফ',
                    description:
                        'যে শব্দ অন্য শব্দের সঙ্গে সম্পর্ক তৈরি করে বা বিশেষ অর্থ প্রকাশ করে।',
                    examples:
                        'উদাহরণ: ফী — মধ্যে, ইলা — দিকে, মিন — থেকে',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ArabicGrammarDetailScreen(
                            categoryId: 'harf',
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // 4. DHAMIR
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: _buildGrammarCard(
                    context: context,
                    isDark: isDark,
                    icon: Icons.person_outline_rounded,
                    title: 'দামীর',
                    description:
                        'যে শব্দ কোনো ব্যক্তি বা বস্তুর পরিবর্তে ব্যবহৃত হয়।',
                    examples:
                        'উদাহরণ: হুয়া — সে, হুম — তারা, আনা — আমি',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ArabicGrammarDetailScreen(
                            categoryId: 'dhamir',
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // Bottom info
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.tealAccent.withAlpha(8)
                          : Colors.teal.withAlpha(10),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isDark
                            ? Colors.tealAccent.withAlpha(35)
                            : Colors.teal.withAlpha(30),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: isDark
                              ? Colors.tealAccent
                              : Colors.teal.shade700,
                          size: 22,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            'প্রতিটি বিষয়ের বিস্তারিত জানতে সংশ্লিষ্ট অংশে প্রবেশ করুন।',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 14,
                              height: 1.6,
                              color: isDark
                                  ? Colors.white70
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrammarCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
    required String examples,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),

        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),

          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withAlpha(10)
                : Colors.white.withAlpha(220),

            borderRadius: BorderRadius.circular(18),

            border: Border.all(
              color: isDark
                  ? Colors.white12
                  : Colors.black12,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 20 : 10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: isDark
                      ? Colors.amberAccent
                      : Colors.amber.shade800,
                  size: 25,
                ),
              ),

              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      title,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      description,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark
                            ? Colors.white70
                            : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      examples,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark
                            ? Colors.tealAccent
                            : Colors.teal.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'বিস্তারিত জানুন',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.amberAccent
                                : Colors.amber.shade900,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: isDark
                              ? Colors.amberAccent
                              : Colors.amber.shade900,
                        ),
                      ],
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
}