part of 'text_translate_page.dart';

TranslateLanguage source = TranslateLanguage.spanish;
TranslateLanguage target = TranslateLanguage.english;

final OnDeviceTranslatorModelManager modelManager =
    OnDeviceTranslatorModelManager();

OnDeviceTranslator translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.spanish,
    targetLanguage: TranslateLanguage.english);

bool isDownloading = false;
bool isTranslating = false;

Future<String> translate(String translateText) async {
  // Check if source/target model is downloaded
  await downloadModel(source.bcpCode);
  await downloadModel(target.bcpCode);

  isTranslating = true;
  String output = '';
  await translator
      .translateText(translateText)
      .then((translatedText) => {
            debugPrint('|- Translated Text: $translatedText'),
            output = translatedText
          })
      .catchError((e) {
    debugPrint('[!!!]- Error: _translate() -> $e');
  });
  isTranslating = false;

  return output;
}

Future<void> downloadModel(String bcpCode) async {
  // Check if inputted language model is downloaded
  debugPrint('|- Downloading model: $bcpCode');
  await modelManager.isModelDownloaded(bcpCode).then((isDownloaded) async => {
        if (!isDownloaded) // If not
          {
            // Download specified language model
            await modelManager
                .downloadModel(bcpCode)
                .then((isSuccessful) => {
                      if (isSuccessful)
                        {debugPrint('|- Download success! Model: $bcpCode')}
                    })
                .catchError((e) {
              debugPrint('[!!!]- Error: _translate() -> $e');
            })
          }
      });
}

  // String capitalize(String s) {
  //   return s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';
  // }
