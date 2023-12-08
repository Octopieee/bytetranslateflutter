part of 'speech_translate_page.dart';

String dirPath = '';
String filePath = '';

Future _buildFilePath() async {
  // Gets cache directory as string for storing audio file on cache
  Directory tempDir = await getApplicationDocumentsDirectory();
  String tempPath = tempDir.path;

  // Create directory string and audio file string

  dirPath = '$tempPath/audio';
  filePath = '$dirPath/test.wav';

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
