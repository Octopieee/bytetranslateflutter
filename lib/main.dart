// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

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
  late AudioRecorder audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = '';

  String dirPath = '';
  String filePath = '';

  @override
  void initState() {
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
    // Map<Permission, PermissionStatus> statuses =
    //     await [Permission.microphone, Permission.storage].request();
    // print(statuses[Permission.microphone]);
    // print(statuses[Permission.storage]);

    PermissionStatus recStatus = await Permission.microphone.request();
    print('Microphone Perms: $recStatus');
    if (recStatus.isGranted) {
      await _buildFilePath();
    }
  }

  Future _buildFilePath() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    setState(() {
      dirPath = '$tempPath/audio';
      filePath = '$dirPath/test.wav';
    });

    print('DIR PATH: $dirPath');
    print('FILE PATH: $filePath');

    await _createDir();
    await _createFile();
  }

  Future _createDir() async {
    bool isDirCreated = await Directory(dirPath).exists();
    if (!isDirCreated) {
      Directory(dirPath).create(recursive: true).then((Directory dir) {
        print("DIR CREATED AT: ${dir.path}");
      });
    }
  }

  Future _createFile() async {
    File(filePath).create(recursive: true).then((File file) async {
      Uint8List bytes = await file.readAsBytes();
      file.writeAsBytes(bytes);

      print('FILE CREATED AT: ${file.path}');
    });
  }

  Future<void> _startRecording() async {
    try {
      await _requestPerms();

      if (await Permission.microphone.status.isGranted) {
        print('FILE PATH DOUBLE CHECK: $filePath');

        await audioRecord.start(const RecordConfig(), path: filePath);

        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      print('Error Start Recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      String? path = await audioRecord.stop();

      setState(() {
        isRecording = false;
        audioPath = path!;
        print(audioPath);
      });
    } catch (e) {
      print('Error Stop Recording: $e');
    }
  }

  Future<void> _playRecording() async {
    try {
      Source urlSource = UrlSource(audioPath);
      await audioPlayer.play(urlSource);
    } catch (e) {
      print('Error Playing Recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRecording) const Text('Recording in Progress'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                    onPressed: isRecording ? _stopRecording : _startRecording,
                    child: isRecording
                        ? const Text('Stop Recording')
                        : const Text('Start Recording')),
                if (!isRecording && audioPath != null && audioPath.isNotEmpty)
                  Row(
                    children: [
                      SizedBox(width: 20),
                      ElevatedButton(
                          onPressed: _playRecording,
                          child: const Text('Play Recording')),
                    ],
                  ),
              ],
            ),
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
