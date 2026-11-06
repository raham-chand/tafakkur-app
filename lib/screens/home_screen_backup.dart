import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'surah_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1C2C),
              const Color(0xFF232538),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: FadeInDown(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'আস-সালামু আলাইকুম,',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.white60,
                            ),
                          ),
                          Text(
                            username,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_active_outlined, color: Colors.amberAccent, size: 24),
                      ),
                    ],
                  ),
                ),
              ),

              // Horizontal Menu Bar
              const SizedBox(height: 10),
              FadeInRight(
                child: SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildMenuBarItem(context, Icons.person_3_outlined, 'প্রোফাইল', isSelected: true),
                      _buildMenuBarItem(context, Icons.history_rounded, 'ইতিহাস'),
                      _buildMenuBarItem(context, Icons.settings_outlined, 'সেটিংস'),
                      _buildMenuBarItem(context, Icons.help_outline_rounded, 'সাহায্য'),
                      _buildMenuBarItem(context, Icons.info_outline, 'সম্পর্কে'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              // Grid Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: FadeIn(
                  child: Text(
                    'আপনার জন্য প্রস্তাবিত',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Main Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildGridItem(
                        context,
                        title: 'সূরা',
                        icon: Icons.menu_book_rounded,
                        color: Colors.indigoAccent,
                        delay: 300,
                      ),
                      _buildGridItem(
                        context,
                        title: 'নামাজ',
                        icon: Icons.mosque_rounded,
                        color: Colors.tealAccent,
                        delay: 500,
                      ),
                      _buildGridItem(
                        context,
                        title: 'কমন শব্দ',
                        icon: Icons.translate_rounded,
                        color: Colors.deepOrangeAccent,
                        delay: 700,
                      ),
                      _buildGridItem(
                        context,
                        title: 'দোয়া',
                        icon: Icons.auto_awesome_rounded,
                        color: Colors.purpleAccent,
                        delay: 900,
                      ),
                    ],
                  ),
                ),
              ),

              // Motivation Text at the Bottom
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  child: Text(
                    '"তোমাদের মধ্যে সেই সর্বোত্তম যে কুরআন শেখে এবং শেখায়"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuBarItem(BuildContext context, IconData icon, String title, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        if (title == 'সাহায্য') {
          _showHelpBottomSheet(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withAlpha(40) : Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.white.withAlpha(80) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.hindSiliguri(
                color: Colors.white,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // এটি কন্টেন্ট অনুযায়ী বড় হতে সাহায্য করবে
      backgroundColor: const Color(0xFF1A1C2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              left: 30,
              right: 30,
              top: 30,
              bottom: MediaQuery.of(context).viewInsets.bottom + 40,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'আপনার জন্য সাহায্য',
                  style: GoogleFonts.hindSiliguri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.white10),
                const SizedBox(height: 15),
                _buildHelpItem(Icons.menu_book, 'সূরা পাঠ:', 'হোম স্ক্রিন থেকে "সূরা" অপশনটি সিলেক্ট করে যেকোনো সূরা এবং আয়াত নির্বাচন করে পড়ুন।'),
                _buildHelpItem(Icons.translate, 'শব্দে শব্দে অর্থ:', 'প্রতিটি আয়াতের নিচে থাকা আরবি শব্দের ওপর তার বাংলা অর্থ দেখতে পাবেন।'),
                _buildHelpItem(Icons.person, 'প্রোফাইল:', 'আপনার সেভ করা সূরা এবং ইতিহাস দেখতে প্রোফাইল অপশনটি ব্যবহার করুন।'),
                _buildHelpItem(Icons.contact_support_rounded, 'সাপোর্ট সেন্টার:', 'যেকোনো সমস্যার জন্য আমাদের ইমেইল করুন: support@quranapp.com'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(20),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('বন্ধ করুন'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (title == 'সূরা') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SurahScreen(username: username)),
                );
              }
            },
            borderRadius: BorderRadius.circular(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
