part of 'speech_translate_page.dart';

String audioPath = '';
SpokenLangLabel spokenLang = SpokenLangLabel.auto;

Future<String> _translate() async {
  try {
    // Selecting our model
    const WhisperModel model = WhisperModel.base;

    // Initializes whisper with said model
    const Whisper whisper = Whisper(
      model: model,
    );
    debugPrint('|- Whisper Model Loaded: ${whisper.model}');

    // Prints out whisper model version to console (Breaks code)
    // final String? whisperVersion = await whisper.getVersion();
    // debugPrint('|- Whisper Version: $whisperVersion');

    debugPrint('|- Whisper Is Working...');
    // Asks whisper to translate audio and we await a response
    final WhisperTranscribeResponse whisperResponse = await whisper.transcribe(
      transcribeRequest: TranscribeRequest(
        audio: audioPath,
        isTranslate: true,
        language: spokenLang.lang,
        diarize: false,
        threads: 8,
      ),
    );

    // Retrieves a list of 'segments' from whisper response
    final List<WhisperTranscribeSegment>? segmentResponse =
        whisperResponse.segments;

    // Essentially prints out the amount of time each 'segment' took to translate
    if (segmentResponse != null) {
      for (var segment in segmentResponse) {
        debugPrint('|- Segment: ${segment.text}');
        debugPrint('|- Duration: ${segment.fromTs} - ${segment.toTs}');
      }
    }

    // Translated Text Output
    final String translatedText = whisperResponse.text;
    debugPrint('|- Done! Whisper\'s Output: $translatedText');

    return translatedText; // Finally return translated text
  } catch (e) {
    debugPrint('[!!!]- Error: _translate() -> $e');
    return '';
  }
}
