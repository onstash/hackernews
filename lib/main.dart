import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: RandomWords(),
      theme: ThemeData(
        primaryColor: Colors.purple,
      )
    );
  }
}

class RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  final Set<WordPair> _saved = new Set<WordPair>();
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Startup name generator"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.list), onPressed: _pushSaved
          )
        ]
      ),
      body: _buildSuggestions(),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(builder: (BuildContext context) {
        final Iterable<ListTile> tiles = _saved.map(
            (WordPair wordPair) {
              return ListTile(
                title: Text(
                  wordPair.asPascalCase,
                  style: _biggerFont
                )
              );
            }
        );
        final List<Widget> divided = ListTile.divideTiles(
          context: context,
          tiles: tiles
        ).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text("Saved suggestions")
          ),
          body: ListView(
            children: divided
          )
        );
      })
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      }
    );
  }

  Widget _buildRow(WordPair wordPair) {
    final bool alreadySaved = _saved.contains(wordPair);
    return ListTile(
      title: Text(
        wordPair.asPascalCase,
        style: _biggerFont
      ),
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(wordPair);
          } else {
            _saved.add(wordPair);
          }
        });
      }
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => new RandomWordsState();
}
