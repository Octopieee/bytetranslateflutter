// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whisper_flutter_plus/whisper_flutter_plus.dart';

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
        home: HomePage(),
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
  late AudioPlayer audioPlayer;
  late AudioRecorder audioRecord;
  bool isRecording = false;
  String audioPath = '';

  String dirPath = '';
  String filePath = '';

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
    audioRecord.dispose();
    audioPlayer.dispose();

    super.dispose();
  }

  Future _requestPerms() async {
    // PermissionStatus recStatus = await Permission.microphone.request();
    // print('Microphone Perms: $recStatus');

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

  Future _buildFilePath() async {
    // Gets cache directory as string for storing audio file on cache
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;

    // Create directory string and audio file string
    setState(() {
      dirPath = '$tempPath/audio';
      filePath = '$dirPath/test.wav';
    });

    debugPrint('|- Directory Path: $dirPath');
    debugPrint('|- Audio File Path: $filePath');

    // Create directory and audio file
    await _createDir();
    await _createFile();
  }

  Future _createDir() async {
    // Check if the directory already exists
    bool isDirCreated = await Directory(dirPath).exists();
    if (!isDirCreated) {
      // If it doesn't, create directory
      Directory(dirPath).create(recursive: true).then((Directory dir) {
        debugPrint("|- Directory Created At: ${dir.path}");
      });
    }
  }

  Future _createFile() async {
    // Create file at directory path
    File(filePath).create(recursive: true).then((File file) async {
      Uint8List bytes = await file.readAsBytes();
      file.writeAsBytes(bytes, mode: FileMode.writeOnly);

      debugPrint('|- Audio File Created At: ${file.path}');
    });
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

        await audioRecord.start(RecordConfig(), path: filePath);

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

  Future _translate() async {
    try {
      WhisperModel model = WhisperModel.base;
      final Whisper whisper = Whisper(model: WhisperModel.base);
      debugPrint('|- Whisper Model Loaded: ${model.modelName}');

      final String? whisperVersion = await whisper.getVersion();
      debugPrint('|- Whisper Version: $whisperVersion');

      debugPrint('|- Whisper Is Working...');
      var whisperResponse = await whisper.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioPath,
          isTranslate: true,
          isNoTimestamps: false,
          splitOnWord: false,
        ),
      );

      final String translatedText = whisperResponse.text;
      print('|- Done! Whisper\'s Output: $translatedText');

      return translatedText;
    } catch (e) {
      debugPrint('[!!!]- Error: _translate() -> $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button Row
            if (isRecording) const Text('Recording in Progress'),
            Column(
              children: [
                ElevatedButton(
                    onPressed: isRecording ? _stopRecording : _startRecording,
                    child: isRecording
                        ? const Text('Stop Recording')
                        : const Text('Start Recording')),
                if (!isRecording && audioPath != null && audioPath.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                          onPressed: _playRecording,
                          child: const Text('Play Recording')),
                      SizedBox(width: 20),
                      ElevatedButton(
                          onPressed: _translate,
                          child: const Text('Translate')),
                    ],
                  ),
              ],
            ),

            // Text Field: Text to Translate
            Text('Input Field'),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                  maxLines: 6,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Text To Translate Here',
                    filled: true,
                  )),
            ),

            // Text Field: Whisper Output Text
            Text('Output Field'),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                  maxLines: 6,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Translated Text Here',
                    filled: true,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
