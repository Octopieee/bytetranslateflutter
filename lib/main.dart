import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

import 'speech_translate_page.dart';
import 'text_translate_page.dart';
import 'settings_page.dart';

void main() {
  runApp(const MainApp());
}

class MainAppState extends ChangeNotifier {}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainAppState(),
      child: MaterialApp(
        title: 'ByteTranslate',
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple, brightness: Brightness.light),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData()),
        darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple, brightness: Brightness.dark),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData()),
        themeMode: ThemeMode.system,
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
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          color: Theme.of(context).colorScheme.inversePrimary,
          buttonBackgroundColor: Theme.of(context).colorScheme.onPrimary,
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
              currentIndex = index;
            });

            debugPrint('|- Current Page Index: $currentIndex');
          },
        ),
        appBar: AppBar(
          systemOverlayStyle: (Theme.of(context).brightness == Brightness.dark)
              ? SystemUiOverlayStyle(
                  systemNavigationBarColor:
                      Theme.of(context).colorScheme.inversePrimary,
                  statusBarIconBrightness: Brightness.light,
                )
              : SystemUiOverlayStyle(
                  systemNavigationBarColor:
                      Theme.of(context).colorScheme.inversePrimary,
                  statusBarIconBrightness: Brightness.dark,
                ),
        ),
        body: IndexedStack(
          index: currentIndex,
          children: const [
            TextTranslate(),
            SpeechTranslate(),
            Settings(),
          ],
        ));
  }
}
