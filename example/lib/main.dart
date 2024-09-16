import 'package:example/screens/cupertino_card_screen.dart';
import 'package:example/screens/cupertino_range_date_widget.dart';
import 'package:example/screens/list_cupertino_fetch_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(platform: TargetPlatform.iOS),
      darkTheme: ThemeData.dark().copyWith(platform: TargetPlatform.iOS),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        SfGlobalLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('en', 'US'), Locale('ar', 'AE'),Locale('vi')],
      locale: const Locale('vi'),
      builder: (context, Widget? child) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Theme.of(context).brightness,
          scaffoldBackgroundColor: CupertinoColors.secondarySystemBackground,
        ),
        child: child!,
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
      },
      {
        "title": "Cupertino Range Date",
        'func': ( ) => Navigator.push(context, CupertinoPageRoute(builder: (context){
          return const CupertinoRangeDateScreen();
        })),
      },
      {
        "title": "Cupertino Card Screen",
        'func': ( ) => Navigator.push(context, CupertinoPageRoute(builder: (context){
          return const CupertinoCardScreen();
        })),
      },
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
