
import 'package:get/get_navigation/src/root/internacionalization.dart';

class TodoTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      'title': 'To-Do App',
      'language': 'Language',
      'Arabic': 'العربية',
      'English': 'English',
      'menu': 'Main Menu',
      'theme': 'Change Theme',
      'more': 'about us',
      'add': 'add a todo',
      'default_language': 'English',
    },
    'ar': {
      'title': 'المفكرة',
      'language': 'اللغة',
      'English': "English",
      'Arabic': "العربيه",
      'menu': "القائمه الرئيسيه",
      'theme': "واجهة التطبيق",
      'more': "المزيد عنا",
      'add': "اضف مهمه",
      'default_language': "العربيه",
    }
  };
}