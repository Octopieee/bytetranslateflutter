import 'package:flutter/material.dart';

import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'unfocus_node.dart';

part 'google_ml.dart';

class TextTranslate extends StatefulWidget {
  const TextTranslate({super.key});

  @override
  State<TextTranslate> createState() => _TextTranslateState();
}

class _TextTranslateState extends State<TextTranslate> {
  final textToTranslate = TextEditingController();
  final translatedTextField = TextEditingController();

  final languageMenu = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    textToTranslate.dispose();
    translatedTextField.dispose();

    languageMenu.dispose();

    translator.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isDownloading) const Text('Downloading model...'),
              Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 20.0,
                  ),
                  child: FilledButton(
                    onPressed: () {
                      translate(textToTranslate.text).then(
                          (output) => {translatedTextField.text = output});
                    },
                    child: const Text('Translate with Google'),
                  )),
            ],
          ),

          // Text Field: Text to Translate
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 20.0,
            ),
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
          Row(
            children: [
              // Source Language DropdownMenu
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                child: DropdownMenu<String>(
                  initialSelection: source.bcpCode,
                  requestFocusOnTap: true,
                  label: const Text('Source Language'),
                  menuHeight: 200,
                  width: 150,
                  onSelected: (String? code) {
                    if (code != null) {
                      final lang = BCP47Code.fromRawValue(code);
                      if (lang != null) {
                        setState(() {
                          source = lang;
                          translator = OnDeviceTranslator(
                            sourceLanguage: source,
                            targetLanguage: target,
                          );
                        });

                        debugPrint(
                            '|- Current Languages: ${source.name} -> ${target.name}');
                      }
                    }
                  },
                  dropdownMenuEntries: TranslateLanguage.values
                      .map<DropdownMenuEntry<String>>((lang) {
                    return DropdownMenuEntry<String>(
                      value: lang.bcpCode,
                      label: capitalize(lang.name),
                      // label: lang.name,
                    );
                  }).toList(),
                ),
              ),

              const Spacer(),

              const Icon(Icons.arrow_forward),

              const Spacer(),

              // Target Language DropdownMenu
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 20.0,
                ),
                child: DropdownMenu<String>(
                  initialSelection: target.bcpCode,
                  requestFocusOnTap: true,
                  label: const Text('Target Language'),
                  menuHeight: 200,
                  width: 150,
                  onSelected: (String? code) {
                    if (code != null) {
                      final lang = BCP47Code.fromRawValue(code);
                      if (lang != null) {
                        setState(() {
                          target = lang;
                          translator = OnDeviceTranslator(
                            sourceLanguage: source,
                            targetLanguage: target,
                          );
                        });

                        debugPrint(
                            '|- Current Languages: ${source.name} -> ${target.name}');
                      }
                    }
                  },
                  dropdownMenuEntries: TranslateLanguage.values
                      .map<DropdownMenuEntry<String>>((lang) {
                    return DropdownMenuEntry<String>(
                      value: lang.bcpCode,
                      label: capitalize(lang.name),
                      // label: lang.name,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          // Text Field: Google Output Text
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 20.0,
            ),
            child: TextField(
                controller: translatedTextField,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                // enableInteractiveSelection: false,
                // focusNode: UnfocusNode(),
                readOnly: true,
                decoration: const InputDecoration(
                  label: Text('Translated Text'),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  hintText: 'Translated text outputs here...',
                  filled: true,
                )),
          ),

          // Picture with Google branding because legal stuff :(
          Row(
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, bottom: 20.0),
                child: Image(
                  image: isDarkMode
                      ? const AssetImage('assets/images/white-regular.png')
                      : const AssetImage('assets/images/color-regular.png'),
                  filterQuality: FilterQuality.high,
                ),
              ),
            ],
          )
        ],
      )),
    );
  }
}

String capitalize(String word) {
  String firstHalf = word[0].toUpperCase();
  String secondHalf = word.substring(1);

  String capWord = firstHalf + secondHalf;

  return capWord;
}
