import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../database/database_helper.dart';
import 'surah_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

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
                            widget.username,
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
                      _buildMenuBarItem(context, Icons.volunteer_activism_outlined, 'অনুদান', isHighlighted: true),
                      _buildMenuBarItem(context, Icons.settings_outlined, 'সেটিংস'),
                      _buildMenuBarItem(context, Icons.help_outline_rounded, 'সাহায্য'),
                      _buildMenuBarItem(context, Icons.info_outline, 'আমাদের সম্পর্কে'),
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

  Widget _buildMenuBarItem(BuildContext context, IconData icon, String title, {bool isSelected = false, bool isHighlighted = false}) {
    Widget item = GestureDetector(
      onTap: () {
        if (title == 'সাহায্য') {
          _showHelpBottomSheet(context);
        } else if (title == 'অনুদান') {
          _showDonationBottomSheet(context);
        } else if (title == 'আমাদের সম্পর্কে') {
          _showAboutBottomSheet(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isHighlighted 
            ? Colors.amberAccent 
            : (isSelected ? Colors.white.withAlpha(40) : Colors.white.withAlpha(15)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHighlighted 
              ? Colors.amberAccent 
              : (isSelected ? Colors.white.withAlpha(80) : Colors.transparent)
          ),
          boxShadow: isHighlighted ? [
            BoxShadow(
              color: Colors.amberAccent.withAlpha(100),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ] : null,
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              color: isHighlighted ? Colors.black87 : Colors.white, 
              size: 18
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.hindSiliguri(
                color: isHighlighted ? Colors.black87 : Colors.white,
                fontSize: 14,
                fontWeight: (isSelected || isHighlighted) ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );

    return item;
  }

  void _showDonationBottomSheet(BuildContext context) async {
    final dbHelper = DatabaseHelper();
    var donationData = await dbHelper.getSalatTopicByTitle('আর্থিক অনুদান');
    
    if (donationData == null) {
      await dbHelper.updateSalatTopic('আর্থিক অনুদান', {
        'content': 'আস-সালামু আলাইকুম। এই অ্যাপটি সম্পূর্ণ ফ্রি এবং দাওয়াহর উদ্দেশ্যে তৈরি করা হয়েছে। অ্যাপটির মেইনটেইনেন্স এবং নতুন নতুন ফিচার যোগ করার কাজে আপনি চাইলে আর্থিক অনুদান দিয়ে আমাদের সহযোগিতা করতে পারেন। জাযাকাল্লাহু খাইরান।',
        'references_text': 'বিকাশ/নগদ: ০১৭০০-০০০০০০\nব্যাংক: ১২৩.৪৫৬.৭৮৯ (ইসলামী ব্যাংক)',
      });
      donationData = await dbHelper.getSalatTopicByTitle('আর্থিক অনুদান');
    }

    if (!context.mounted) return;
    bool isAdmin = widget.username.toLowerCase() == 'admin';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1C2C),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('আর্থিক অনুদান', style: GoogleFonts.hindSiliguri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white38),
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditSalatGuideDialog(context, donationData!);
                    },
                  ),
              ],
            ),
            const Divider(color: Colors.white10),
            const SizedBox(height: 15),
            Text(
              donationData!['content'],
              style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.tealAccent.withAlpha(10),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.tealAccent.withAlpha(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('পেমেন্ট ডিটেইলস:', style: GoogleFonts.hindSiliguri(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  Text(donationData['references_text'], style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 15, height: 1.8)),
                ],
              ),
            ),
            const SizedBox(height: 30),
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
  }

  void _showEditSalatGuideDialog(BuildContext context, Map<String, dynamic> topic) {
    final TextEditingController contentController = TextEditingController(text: topic['content']);
    final TextEditingController refController = TextEditingController(text: topic['references_text']);
    final dbHelper = DatabaseHelper();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF232538),
        title: Text('${topic['title']} সংশোধন', style: GoogleFonts.hindSiliguri(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                maxLines: 6,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'মূল কন্টেন্ট',
                  labelStyle: const TextStyle(color: Colors.amberAccent),
                  filled: true,
                  fillColor: Colors.white.withAlpha(10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: refController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'রেফারেন্স (বইয়ের নাম)',
                  labelStyle: const TextStyle(color: Colors.amberAccent),
                  filled: true,
                  fillColor: Colors.white.withAlpha(10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent.withAlpha(50)),
            onPressed: () async {
              await dbHelper.updateSalatTopic(topic['title'], {
                'content': contentController.text,
                'references_text': refController.text,
              });
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সফলভাবে আপডেট হয়েছে!')));
              }
            },
            child: const Text('সেভ করুন', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
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
                  MaterialPageRoute(builder: (context) => SurahScreen(username: widget.username)),
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

  void _showAboutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  'অ্যাপ সম্পর্কে',
                  style: GoogleFonts.hindSiliguri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.white10),
                const SizedBox(height: 15),
                
                Text(
                  'উৎস ও তথ্যসূত্র:',
                  style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                _buildAboutItem(Icons.source, 'শব্দ বিশ্লেষণ (ইংরেজি):', 'প্রতিটি শব্দের ইংরেজি অর্থ "Quranic Arabic Corpus (corpus.quran.com)" থেকে সংগৃহীত।'),
                _buildAboutItem(Icons.verified_user_outlined, 'যাচাইকরণ পদ্ধতি:', 'ইংরেজি অর্থগুলোকে বাংলায় রূপান্তর করার পর আয়াতের মূল ভাবার্থের সাথে মিলিয়ে অত্যন্ত সতর্কতার সাথে ম্যানুয়ালি যাচাই করা হয়েছে।'),
                _buildAboutItem(Icons.translate, 'বাংলা অনুবাদ ও গবেষণা:', 'মূল অনুবাদটি প্রধানত "আল-বায়ান ফাউন্ডেশন" থেকে সংগৃহীত। বিষয়ভিত্তিক আলোচনা ও সঠিক দিকনির্দেশনার জন্য শায়খ মতিউর রহমান মাদানীর লেকচার থেকে সহায়তা নেওয়া হয়েছে।'),
                
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.amberAccent.withAlpha(20),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amberAccent.withAlpha(50)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.amberAccent, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'সতর্কবার্তা ও সীমাবদ্ধতা',
                            style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'এই অ্যাপের শব্দে শব্দে অর্থগুলো একটি সিস্টেমেটিক প্রক্রিয়ায় (ইংরেজি সোর্স -> বাংলা অনুবাদ -> ম্যানুয়াল যাচাইকরণ) তৈরি করা হয়েছে। সর্বোচ্চ সতর্কতা অবলম্বন করা সত্ত্বেও মানুষের সীমাবদ্ধতার কারণে অনিচ্ছাকৃত ভুল থাকতে পারে। কোনো অসামঞ্জস্যতা নজরে পড়লে আমাদের জানানোর অনুরোধ রইল। গভীর গবেষণার জন্য মূল তাফসীর পাঠ করা উত্তম।',
                        style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.white70, height: 1.5),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
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

  Widget _buildAboutItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.tealAccent, size: 20),
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
}
