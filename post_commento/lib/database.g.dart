part of 'database.dart';

// Classe helper per costruire e configurare il database.
class $FloorMyAppDatabase {
  // Metodo per creare il builder del database persistente.
  static _$MyAppDatabaseBuilder databaseBuilder(String name) =>
      _$MyAppDatabaseBuilder(name);

  // Metodo per creare il builder del database in memoria.
  // I dati in un database in memoria vengono persi quando il processo termina.
  static _$MyAppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$MyAppDatabaseBuilder(null);
}

// Builder del database che consente di configurare il database prima della creazione.
class _$MyAppDatabaseBuilder {
  _$MyAppDatabaseBuilder(this.name);

  final String? name;
  final List<Migration> _migrations = [];
  Callback? _callback;

  // Aggiunge le migrazioni al builder.
  _$MyAppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  // Aggiunge un Callback al builder per gestire eventi come onCreate, onUpgrade, ecc.
  _$MyAppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  // Costruisce il database e lo inizializza.
  Future<MyAppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$MyAppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

// Implementazione concreta del database MyAppDatabase.
class _$MyAppDatabase extends MyAppDatabase {
  _$MyAppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  // Istanze dei DAO.
  PostDao? _postDaoInstance;
  CommentDao? _commentDaoInstance;

  // Apre il database e applica le configurazioni necessarie.
  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);
        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `post` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `comment` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `content` TEXT NOT NULL, `postId` INTEGER NOT NULL, FOREIGN KEY (`postId`) REFERENCES `post` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  // Getter per accedere ai DAO.
  @override
  PostDao get postDao {
    return _postDaoInstance ??= _$PostDao(database, changeListener);
  }

  @override
  CommentDao get commentDao {
    return _commentDaoInstance ??= _$CommentDao(database, changeListener);
  }
}

// Implementazione del PostDao.
class _$PostDao extends PostDao {
  _$PostDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _postInsertionAdapter = InsertionAdapter(
            database,
            'post',
            (Post item) =>
                <String, Object?>{'id': item.id, 'title': item.title});

  final sqflite.DatabaseExecutor database;
  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;
  final InsertionAdapter<Post> _postInsertionAdapter;

  // Metodi per operazioni CRUD sui post.
  @override
  Future<List<Post>> findAllPosts() async {
    return _queryAdapter.queryList('SELECT * FROM post',
        mapper: (Map<String, Object?> row) =>
            Post(row['id'] as int?, row['title'] as String));
  }

  @override
  Future<void> deletePostById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM Post WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<Post?> findPostByTitle(String title) async {
    return _queryAdapter.query('SELECT * FROM Post WHERE title = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) =>
            Post(row['id'] as int?, row['title'] as String),
        arguments: [title]);
  }

  @override
  Future<void> insertPost(Post post) async {
    await _postInsertionAdapter.insert(post, OnConflictStrategy.abort);
  }
}

// Implementazione del CommentDao.
class _$CommentDao extends CommentDao {
  _$CommentDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _commentInsertionAdapter = InsertionAdapter(
            database,
            'comment',
            (Comment item) => <String, Object?>{
                  'id': item.id,
                  'content': item.content,
                  'postId': item.postId
                });

  final sqflite.DatabaseExecutor database;
  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;
  final InsertionAdapter<Comment> _commentInsertionAdapter;

  // Metodi per operazioni CRUD sui commenti.
  @override
  Future<List<Comment>> findCommentsForPost(int postId) async {
    return _queryAdapter.queryList('SELECT * FROM comment WHERE postId = ?1',
        mapper: (Map<String, Object?> row) => Comment(
            row['id'] as int?, row['content'] as String, row['postId'] as int),
        arguments: [postId]);
  }

  @override
  Future<void> deleteCommentsByPostId(int postId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM Comment WHERE postId = ?1',
        arguments: [postId]);
  }

  @override
  Future<void> insertComment(Comment comment) async {
    await _commentInsertionAdapter.insert(comment, OnConflictStrategy.abort);
  }
}
