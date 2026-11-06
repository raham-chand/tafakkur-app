import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArabicGrammarDetailScreen extends StatelessWidget {
  final String categoryId;

  const ArabicGrammarDetailScreen({
    super.key,
    required this.categoryId,
  });

  // ------------------------------------------------------------
  // Category Information
  // ------------------------------------------------------------

  Map<String, dynamic> get category {
    switch (categoryId) {
      case 'ism':
        return {
          'title': 'ইসম',
          'icon': Icons.label_outline_rounded,
          'color': Colors.blue,
          'definition':
              'ইসম হলো আরবি ভাষার একটি মৌলিক শব্দশ্রেণি, যা ব্যক্তি, বস্তু, স্থান, গুণ, অবস্থা, ধারণা বা কোনো সত্তাকে নির্দেশ করতে পারে। দামীর, ইসমে ইশারা ও ইসমে মাওসূলও ইসমের অন্তর্ভুক্ত।',
          'examples': [
            {
              'word': 'আল্লাহ',
              'meaning': 'আল্লাহ',
            },
            {
              'word': 'রব',
              'meaning': 'প্রতিপালক',
            },
            {
              'word': 'কিতাব',
              'meaning': 'গ্রন্থ',
            },
          ],
        };

      case 'fail':
        return {
          'title': 'ফে‘ল',
          'icon': Icons.directions_run_rounded,
          'color': Colors.green,
          'definition':
              'ফে‘ল হলো এমন শব্দ, যা কোনো কাজ বা ঘটনা সংঘটিত হওয়া বোঝায় এবং এর সঙ্গে সময়ের সম্পর্ক থাকে। আরবি ব্যাকরণে ফে‘ল প্রধানত মাদী, মুদারী ও আমর—এই তিন ভাগে আলোচনা করা হয়।',
          'examples': [
            {
              'word': 'খালাকা',
              'meaning': 'সে সৃষ্টি করল',
            },
            {
              'word': 'কালা',
              'meaning': 'সে বলল',
            },
            {
              'word': 'জাআ',
              'meaning': 'সে এলো',
            },
          ],
        };

      case 'harf':
        return {
          'title': 'হরফ',
          'icon': Icons.link_rounded,
          'color': Colors.orange,
          'definition':
              'হরফ হলো আরবি ভাষার এমন শব্দশ্রেণি, যার অর্থ সাধারণত অন্য শব্দের সঙ্গে সম্পর্ক স্থাপনের মাধ্যমে প্রকাশ পায়। হরফ নিজে ইসম বা ফে‘লের মতো স্বাধীন নাম বা কাজ নির্দেশ করে না।',
          'examples': [
            {
              'word': 'ফী',
              'meaning': 'মধ্যে / ভিতরে',
            },
            {
              'word': 'ইলা',
              'meaning': 'দিকে / পর্যন্ত',
            },
            {
              'word': 'মিন',
              'meaning': 'থেকে',
            },
          ],
        };

      case 'dhamir':
        return {
          'title': 'দামীর',
          'icon': Icons.person_outline_rounded,
          'color': Colors.purple,
          'definition':
              'দামীর হলো সর্বনাম। আরবি ব্যাকরণে দামীর ইসমের একটি প্রকার। এটি কোনো ব্যক্তি বা সত্তার নামের পরিবর্তে ব্যবহৃত হয় এবং কর্তা, কর্ম, মালিকানা ইত্যাদি প্রকাশ করতে পারে।',
          'examples': [
            {
              'word': 'হুয়া',
              'meaning': 'সে',
            },
            {
              'word': 'হুম',
              'meaning': 'তারা',
            },
            {
              'word': 'আনা',
              'meaning': 'আমি',
            },
          ],
        };

      default:
        return {
          'title': 'আরবি ব্যাকরণ',
          'icon': Icons.menu_book_rounded,
          'color': Colors.amber,
          'definition': '',
          'examples': [],
        };
    }
  }

  // ------------------------------------------------------------
  // Sections
  // ------------------------------------------------------------

  List<Map<String, dynamic>> get sections {
    switch (categoryId) {
      // ==========================================================
      // ISM
      // ==========================================================

      case 'ism':
        return [
          {
            'title': 'ইসমের সংজ্ঞা',
            'icon': Icons.help_outline_rounded,
            'content':
                'ইসম হলো আরবি ভাষার তিনটি মৌলিক শব্দশ্রেণির একটি। এটি ব্যক্তি, বস্তু, স্থান, গুণ, অবস্থা, ধারণা বা কোনো সত্তাকে নির্দেশ করতে পারে। যেমন— আল্লাহ, রব, কিতাব, আসমান, জমিন, রহমত ইত্যাদি।\n\nগুরুত্বপূর্ণ: দামীর, ইসমে ইশারা ও ইসমে মাওসূল—এসব আলাদা মৌলিক শব্দশ্রেণি নয়; এগুলো ইসমের বিভিন্ন প্রকার।',
          },
          {
            'title': 'আরবি ভাষার ৩টি মৌলিক শব্দশ্রেণি',
            'icon': Icons.account_tree_outlined,
            'items': [
              {
                'title': 'ইসম',
                'description':
                    'কোনো ব্যক্তি, বস্তু, স্থান, গুণ, অবস্থা বা সত্তাকে নির্দেশ করে।',
                'examples':
                    'আল্লাহ — আল্লাহ\nরব — প্রতিপালক\nকিতাব — গ্রন্থ',
              },
              {
                'title': 'ফে‘ল',
                'description':
                    'কোনো কাজ বা ঘটনা সংঘটিত হওয়া এবং তার সঙ্গে সময়ের সম্পর্ক প্রকাশ করে।',
                'examples':
                    'খালাকা — সৃষ্টি করল\nইয়াখলুকু — সৃষ্টি করে / করবে\nইকরা — পড়ো',
              },
              {
                'title': 'হরফ',
                'description':
                    'অন্য শব্দের সঙ্গে সম্পর্ক স্থাপনের মাধ্যমে অর্থ প্রকাশ করে।',
                'examples':
                    'ফী — মধ্যে\nমিন — থেকে\nইলা — দিকে / পর্যন্ত',
              },
            ],
          },
          {
            'title': 'ইসম চেনার আলামত',
            'icon': Icons.search_rounded,
            'content':
                'ক্লাসিক্যাল আরবি ব্যাকরণে ইসম চেনার কয়েকটি প্রসিদ্ধ আলামত রয়েছে। এর মধ্যে জার গ্রহণ করা, তানভীন গ্রহণ করা, আলিফ-লাম গ্রহণ করা এবং সম্বোধনের হরফের পরে আসা উল্লেখযোগ্য।\n\nতবে মনে রাখতে হবে—প্রতিটি ইসম সব আলামত গ্রহণ করবে এমন নয়। তাই শুধু একটি আলামতের ওপর নির্ভর না করে শব্দের গঠন, বাক্যে অবস্থান এবং প্রসঙ্গও বিবেচনা করতে হবে।',
          },
          {
            'title': 'ইসমের শ্রেণিবিভাগ',
            'icon': Icons.category_outlined,
            'content':
                'ইসমকে একটিমাত্র পদ্ধতিতে শ্রেণিবদ্ধ করা হয় না। বিভিন্ন দৃষ্টিকোণ থেকে ইসমের বিভিন্ন শ্রেণিবিভাগ করা হয়।',
          },
          {
            'title': 'ইসম — معرفہ ও نكرة',
            'icon': Icons.visibility_outlined,
            'items': [
              {
                'title': 'মা‘রিফাহ',
                'description':
                    'নির্দিষ্ট বা পরিচিত ব্যক্তি, বস্তু বা সত্তাকে বোঝায়।',
                'examples':
                    'আল্লাহ — নির্দিষ্ট সত্তা\nআল-কিতাব — নির্দিষ্ট কিতাব\nহুয়া — সে',
              },
              {
                'title': 'নাকিরাহ',
                'description':
                    'অনির্দিষ্ট ব্যক্তি, বস্তু বা সত্তাকে বোঝায়।',
                'examples':
                    'কিতাবুন — একটি কিতাব\nরাজুলুন — একজন ব্যক্তি',
              },
            ],
          },
          {
            'title': 'ইসম — জামিদ ও মুশতাক',
            'icon': Icons.auto_awesome_outlined,
            'items': [
              {
                'title': 'ইসমে জামিদ',
                'description':
                    'অন্য কোনো শব্দ থেকে গঠিত হওয়ার দিকটি বিবেচনায় না এনে মৌলিক নাম হিসেবে ব্যবহৃত ইসম।',
                'examples':
                    'শামস — সূর্য\nবাহর — সমুদ্র',
              },
              {
                'title': 'ইসমে মুশতাক',
                'description':
                    'অন্য একটি মূল শব্দ থেকে নির্দিষ্ট অর্থ ও গঠন অনুযায়ী উৎপন্ন ইসম।',
                'examples':
                    'নাসির — সাহায্যকারী\nমাকতুব — লিখিত',
              },
            ],
          },
          {
            'title': 'ইসমের সংখ্যা',
            'icon': Icons.format_list_numbered_rounded,
            'items': [
              {
                'title': 'মুফরাদ',
                'description': 'একজন বা একটি বোঝায়।',
                'examples':
                    'কিতাব — একটি কিতাব\nরাজুল — একজন ব্যক্তি',
              },
              {
                'title': 'মুছান্না',
                'description': 'দুইজন বা দুটি বোঝায়।',
                'examples':
                    'দুই ব্যক্তি / দুটি বস্তু',
              },
              {
                'title': 'জাম‘',
                'description': 'সাধারণভাবে দুইয়ের বেশি বোঝায়।',
                'examples':
                    'কুতুব — কিতাবসমূহ\nরিজাল — পুরুষগণ',
              },
            ],
          },
          {
            'title': 'ইসমের লিঙ্গ',
            'icon': Icons.wc_rounded,
            'items': [
              {
                'title': 'মুযাক্কার',
                'description':
                    'পুংলিঙ্গ হিসেবে ব্যবহৃত ইসম।',
                'examples':
                    'রাজুল — পুরুষ\nআব — পিতা',
              },
              {
                'title': 'মুয়ান্নাছ',
                'description':
                    'স্ত্রীলিঙ্গ হিসেবে ব্যবহৃত ইসম।',
                'examples':
                    'মারআহ — নারী\nউম্ম — মা',
              },
            ],
          },
          {
            'title': 'দামীর, ইসমে ইশারা ও ইসমে মাওসূল',
            'icon': Icons.account_tree_outlined,
            'items': [
              {
                'title': 'দামীর',
                'description':
                    'সর্বনাম; ইসমের একটি প্রকার।',
                'examples':
                    'হুয়া — সে\nআনা — আমি',
              },
              {
                'title': 'ইসমে ইশারা',
                'description':
                    'কোনো ব্যক্তি বা বস্তুর দিকে ইঙ্গিত করে।',
                'examples':
                    'হাযা — এটি / এই\nযালিকা — সেটি / ঐ',
              },
              {
                'title': 'ইসমে মাওসূল',
                'description':
                    'যে শব্দের মাধ্যমে পরবর্তী বাক্যাংশের সঙ্গে সম্পর্ক স্থাপন করে কোনো ব্যক্তি বা বিষয়কে নির্দেশ করা হয়।',
                'examples':
                    'আল্লাযী — যে\nআল্লাতী — যে',
              },
            ],
          },
          {
            'title': 'গুরুত্বপূর্ণ উদাহরণ — গাইর',
            'icon': Icons.info_outline_rounded,
            'content':
                '“গাইর” হরফ নয়; এটি একটি ইসম। এটি অনেক সময় ইদাফাহর কাঠামোয় আসে। যেমন— “গাইরুল মাগদূবি” অর্থ “যাদের ওপর ক্রোধ করা হয়নি তারা ছাড়া / ক্রোধপ্রাপ্তদের ছাড়া”। এখানে “গাইর” ইসম এবং পরবর্তী শব্দ তার মুদাফ ইলাইহ হিসেবে আসে।',
          },
          {
            'title': 'কুরআনিক উদাহরণ',
            'icon': Icons.menu_book_rounded,
            'content':
                'কুরআনে ইসমের অসংখ্য উদাহরণ রয়েছে। যেমন— আল্লাহ, রব, কিতাব, আয়াত, রাসূল, নবী, আসমান, জমিন, জান্নাত, জাহান্নাম ইত্যাদি।\n\nইসমের সঠিক ব্যাকরণিক ভূমিকা বুঝতে শুধু বাংলা অর্থ নয়; আয়াতে তার অবস্থান ও অন্য শব্দের সঙ্গে সম্পর্কও দেখতে হবে।',
          },
        ];

      // ==========================================================
      // FAIL
      // ==========================================================

      case 'fail':
        return [
          {
            'title': 'ফে‘লের সংজ্ঞা',
            'icon': Icons.help_outline_rounded,
            'content':
                'ফে‘ল হলো এমন শব্দ, যা কোনো কাজ বা ঘটনা সংঘটিত হওয়া বোঝায় এবং এর সঙ্গে সময়ের সম্পর্ক থাকে। ফে‘ল দ্বারা কর্তা, সংখ্যা ও লিঙ্গের পরিবর্তনও প্রকাশিত হতে পারে।',
          },
          {
            'title': 'ফে‘লের প্রধান তিন প্রকার',
            'icon': Icons.account_tree_outlined,
            'items': [
              {
                'title': 'ফে‘ল মাদী',
                'description':
                    'সাধারণত অতীতে সংঘটিত কোনো কাজ বা ঘটনা বোঝায়।',
                'examples':
                    'খালাকা — সৃষ্টি করল\nজাআ — এলো\nকালা — বলল',
              },
              {
                'title': 'ফে‘ল মুদারী',
                'description':
                    'বর্তমান বা ভবিষ্যৎ সময়ের কাজ বোঝাতে ব্যবহৃত হয়। সঠিক সময় প্রসঙ্গ ও বাক্যগঠনের ওপর নির্ভর করে।',
                'examples':
                    'ইয়াখলুকু — সৃষ্টি করে / করবে\nইয়াকুলু — বলে / বলবে',
              },
              {
                'title': 'ফে‘ল আমর',
                'description':
                    'কোনো কাজ করার আদেশ, নির্দেশ বা অনুরোধ বোঝায়।',
                'examples':
                    'ইকরা — পড়ো\nকুল — বলো\nউ‘বুদ — ইবাদত করো',
              },
            ],
          },
          {
            'title': 'ফে‘ল মাদী',
            'icon': Icons.history_rounded,
            'content':
                'ফে‘ল মাদী দ্বারা সাধারণত অতীতে সংঘটিত কাজ বোঝানো হয়। কুরআনে পূর্ববর্তী ঘটনা, নবীদের ঘটনা এবং আল্লাহর সংঘটিত কাজ বর্ণনায় ফে‘ল মাদী ব্যাপকভাবে ব্যবহৃত হয়েছে।\n\nতবে বাংলা অনুবাদে সবসময় শুধু অতীত কাল হিসেবে অনুবাদ হবে—এমন নয়। আরবি বাক্যের প্রসঙ্গও গুরুত্বপূর্ণ।',
          },
          {
            'title': 'ফে‘ল মুদারী',
            'icon': Icons.autorenew_rounded,
            'content':
                'ফে‘ল মুদারী বর্তমান বা ভবিষ্যৎ কাজ বোঝাতে পারে। এর আগে কিছু হরফ বা শব্দ এলে সময় ও অর্থের পরিবর্তন হতে পারে। যেমন— ভবিষ্যৎ বোঝানো, নাকচ করা বা শর্ত প্রকাশের কারণে এর অর্থ ভিন্ন হতে পারে।',
          },
          {
            'title': 'ফে‘ল আমর',
            'icon': Icons.campaign_outlined,
            'content':
                'ফে‘ল আমর দ্বারা সাধারণত কোনো কাজ করার আদেশ বা নির্দেশ বোঝানো হয়। কুরআনে ইবাদত, নৈতিকতা ও বিভিন্ন নির্দেশ প্রদানের ক্ষেত্রে ফে‘ল আমর ব্যবহৃত হয়েছে।',
          },
          {
            'title': 'ফে‘লের সঙ্গে ব্যক্তি, সংখ্যা ও লিঙ্গ',
            'icon': Icons.people_outline_rounded,
            'items': [
              {
                'title': 'ব্যক্তি',
                'description':
                    'কাজটি কে করছে—প্রথম, দ্বিতীয় নাকি তৃতীয় ব্যক্তি—তা প্রকাশিত হতে পারে।',
                'examples':
                    'আমি / আমরা\nতুমি / তোমরা\nসে / তারা',
              },
              {
                'title': 'সংখ্যা',
                'description':
                    'একজন, দুজন বা একাধিক ব্যক্তি অনুযায়ী ফে‘লের রূপ পরিবর্তিত হতে পারে।',
                'examples':
                    'একবচন\nদ্বিবচন\nবহুবচন',
              },
              {
                'title': 'লিঙ্গ',
                'description':
                    'পুরুষ ও নারীর ক্ষেত্রে অনেক ফে‘লের রূপে পার্থক্য দেখা যায়।',
                'examples':
                    'পুরুষ\nনারী',
              },
            ],
          },
          {
            'title': 'ফে‘ল চেনার গুরুত্বপূর্ণ বিষয়',
            'icon': Icons.search_rounded,
            'content':
                'ফে‘ল চেনার সময় শুধু বাংলা অর্থের দিকে তাকানো যথেষ্ট নয়। শব্দের গঠন, শুরু ও শেষের পরিবর্তন, কর্তার সঙ্গে সম্পর্ক এবং বাক্যের সময়গত অর্থও বিবেচনা করতে হয়।',
          },
        ];

      // ==========================================================
      // HARF
      // ==========================================================

      case 'harf':
        return [
          {
            'title': 'হরফের সংজ্ঞা',
            'icon': Icons.help_outline_rounded,
            'content':
                'হরফ হলো আরবি ভাষার তিনটি মৌলিক শব্দশ্রেণির একটি। এর অর্থ সাধারণত অন্য শব্দের সঙ্গে সম্পর্ক স্থাপনের মাধ্যমে প্রকাশ পায়। হরফ নিজে সাধারণত কোনো ব্যক্তি, বস্তু বা কাজের নাম নির্দেশ করে না।',
          },
          {
            'title': 'হরফে জার',
            'icon': Icons.link_rounded,
            'items': [
              {
                'title': 'মিন',
                'description': 'থেকে / হতে',
                'examples': 'মিন — থেকে / হতে',
              },
              {
                'title': 'ইলা',
                'description': 'দিকে / পর্যন্ত',
                'examples': 'ইলা — দিকে / পর্যন্ত',
              },
              {
                'title': 'আন',
                'description': 'থেকে / সম্পর্কে',
                'examples': 'আন — থেকে / সম্পর্কে',
              },
              {
                'title': 'আলা',
                'description': 'উপর',
                'examples': 'আলা — উপর',
              },
              {
                'title': 'ফী',
                'description': 'মধ্যে / ভিতরে',
                'examples': 'ফী — মধ্যে / ভিতরে',
              },
              {
                'title': 'বি',
                'description': 'দ্বারা / দিয়ে / সঙ্গে',
                'examples': 'বি — দ্বারা / দিয়ে / সঙ্গে',
              },
              {
                'title': 'লি',
                'description': 'জন্য / অধিকার বা সম্পর্ক বোঝাতে',
                'examples': 'লি — জন্য / উদ্দেশ্যে',
              },
            ],
          },
          {
            'title': 'সংযোগকারী হরফ',
            'icon': Icons.compare_arrows_rounded,
            'items': [
              {
                'title': 'ওয়া',
                'description': 'এবং / ও',
                'examples': 'ওয়া — এবং / ও',
              },
              {
                'title': 'ফা',
                'description': 'অতঃপর / ফলে / তাই',
                'examples': 'ফা — অতঃপর / ফলে',
              },
              {
                'title': 'ছুম্মা',
                'description': 'তারপর',
                'examples': 'ছুম্মা — তারপর',
              },
              {
                'title': 'আও',
                'description': 'অথবা',
                'examples': 'আও — অথবা',
              },
            ],
          },
          {
            'title': 'নাকচের হরফ',
            'icon': Icons.block_rounded,
            'items': [
              {
                'title': 'লা',
                'description': 'না / নয়',
                'examples': 'লা — না / নয়',
              },
              {
                'title': 'লাম',
                'description':
                    'অতীতে কাজ সংঘটিত হয়নি—এমন নাকচ প্রকাশে ব্যবহৃত হয়।',
                'examples': 'লাম — করেনি / হয়নি',
              },
              {
                'title': 'লান',
                'description':
                    'ভবিষ্যতে কাজ সংঘটিত হবে না—এমন নাকচ প্রকাশে ব্যবহৃত হয়।',
                'examples': 'লান — করবে না',
              },
              {
                'title': 'মা',
                'description':
                    'কিছু প্রসঙ্গে নাকচের হরফ হিসেবে ব্যবহৃত হয়।',
                'examples': 'মা — না / নয়',
              },
            ],
          },
          {
            'title': 'সম্বোধনের হরফ',
            'icon': Icons.record_voice_over_rounded,
            'items': [
              {
                'title': 'ইয়া',
                'description':
                    'কাউকে সম্বোধন বা ডাকার জন্য ব্যবহৃত হয়।',
                'examples': 'ইয়া — হে...',
              },
            ],
          },
          {
            'title': 'গুরুত্বপূর্ণ — সব ছোট শব্দ হরফ নয়',
            'icon': Icons.warning_amber_rounded,
            'content':
                'আরবি ব্যাকরণে একটি ছোট শব্দ দেখলেই তাকে হরফ বলা যাবে না। কোনো শব্দের শ্রেণি নির্ধারণ করতে তার বাক্যগত ব্যবহার ও ব্যাকরণিক ভূমিকা দেখতে হবে।\n\nবিশেষভাবে মনে রাখুন:\n\n• গাইর — ইসম\n• দামীর যেমন কা, কুম, হু, হা — দামীর; এগুলো হরফ নয়\n• মা — প্রসঙ্গভেদে ইসম বা হরফ হতে পারে\n• মান — সাধারণত বিভিন্ন ধরনের ইসম হিসেবে ব্যবহৃত হয়\n• ইযা — সাধারণত সময়বাচক ظرف এবং শর্তের অর্থ বহন করে; একে সরাসরি সাধারণ হরফ বলা ঠিক নয়',
          },
          {
            'title': 'প্রসঙ্গভেদে অর্থ পরিবর্তন',
            'icon': Icons.info_outline_rounded,
            'content':
                'একটি হরফের বাংলা অর্থ সব জায়গায় একই হবে—এমন নয়। বাক্যে কোন শব্দের সঙ্গে সম্পর্ক তৈরি করছে এবং বাক্যের উদ্দেশ্য কী—তার ওপর অর্থ নির্ভর করে। তাই কুরআনের আয়াত বুঝতে হরফের শুধু বাংলা অর্থ মুখস্থ না করে তার ব্যাকরণিক ভূমিকা বোঝা জরুরি।',
          },
        ];

      // ==========================================================
      // DHAMIR
      // ==========================================================

      case 'dhamir':
        return [
          {
            'title': 'দামীরের সংজ্ঞা',
            'icon': Icons.help_outline_rounded,
            'content':
                'দামীর হলো সর্বনাম। আরবি ব্যাকরণে দামীর ইসমের একটি প্রকার। এটি কোনো ব্যক্তি বা সত্তার নামের পরিবর্তে ব্যবহৃত হয়।\n\nদামীর বাক্যে কর্তা, কর্ম, মালিকানা বা অন্য কোনো ব্যাকরণিক সম্পর্ক প্রকাশ করতে পারে।',
          },
          {
            'title': 'ইসম ও দামীরের সম্পর্ক',
            'icon': Icons.account_tree_outlined,
            'content':
                'আরবি ভাষার মৌলিক শব্দশ্রেণি তিনটি—ইসম, ফে‘ল ও হরফ। দামীর আলাদা চতুর্থ মৌলিক শব্দশ্রেণি নয়। বরং দামীর হলো ইসমের একটি বিশেষ প্রকার।\n\nসহজভাবে:\n\nইসম → একটি মৌলিক শব্দশ্রেণি\nদামীর → ইসমের একটি প্রকার\nফে‘ল → কাজ ও সময় প্রকাশ করে\nহরফ → শব্দের মধ্যে সম্পর্ক তৈরি করে',
          },
          {
            'title': 'দামীরের তিনটি প্রধান শ্রেণি',
            'icon': Icons.account_tree_outlined,
            'items': [
              {
                'title': 'মুতাকাল্লিম',
                'description':
                    'যে ব্যক্তি কথা বলছে তাকে বোঝায়।',
                'examples':
                    'আনা — আমি\nনাহনু — আমরা',
              },
              {
                'title': 'মুখাতাব',
                'description':
                    'যার সঙ্গে কথা বলা হচ্ছে তাকে বোঝায়।',
                'examples':
                    'আন্তা — তুমি, পুরুষ\nআন্তি — তুমি, নারী\nআন্তুম — তোমরা, পুরুষ',
              },
              {
                'title': 'গায়েব',
                'description':
                    'যার সম্পর্কে কথা বলা হচ্ছে তাকে বোঝায়।',
                'examples':
                    'হুয়া — সে, পুরুষ\nহিয়া — সে, নারী\nহুম — তারা, পুরুষ',
              },
            ],
          },
          {
            'title': 'দামীরের ১৪টি প্রচলিত রূপ',
            'icon': Icons.format_list_numbered_rounded,
            'items': [
              {
                'title': '১. হুয়া',
                'description':
                    'গায়েব — তৃতীয় ব্যক্তি — একবচন — পুরুষ',
                'examples': 'সে',
              },
              {
                'title': '২. হুমা',
                'description':
                    'গায়েব — তৃতীয় ব্যক্তি — দ্বিবচন — পুরুষ',
                'examples': 'তারা দুজন',
              },
              {
                'title': '৩. হুম',
                'description':
                    'গায়েব — তৃতীয় ব্যক্তি — বহুবচন — পুরুষ',
                'examples': 'তারা',
              },
              {
                'title': '৪. হিয়া',
                'description':
                    'গায়েব — তৃতীয় ব্যক্তি — একবচন — নারী',
                'examples': 'সে',
              },
              {
                'title': '৫. হুমা',
                'description':
                    'গায়েব — তৃতীয় ব্যক্তি — দ্বিবচন — নারী',
                'examples': 'তারা দুজন',
              },
              {
                'title': '৬. হুন্না',
                'description':
                    'গায়েব — তৃতীয় ব্যক্তি — বহুবচন — নারী',
                'examples': 'তারা',
              },
              {
                'title': '৭. আন্তা',
                'description':
                    'মুখাতাব — দ্বিতীয় ব্যক্তি — একবচন — পুরুষ',
                'examples': 'তুমি',
              },
              {
                'title': '৮. আন্তুমা',
                'description':
                    'মুখাতাব — দ্বিতীয় ব্যক্তি — দ্বিবচন — পুরুষ',
                'examples': 'তোমরা দুজন',
              },
              {
                'title': '৯. আন্তুম',
                'description':
                    'মুখাতাব — দ্বিতীয় ব্যক্তি — বহুবচন — পুরুষ',
                'examples': 'তোমরা',
              },
              {
                'title': '১০. আন্তি',
                'description':
                    'মুখাতাব — দ্বিতীয় ব্যক্তি — একবচন — নারী',
                'examples': 'তুমি',
              },
              {
                'title': '১১. আন্তুমা',
                'description':
                    'মুখাতাব — দ্বিতীয় ব্যক্তি — দ্বিবচন — নারী',
                'examples': 'তোমরা দুজন',
              },
              {
                'title': '১২. আন্তুন্না',
                'description':
                    'মুখাতাব — দ্বিতীয় ব্যক্তি — বহুবচন — নারী',
                'examples': 'তোমরা',
              },
              {
                'title': '১৩. আনা',
                'description':
                    'মুতাকাল্লিম — প্রথম ব্যক্তি — একবচন',
                'examples': 'আমি',
              },
              {
                'title': '১৪. নাহনু',
                'description':
                    'মুতাকাল্লিম — প্রথম ব্যক্তি — বহুবচন',
                'examples': 'আমরা',
              },
            ],
          },
          {
            'title': '১৪টি রূপ মনে রাখার গুরুত্বপূর্ণ বিষয়',
            'icon': Icons.info_outline_rounded,
            'content':
                'দামীরের ১৪টি প্রচলিত রূপে ব্যক্তি, সংখ্যা ও লিঙ্গের বিষয়টি গুরুত্বপূর্ণ।\n\nহুমা শব্দটি দুজন পুরুষ এবং দুজন নারী—উভয়ের ক্ষেত্রেই ব্যবহৃত হয়। একইভাবে আন্তুমা শব্দটিও দুজন পুরুষ ও দুজন নারীর ক্ষেত্রে ব্যবহৃত হতে পারে। এখানে লিঙ্গ প্রসঙ্গ ও সংশ্লিষ্ট ফে‘ল/ইসমের মাধ্যমে বোঝা যায়।',
          },
          {
            'title': 'দামীর মুত্তাসিল',
            'icon': Icons.link_rounded,
            'content':
                'দামীর যখন অন্য কোনো শব্দের সঙ্গে যুক্ত হয়ে আসে, তাকে দামীর মুত্তাসিল বা সংযুক্ত সর্বনাম বলা হয়। এটি ইসম, ফে‘ল বা হরফের সঙ্গে যুক্ত হয়ে বিভিন্ন ব্যাকরণিক ভূমিকা পালন করতে পারে।\n\nযেমন— কোনো ইসমের সঙ্গে যুক্ত হয়ে মালিকানা বোঝাতে পারে, আবার ফে‘লের সঙ্গে যুক্ত হয়ে কর্ম বোঝাতে পারে।',
          },
          {
            'title': 'সংযুক্ত দামীর — ইসমের সঙ্গে',
            'icon': Icons.menu_book_rounded,
            'items': [
              {
                'title': 'রব্বুহু',
                'description': 'তার রব',
                'examples': 'হু → তার',
              },
              {
                'title': 'রব্বুহা',
                'description': 'তার রব — নারী',
                'examples': 'হা → তার',
              },
              {
                'title': 'রব্বুহুম',
                'description': 'তাদের রব',
                'examples': 'হুম → তাদের',
              },
              {
                'title': 'রব্বুকা',
                'description': 'তোমার রব — পুরুষ',
                'examples': 'কা → তোমার',
              },
              {
                'title': 'রব্বুকুম',
                'description': 'তোমাদের রব',
                'examples': 'কুম → তোমাদের',
              },
              {
                'title': 'রব্বুনা',
                'description': 'আমাদের রব',
                'examples': 'না → আমাদের',
              },
            ],
          },
          {
            'title': 'সংযুক্ত দামীরের সাধারণ রূপ',
            'icon': Icons.people_outline_rounded,
            'items': [
              {
                'title': 'কা',
                'description':
                    'দ্বিতীয় ব্যক্তি, একবচন, পুরুষের সংযুক্ত দামীর।',
                'examples':
                    'রব্বুকা — তোমার রব\nকিছু বাক্যে — তোমাকে',
              },
              {
                'title': 'কি',
                'description':
                    'দ্বিতীয় ব্যক্তি, একবচন, নারীর সংযুক্ত দামীর।',
                'examples':
                    'তোমার / তোমাকে — প্রসঙ্গ ও ব্যাকরণিক অবস্থান অনুযায়ী',
              },
              {
                'title': 'কুম',
                'description':
                    'দ্বিতীয় ব্যক্তি, বহুবচনের সংযুক্ত দামীর।',
                'examples':
                    'রব্বুকুম — তোমাদের রব\nতোমাদেরকে — প্রসঙ্গভেদে',
              },
              {
                'title': 'হু',
                'description':
                    'তৃতীয় ব্যক্তি, একবচন, পুরুষের সংযুক্ত দামীর।',
                'examples':
                    'রব্বুহু — তার রব\nতাকে — প্রসঙ্গভেদে',
              },
              {
                'title': 'হা',
                'description':
                    'তৃতীয় ব্যক্তি, একবচন, নারীর সংযুক্ত দামীর।',
                'examples':
                    'রব্বুহা — তার রব\nতাকে — প্রসঙ্গভেদে',
              },
              {
                'title': 'হুম',
                'description':
                    'তৃতীয় ব্যক্তি, বহুবচনের সংযুক্ত দামীর।',
                'examples':
                    'রব্বুহুম — তাদের রব\nতাদেরকে — প্রসঙ্গভেদে',
              },
              {
                'title': 'না',
                'description':
                    'প্রথম ব্যক্তি, বহুবচনের সংযুক্ত দামীর।',
                'examples':
                    'রব্বুনা — আমাদের রব\nআমাদেরকে — প্রসঙ্গভেদে',
              },
            ],
          },
          {
            'title': 'দামীরের অর্থ সবসময় এক নয়',
            'icon': Icons.warning_amber_rounded,
            'content':
                'একটি সংযুক্ত দামীরকে শুধু একটি বাংলা অর্থ দিয়ে মুখস্থ করলে ভুল হতে পারে। যেমন “কা” কখনো “তোমার” আবার অন্য বাক্যে “তোমাকে” হিসেবে প্রকাশিত হতে পারে। একইভাবে “হু”, “হা”, “কুম”, “হুম” ইত্যাদির অর্থ তাদের ব্যাকরণিক অবস্থান অনুযায়ী পরিবর্তিত হতে পারে।',
          },
          {
            'title': 'দামীর মুত্তাসিল ও মুস্তাতির',
            'icon': Icons.visibility_off_outlined,
            'content':
                'দামীরের আরেকটি গুরুত্বপূর্ণ আলোচনা হলো— মুত্তাসিল এবং মুস্তাতির।\n\nমুত্তাসিল হলো এমন দামীর, যা শব্দের সঙ্গে প্রকাশ্যভাবে যুক্ত থাকে।\n\nমুস্তাতির হলো এমন দামীর, যা শব্দের মধ্যে প্রকাশ্যে আলাদা শব্দ হিসেবে দেখা যায় না; কিন্তু ফে‘লের রূপ ও বাক্যের গঠন থেকে কর্তা বোঝা যায়।\n\nএটি ফে‘লের বিস্তারিত ব্যাকরণ শেখার সময় আরও গভীরভাবে আলোচনা করা যেতে পারে।',
          },
          {
            'title': 'কুরআন বুঝতে দামীর কেন গুরুত্বপূর্ণ',
            'icon': Icons.menu_book_rounded,
            'content':
                'কুরআনে দামীর অত্যন্ত বেশি ব্যবহৃত হয়েছে। একটি দামীর কোন ব্যক্তিকে নির্দেশ করছে, তার লিঙ্গ ও সংখ্যা কী, এবং এটি কর্তা না কর্ম না মালিকানা প্রকাশ করছে—এসব বুঝতে পারলে আয়াতের অর্থ অনেক বেশি স্পষ্ট হয়।',
          },
        ];

      default:
        return [];
    }
  }

  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final data = category;
    final color = data['color'] as Color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          data['title'],
          style: GoogleFonts.hindSiliguri(
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          children: [
            _buildHeader(
              context,
              data,
              color,
            ),

            const SizedBox(height: 20),

            Text(
              'বিস্তারিত আলোচনা',
              style: GoogleFonts.hindSiliguri(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            ...sections.map(
              (section) => _buildExpansionTile(
                context,
                section,
                color,
              ),
            ),

            const SizedBox(height: 15),

            _buildBottomNote(context),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Header
  // ------------------------------------------------------------

  Widget _buildHeader(
    BuildContext context,
    Map<String, dynamic> data,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(.18),
            color.withOpacity(.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: color.withOpacity(.20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data['icon'] as IconData,
              color: color,
              size: 32,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            data['title'],
            style: GoogleFonts.hindSiliguri(
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'সংক্ষিপ্ত সংজ্ঞা',
            style: GoogleFonts.hindSiliguri(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            data['definition'],
            textAlign: TextAlign.center,
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 18),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'সহজ উদাহরণ',
              style: GoogleFonts.hindSiliguri(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 10),

          ...List.generate(
            (data['examples'] as List).length,
            (index) {
              final example = data['examples'][index];

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withOpacity(.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${example['word']} → ${example['meaning']}',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ExpansionTile
  // ------------------------------------------------------------

  Widget _buildExpansionTile(
    BuildContext context,
    Map<String, dynamic> section,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withOpacity(.5),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: color.withOpacity(.06),
          highlightColor: color.withOpacity(.04),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 3,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              section['icon'] ?? Icons.article_outlined,
              color: color,
              size: 22,
            ),
          ),
          title: Text(
            section['title'],
            style: GoogleFonts.hindSiliguri(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          children: [
            if (section['content'] != null)
              _buildContent(
                context,
                section['content'],
              ),

            if (section['items'] != null)
              ..._buildItems(
                context,
                section['items'],
                color,
              ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Content
  // ------------------------------------------------------------

  Widget _buildContent(
    BuildContext context,
    String content,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        content,
        style: GoogleFonts.hindSiliguri(
          fontSize: 15.5,
          height: 1.7,
          color: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.color,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Items
  // ------------------------------------------------------------

  List<Widget> _buildItems(
    BuildContext context,
    List items,
    Color color,
  ) {
    return List.generate(
      items.length,
      (index) {
        final item = items[index];

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(
            bottom: index == items.length - 1 ? 0 : 10,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(.055),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: color.withOpacity(.10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.13),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      item['title'],
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              if (item['description'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  item['description'],
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 14.5,
                    height: 1.6,
                  ),
                ),
              ],

              if (item['examples'] != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withOpacity(.65),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item['examples'],
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // Bottom Note
  // ------------------------------------------------------------

  Widget _buildBottomNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.amber.withOpacity(.08),
        border: Border.all(
          color: Colors.amber.withOpacity(.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: Colors.amber,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'কুরআনের আরবি বুঝতে শুধু শব্দের বাংলা অর্থ জানা যথেষ্ট নয়। শব্দটি ইসম, ফে‘ল নাকি হরফ—তারপর তার ব্যাকরণিক ভূমিকা, গঠন, ব্যক্তি, সংখ্যা, লিঙ্গ এবং আয়াতের প্রসঙ্গ বুঝতে হবে।',
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}