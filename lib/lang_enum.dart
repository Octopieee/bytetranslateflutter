part of 'main.dart';

enum LangLabel {
  auto('Auto-Detect', 'id'),
  english('English', 'en'),
  spanish('Spanish', 'es'),
  french('French', 'fr'),
  russian('Russian', 'ru'),
  chinese('Chinese', 'zh'),
  dutch('Dutch', 'nl');

  const LangLabel(this.label, this.lang);
  final String label;
  final String lang;
}
