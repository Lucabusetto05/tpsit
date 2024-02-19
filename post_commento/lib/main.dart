import 'package:flutter/material.dart';
import 'package:post_db/database.dart';
import 'package:post_db/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorMyAppDatabase.databaseBuilder('app_database.db').build();
  runApp(MyApp(database));
}

class MyApp extends StatelessWidget {
  final MyAppDatabase database;

  MyApp(this.database);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APP',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('APP'),
        ),
        body: PostAndCommentsWidget(database: database),
      ),
    );
  }
}