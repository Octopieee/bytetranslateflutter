import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'package:record/record.dart';

import 'package:whisper_flutter_plus/whisper_flutter_plus.dart';

import 'spoken_lang_enum.dart';

part 'path_builder.dart';
part 'whisper.dart';

class SpeechTranslate extends StatefulWidget {
  const SpeechTranslate({
    super.key,
  });

  @override
  State<SpeechTranslate> createState() => _SpeechTranslateState();
}

class _SpeechTranslateState extends State<SpeechTranslate> {
  late AudioRecorder audioRecord;
  bool isRecording = false;
  final translatedTextField = TextEditingController();

  final languageMenu = TextEditingController();

  @override
  void initState() {
    // Initialize recorder and player
    audioRecord = AudioRecorder();

    super.initState();
  }

  @override
  void dispose() {
    translatedTextField.dispose();

    languageMenu.dispose();

    audioRecord.dispose();

    super.dispose();
  }

  Future _requestPerms() async {
    // Asks for microphone and audio file access permissions
    Map<Permission, PermissionStatus> statuses =
        await [Permission.microphone, Permission.audio].request();

    PermissionStatus? audioFileStatus = statuses[Permission.audio];
    PermissionStatus? micStatus = statuses[Permission.microphone];

    debugPrint('|- Microphone Perms: $micStatus');
    debugPrint('|- Audio File Access Perms: $audioFileStatus');

    if (micStatus == PermissionStatus.granted &&
        audioFileStatus == PermissionStatus.granted) {
      // Builds audio file path if perms are granted
      await _buildFilePath();
    }
  }

  Future<void> _startRecording() async {
    try {
      await _requestPerms();

      if (await Permission.microphone.status.isGranted) {
        debugPrint('|- FILE PATH DOUBLE CHECK: $filePath');

        const recConfig = RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
        );

        debugPrint('|- Recording Config: $recConfig');

        await audioRecord.start(const RecordConfig(), path: filePath);

        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      debugPrint('[!!!]- Error: _startRecording() -> $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      String? path = await audioRecord.stop();

      setState(() {
        isRecording = false;
        audioPath = path!;
        debugPrint('|- Recording Saved To: $audioPath');
      });
    } catch (e) {
      debugPrint('[!!!]- Error: _stopRecording() -> $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(
          flex: 1,
        ),

        // Top Row with Button and Dropdown
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 20.0,
              ),
              child: DropdownMenu<SpokenLangLabel>(
                initialSelection: SpokenLangLabel.auto,
                controller: languageMenu,
                requestFocusOnTap: true,
                label: const Text('Spoken Language'),
                onSelected: (SpokenLangLabel? lang) {
                  setState(() {
                    spokenLang = lang as SpokenLangLabel;
                  });
                  debugPrint('|- Current Language: $spokenLang');
                },
                dropdownMenuEntries: SpokenLangLabel.values
                    .map<DropdownMenuEntry<SpokenLangLabel>>(
                        (SpokenLangLabel lang) {
                  return DropdownMenuEntry<SpokenLangLabel>(
                    value: lang,
                    label: lang.label,
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            FilledButton(
                onPressed: () {
                  _translate()
                      .then((value) => translatedTextField.text = value);
                },
                child: const Text('Translate')),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 20.0,
              ),
              child: IconButton.filled(
                isSelected: isRecording,
                icon: const Icon(Icons.mic_off),
                selectedIcon: const Icon(Icons.mic),
                onPressed: () {
                  setState(() {
                    isRecording = !isRecording;
                  });

                  isRecording ? _startRecording() : _stopRecording();
                },
              ),
            ),
          ],
        ),

        // Text Field: Whisper Output Text
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 20.0,
          ),
          child: TextField(
              controller: translatedTextField,
              maxLines: 15,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                label: Text('Translated Text'),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                hintText: 'Translated text outputs here...',
                filled: true,
              )),
        ),
        const Spacer(
          flex: 3,
        ),
      ],
    ));
  }
}
