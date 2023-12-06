part of 'main.dart';

String audioPath = '';
LangLabel spokenLang = LangLabel.auto;

Future<String> _translate() async {
  try {
    const WhisperModel model = WhisperModel.medium;

    const Whisper whisper = Whisper(
      model: model,
    );
    debugPrint('|- Whisper Model Loaded: ${whisper.model}');

    // final String? whisperVersion = await whisper.getVersion();
    // debugPrint('|- Whisper Version: $whisperVersion');

    debugPrint('|- Whisper Is Working...');
    final WhisperTranscribeResponse whisperResponse = await whisper.transcribe(
      transcribeRequest: TranscribeRequest(
        audio: audioPath,
        isTranslate: true,
        language: spokenLang.lang,
        threads: 8,
      ),
    );

    // Translation Time Check
    final List<WhisperTranscribeSegment>? segmentResponse =
        whisperResponse.segments;

    if (segmentResponse != null) {
      for (var segment in segmentResponse) {
        debugPrint('|- Segment: ${segment.text}');
        debugPrint('|- Duration: ${segment.fromTs} - ${segment.toTs}');
      }
    }

    // Translated Text Output
    final String translatedText = whisperResponse.text;
    debugPrint('|- Done! Whisper\'s Output: $translatedText');

    return translatedText;
  } catch (e) {
    debugPrint('[!!!]- Error: _translate() -> $e');
    return '';
  }
}
