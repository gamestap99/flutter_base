import 'package:flutter/cupertino.dart';
import 'package:flutter_base/flutter_base.dart';

class CupertinoRangeDateScreen extends StatefulWidget {
  const CupertinoRangeDateScreen({super.key});

  @override
  State<CupertinoRangeDateScreen> createState() => _CupertinoRangeDateScreenState();
}

class _CupertinoRangeDateScreenState extends State<CupertinoRangeDateScreen> {
  @override
  Widget build(BuildContext context) {
    return  CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Cupertino Range Date'),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CupertinoRangeDateWidget(
            maxDate: DateTime.now(),
            actionBottom: (DateTime? start, DateTime? end) {
              return CupertinoButton(
                onPressed: (){
                  print("start:${start.toString()}");
                  print("end:${end.toString()}");
                },
                child: Text("Oke"),
              );
            },
          ),
        ),
      ),
    );
  }
}
