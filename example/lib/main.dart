import 'package:example/controller/spell_checker_controller.dart';
import 'package:flutter/material.dart';
import 'package:simple_spell_checker/simple_spell_checker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Simple Spell Checker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final SpellCheckerController _controller;
  late final SpellCheckerController _titleController;
  bool isFirst = true;

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    if (isFirst) {
      isFirst = false;
      final language = Localizations.localeOf(context).languageCode;
      _controller = SpellCheckerController(
        spellchecker: SimpleSpellChecker(
          language: language,
        ),
        text:
            'Simple Spell Checker is a simple but powerful spell checker, that allows to all developers detect and highlight spelling errors in text. It Allows customization of languages, providing efficient and adaptable spell-checking for various applications.',
      );
      _titleController = SpellCheckerController(
        spellchecker: SimpleSpellChecker(
          language: language,
        ),
        text: 'What is Simple Spell Checker',
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _controller.spellchecker.toggleChecker();
              setState(() {});
            },
            icon: const Icon(
              Icons.document_scanner_sharp,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
                alignment: Alignment.center,
                width: size.width * 0.80,
                child: TextField(
                  controller: _titleController,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    disabledBorder: InputBorder.none,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Divider(
              height: 2,
              indent: size.width * 0.10,
              endIndent: size.width * 0.10,
              color: Colors.black,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: size.width * 0.10,
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                minLines: 10,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write something here',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
