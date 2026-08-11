import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data/db_helper.dart';
import 'home_page.dart';

Future<void> main() async{
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    DbHelper db = DbHelper.getInstance;

    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );

  }

}
