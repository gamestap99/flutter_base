import 'package:example/screens/list_cupertino_fetch_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'iOSDemo',
      theme: CupertinoThemeData(
          primaryColor: Colors.black,
          scaffoldBackgroundColor: CupertinoColors.tertiarySystemGroupedBackground,
          barBackgroundColor: Colors.white,
         ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  @override
  Widget build(BuildContext context) {
    List<Map<String,dynamic>> items = [
      {
        "title": "List Cupertino fetch data",
        'func': ( ) => Navigator.push(context, CupertinoPageRoute(builder: (context){
          return const ListCupertinoFetchData();
        })),
      }
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: ListView(
        children: items.map((e) => Card(
          child: ListTile(
            onTap: e['func'],
            title: Text(e['title']),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ),).toList(),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
