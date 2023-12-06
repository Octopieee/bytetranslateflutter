import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:whisper_flutter_plus/whisper_flutter_plus.dart';

part 'unfocus_node.dart';
part 'path_builder.dart';
part 'lang_enum.dart';
part 'whisper.dart';

void main() {
  runApp(const MainApp());
}

class MainAppState extends ChangeNotifier {}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainAppState(),
      child: MaterialApp(
        title: 'ByteTranslate',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;

  late AudioPlayer audioPlayer;
  late AudioRecorder audioRecord;
  bool isRecording = false;

  final textToTranslate = TextEditingController();
  final translatedTextField = TextEditingController();

  final languageMenu = TextEditingController();

  @override
  void initState() {
    // Initialize recorder and player
    audioRecord = AudioRecorder();
    audioPlayer = AudioPlayer();

    // _requestPerms();

    super.initState();
  }

  @override
  void dispose() {
    textToTranslate.dispose();
    translatedTextField.dispose();

    languageMenu.dispose();

    audioRecord.dispose();
    audioPlayer.dispose();

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

  Future<void> _playRecording() async {
    try {
      Source urlSource = DeviceFileSource(audioPath);
      await audioPlayer.play(urlSource);
    } catch (e) {
      debugPrint('[!!!]- Error: _playRecording() -> $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.blueAccent,
          items: const [
            CurvedNavigationBarItem(
              child: Icon(Icons.text_fields),
              label: 'Text Translation',
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.multitrack_audio),
              label: 'Speech Translation',
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          onTap: (index) {
            setState(() {
              page = index;
            });

            debugPrint('|- Current Page Index: $page');
          },
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Button Row
              if (isRecording) const Text('Recording in Progress'),
              if (!isRecording && audioPath != null && audioPath.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                        onPressed: _playRecording,
                        child: const Text('Play Recording')),
                    const SizedBox(width: 20),
                    ElevatedButton(
                        onPressed: () {
                          _translate().then(
                              (value) => translatedTextField.text = value);
                        },
                        child: const Text('Translate')),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 0.0,
                      horizontal: 20.0,
                    ),
                    child: IconButton.outlined(
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

              // Text Field: Text to Translate
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                child: TextField(
                    controller: textToTranslate,
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      label: Text('Text to Translate'),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                      hintText: 'Text to translate here...',
                      filled: true,
                    )),
              ),

              // Language Selection
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: DropdownMenu<LangLabel>(
                  initialSelection: LangLabel.auto,
                  controller: languageMenu,
                  requestFocusOnTap: true,
                  label: const Text('Spoken Language'),
                  onSelected: (LangLabel? lang) {
                    setState(() {
                      spokenLang = lang as LangLabel;
                    });
                    debugPrint('|- Current Language: $spokenLang');
                  },
                  dropdownMenuEntries: LangLabel.values
                      .map<DropdownMenuEntry<LangLabel>>((LangLabel lang) {
                    return DropdownMenuEntry<LangLabel>(
                      value: lang,
                      label: lang.label,
                    );
                  }).toList(),
                ),
              ),

              // Text Field: Whisper Output Text
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                    controller: translatedTextField,
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    enableInteractiveSelection: false,
                    focusNode: UnfocusNode(),
                    decoration: const InputDecoration(
                      label: Text('Translated Text'),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                      hintText: 'Translated text outputs here...',
                      filled: true,
                    )),
              ),
            ],
          ),
        ));
  }
}
