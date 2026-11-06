import 'dart:convert';
import 'dart:io';

// ==========================================
// QURAN DATA SCRAPER
// This script fetches data from the taffakur website.
// You can use it to fetch missing Surahs and copy-paste them
// into your quran_data.dart file.
// ==========================================

Future<void> main() async {
  print('Scraping data from taffakur...\n');
  
  // ===========================================
  // IMPORTANT: CHANGE THESE NUMBERS
  // Add the Surah numbers you want to fetch here:
  // e.g., to fetch Surah Yaseen, use [36].
  // ===========================================
  List<int> surahsToFetch = [35];
  
  StringBuffer sb = StringBuffer();

  String toBengali(String english) {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String result = english;
    for (int i = 0; i < englishDigits.length; i++) {
      result = result.replaceAll(englishDigits[i], bengaliDigits[i]);
    }
    return result;
  }

  for (int surahId in surahsToFetch) {
    int totalAyats = await getAyatCount(surahId);
    
    if (totalAyats == 0) {
      print('Could not find Ayats for Surah $surahId or an error occurred.');
      continue;
    }
    
    print('Found $totalAyats Ayats for Surah $surahId');
    
    List<Map<String, String>> ayats = [];
    for (int ayatNo = 1; ayatNo <= totalAyats; ayatNo++) {
      print('Fetching Surah $surahId Ayat $ayatNo...');
      var data = await fetchAyatData(surahId, ayatNo);
      ayats.add(data);
      // Wait for a bit (500ms) before the next request to prevent ban or server overload
      await Future.delayed(Duration(milliseconds: 500));
    }

    // Generate Dart string
    sb.writeln("    {");
    sb.writeln("      'no': $surahId,");
    sb.writeln("      'name': '${toBengali(surahId.toString())} : ...', // Change this to the real name");
    sb.writeln("      'ayats': [");
    for (var ayat in ayats) {
      sb.writeln("        {");
      sb.writeln("          'no': '${toBengali(ayat['no']!)}',");
      sb.writeln("          'arabic': '${ayat['arabic']?.replaceAll("'", "\\'")}',");
      sb.writeln("          'pronunciation': '${ayat['pronunciation']?.replaceAll("'", "\\'")}',");
      sb.writeln("          'meaning': '${ayat['meaning']?.replaceAll("'", "\\'")}',");
      sb.writeln("          'wordMeaning': '${ayat['wordMeaning']?.replaceAll("\n", "\\n")?.replaceAll("'", "\\'")}',");
      sb.writeln("          'notes': '${ayat['notes']?.replaceAll("\n", "\\n")?.replaceAll("'", "\\'")}',");
      sb.writeln("        },");
    }
    sb.writeln("      ]");
    sb.writeln("    },");
  }

  File('extracted_surahs.txt').writeAsStringSync(sb.toString());
  print('\n✅ Done! The dart code has been saved to "extracted_surahs.txt".');
  print('You can open this file and copy the contents into quran_data.dart.');
}

// --------------------------------------------------------------------------
// HELPER FUNCTIONS 
// --------------------------------------------------------------------------

Future<int> getAyatCount(int surahId) async {
  var url = Uri.parse('https://oegfashion.com/taffakur/get-ayat-list?sura_id=$surahId');
  var httpClient = HttpClient();
  httpClient.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
  var request = await httpClient.getUrl(url);
  var response = await request.close();
  var responseBody = await response.transform(utf8.decoder).join();
  try {
    Map<String, dynamic> data = jsonDecode(responseBody);
    List ayatLists = data['ayatLists'] ?? [];
    return ayatLists.length;
  } catch (e) {
    return 0;
  }
}

Future<Map<String, String>> fetchAyatData(int surahId, int pageNo) async {
  var url = Uri.parse('https://oegfashion.com/taffakur/atay-list/$surahId?page=$pageNo');
  var httpClient = HttpClient();
  httpClient.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
  var request = await httpClient.getUrl(url);
  var response = await request.close();
  var responseBody = await response.transform(utf8.decoder).join();
  
  // Strip out all HTML comments which might break our string matching
  responseBody = responseBody.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');

  String extract(String fieldName) {
    try {
      var nameRegExp = RegExp('<div class="avatar avatar-md flex-shrink-0">\\s*$fieldName\\s*</div>([\\s\\S]*?)</div>', multiLine: true);
      var match = nameRegExp.firstMatch(responseBody);
      if (match != null) {
        String contentBlock = match.group(1)!;
        // Replace html breaks with newline before removing tags
        contentBlock = contentBlock.replaceAll(RegExp(r'<br\s*\/?>', caseSensitive: false), '\n');
        // Strip all remaining HTML tags
        String textContent = contentBlock.replaceAll(RegExp(r'<[^>]*>'), '').trim();
        return textContent;
      }
    } catch(e) { /* ignore */ }
    return '';
  }

  return {
    'no': '$surahId : $pageNo',
    'arabic': extract('আয়াত'),
    'pronunciation': extract('বাংলা উচ্চারণ'),
    'meaning': extract('অর্থ'),
    'wordMeaning': extract('শব্দার্থ'),
    'notes': extract('টিকা'),
  };
}
