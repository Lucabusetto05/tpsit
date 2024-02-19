import 'package:floor/floor.dart';

@Entity(tableName: 'post')
class Post {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String title;

  Post(this.id, this.title);
}

@Entity(
  tableName: 'comment',
  foreignKeys: [
    ForeignKey(
      childColumns: ['postId'],
      parentColumns: ['id'],
      entity: Post,
    ),
  ],
)
class Comment {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String content;

  final int postId;

  Comment(this.id, this.content, this.postId);
}