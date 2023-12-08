enum SpokenLangLabel {
  auto('Auto-Detect', 'id'),
  english('English', 'en'),
  spanish('Spanish', 'es'),
  french('French', 'fr'),
  russian('Russian', 'ru'),
  chinese('Chinese', 'zh'),
  dutch('Dutch', 'nl');

  const SpokenLangLabel(this.label, this.lang);
  final String label;
  final String lang;
}
