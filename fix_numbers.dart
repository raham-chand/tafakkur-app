import 'dart:io';

void main() {
  File file = File('lib/data/quran_data.dart');
  String content = file.readAsStringSync();
  
  String toBengali(String english) {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String result = english;
    for (int i = 0; i < englishDigits.length; i++) {
      result = result.replaceAll(englishDigits[i], bengaliDigits[i]);
    }
    return result;
  }
  
  content = content.replaceAllMapped(
    RegExp(r"'name':\s*'36 : ইয়াসীন'"),
    (match) => "'name': '৩৬ : ইয়াসীন'"
  );

  content = content.replaceAllMapped(
    RegExp(r"'no':\s*'36 : (\d+)'"),
    (match) {
      String bengaliAyat = toBengali(match.group(1)!);
      return "'no': '৩৬ : $bengaliAyat'";
    }
  );

  file.writeAsStringSync(content);
}
