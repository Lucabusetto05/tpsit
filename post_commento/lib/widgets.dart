import 'package:flutter/material.dart';

import 'dao.dart';
import 'database.dart';
import 'model.dart';

// Definizione del widget StatefulWidget per la gestione di post e commenti.
class PostAndCommentsWidget extends StatefulWidget {
  final MyAppDatabase database;

  // Costruttore del widget che richiede un'istanza del database.
  const PostAndCommentsWidget({Key? key, required this.database}) : super(key: key);

  @override
  _PostAndCommentsWidgetState createState() => _PostAndCommentsWidgetState();
}

class _PostAndCommentsWidgetState extends State<PostAndCommentsWidget> {
  // Controller per la gestione del testo dei post e dei commenti.
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  // Liste per memorizzare i post e i commenti recuperati dal database.
  List<Post> _posts = [];
  List<Comment> _comments = [];

  // Variabile per tenere traccia del post selezionato.
  int? _selectedPostId;

  @override
  void initState() {
    super.initState();
    // Carica i dati dal database all'inizializzazione.
    _loadData();
  }

  // Funzione asincrona per il caricamento dei post dal database.
  Future<void> _loadData() async {
    final posts = await widget.database.postDao.findAllPosts();
    setState(() {
      _posts = posts;
    });
  }

  // Funzione asincrona per aggiungere un nuovo post al database.
  Future<void> _addPost(String title) async {
    final post = Post(null, title);
    await widget.database.postDao.insertPost(post);
    // Ricarica i dati dopo l'aggiunta di un post.
    await _loadData();
    // Carica i commenti per il nuovo post.
    if (post.id != null) {
      _loadCommentsForPost(post.id!);
    }
  }

  // Funzione asincrona per caricare i commenti di un determinato post.
  Future<void> _loadCommentsForPost(int postId) async {
    if (_selectedPostId == postId) {
      setState(() {
        _selectedPostId = null;
        _comments = [];
      });
    } else {
      final comments = await widget.database.commentDao.findCommentsForPost(postId);
      setState(() {
        _selectedPostId = postId;
        _comments = comments;
      });
    }
  }

  // Funzione asincrona per aggiungere un commento a un post.
  Future<void> _addCoommentToPst(int postId, String content) async {
    final comment = Comment(null, content, postId);
    await widget.database.commentDao.insertComment(comment);
    // Ricarica i commenti per il post dopo l'aggiunta.
    _loadCommentsForPost(postId);
  }

  // Funzione asincrona per eliminare un post e tutti i suoi commenti.
  Future<void> _deletePost(int postId) async {
    await widget.database.commentDao.deleteCommentsByPostId(postId);
    await widget.database.postDao.deletePostById(postId);
    // Ricarica i post dopo l'eliminazione.
    await _loadData();
    // Carica i commenti per il primo post disponibile.
    if (_posts.isNotEmpty) {
      _loadCommentsForPost(_posts.first.id!);
    }
  }

  // Funzione asincrona per eliminare un commento specifico.
  Future<void> _deleteComment(int commentId) async {
    await widget.database.commentDao.deleteCommentsByPostId(commentId);
    // Ricarica i commenti per il post corrente.
    if (_selectedPostId != null) {
      await _loadCommentsForPost(_selectedPostId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Sfondo scuro per l'applicazione.
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Lista scrollabile per mostrare i post e i relativi commenti.
          Expanded(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        post.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        // Carica i commenti quando un post viene selezionato.
                        _loadCommentsForPost(post.id!);
                      },
                      // Menu contestuale per ogni post.
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'Delete') {
                            _deletePost(post.id!);
                          } else if (value == 'Add') {
                            // Mostra il dialog per aggiungere un commento.
                            final content = await _showAddCommentDialog();
                            if (content != null) {
                              await _addCoommentToPst(post.id!, content);
                              _loadCommentsForPost(post.id!);
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'Delete',
                            child: Text('Delete Post'),
                          ),
                          PopupMenuItem(
                            value: 'Add',
                            child: Text('Add Comment'),
                          ),
                        ],
                      ),
                    ),
                    // Mostra i commenti relativi al post selezionato.
                    ..._comments.where((comment) => comment.postId == post.id).map((comment) {
                      return Padding(
                        padding: EdgeInsets.only(left: 30.0),
                        child: ListTile(
                          title: Text(
                            comment.content,
                            style: TextStyle(color: Colors.green),
                          ),
                          leading: Icon(Icons.comment, color: Colors.blue),
                          // Menu contestuale per ogni commento.
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'Delete') {
                                _deleteComment(comment.id!);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'Delete',
                                child: Text('Delete Comment'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
          // Area di input e bottone per aggiungere un nuovo post.
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _postController,
                  decoration: InputDecoration(
                    labelText: 'Write a post',
                    labelStyle: TextStyle(color: Colors.white), // Cambia il colore del testo dell'etichetta.
                    contentPadding: EdgeInsets.all(10.0),
                    fillColor: Colors.grey[800], // Cambia il colore di riempimento.
                    filled: true,
                  ),
                  style: TextStyle(color: Colors.white), // Cambia il colore del testo.
                ),
              ),
              FloatingActionButton(
                backgroundColor: Colors.blue, // Cambia il colore del bottone.
                onPressed: () {
                  // Aggiunge un nuovo post al database.
                  _addPost(_postController.text);
                  _postController.clear(); // Pulisce il campo di testo dopo l'invio.
                },
                child: Icon(Icons.add, color: Colors.white), // Cambia il colore dell'icona.
              ),
            ],
          ),
        ],
      ),
    );
  }

// Funzione per mostrare il dialog di inserimento di un nuovo commento.
Future<String?> _showAddCommentDialog() async {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add Comment'),
        content: TextField(
          controller: _commentController,
          decoration: InputDecoration(
            labelText: 'Write a comment',
            contentPadding: EdgeInsets.all(10.0),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Chiude il dialog senza salvare.
            },
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
              // Restituisce il testo del commento e pulisce il campo di testo.
              Navigator.of(context).pop(_commentController.text);
              _commentController.clear();
            },
          ),
        ],
      );
    },
  );
}
}
