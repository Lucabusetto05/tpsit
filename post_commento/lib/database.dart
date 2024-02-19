import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:post_db/dao.dart';
import 'package:post_db/model.dart';

part 'database.g.dart';

@Database(version: 1, entities: [Post, Comment])
abstract class MyAppDatabase extends FloorDatabase {
  PostDao get postDao;
  CommentDao get commentDao;
}