import 'package:floor/floor.dart';
import 'package:post_db/model.dart';

@dao
abstract class PostDao {
  @Query('SELECT * FROM post')
  Future<List<Post>> findAllPosts();

  @insert
  Future<void> insertPost(Post post);

  @Query('DELETE FROM Post WHERE id = :id')
  Future<void> deletePostById(int id);

  @Query('SELECT * FROM Post WHERE title = :title LIMIT 1')
  Future<Post?> findPostByTitle(String title);
}

@dao
abstract class CommentDao {
  @Query('SELECT * FROM comment WHERE postId = :postId')
  Future<List<Comment>> findCommentsForPost(int postId);

  @insert
  Future<void> insertComment(Comment comment);

  @Query('DELETE FROM Comment WHERE postId = :postId')
  Future<void> deleteCommentsByPostId(int postId);

}