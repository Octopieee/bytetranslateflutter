part of 'text_translate_page.dart';

// Initialize the source and target languages
TranslateLanguage source = TranslateLanguage.spanish;
TranslateLanguage target = TranslateLanguage.english;

// Initialize our model manager
final OnDeviceTranslatorModelManager modelManager =
    OnDeviceTranslatorModelManager();

// Initialize translator with source and target languages
OnDeviceTranslator translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.spanish,
    targetLanguage: TranslateLanguage.english);

// Bools in order to keep track of whether or not things are happening in the background
bool isDownloading = false;
bool isTranslating = false;

// Uses OnDeviceTranslator in order to ask model to translate text
Future<String> translate(String translateText) async {
  // Check if source/target model is downloaded
  await downloadModel(source.bcpCode);
  await downloadModel(target.bcpCode);

  isTranslating = true;
  String output = '';
  await translator
      .translateText(translateText) // Calls built in function to translate text
      .then((translatedText) => {
            debugPrint('|- Translated Text: $translatedText'),
            output =
                translatedText // Set output will now have our translated text
          })
      .catchError((e) {
    debugPrint('[!!!]- Error: _translate() -> $e');
  });
  isTranslating = false;

  return output; // Return translated text
}

// A function that uses OnDeviceTranslatorModelManager to download a model
Future<void> downloadModel(String bcpCode) async {
  debugPrint('|- Downloading model: $bcpCode');
  // Check if inputted language model is downloaded
  await modelManager.isModelDownloaded(bcpCode).then((isDownloaded) async => {
        if (!isDownloaded) // If not
          {
            // Download specified language model
            await modelManager
                .downloadModel(
                    bcpCode) // Uses built in function to download the model
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
