# post_db

Un progetto Flutter per la gestione di post e commenti.

## Funzionalità del progetto

Questa iniziativa Flutter sviluppa un'app per l'organizzazione di post e commenti con le seguenti capacità:

- Esposizione di un catalogo di post.
- Inserimento di un post inedito.
- Rimozione di un post preesistente.
- Esame dei commenti collegati a un post.
- Creazione di un commento su un post.
- Distruzione di un commento già presente.

## Struttura del codice

La struttura del codice si articola in diversi documenti:

- `lib/main.dart`: Rappresenta l'ingresso principale dell'app. Racchiude il codice per l'avvio dell'app e il widget di base.
- `lib/database.dart`: Questo documento dettaglia la struttura del database per l'archiviazione di post e commenti.
- `lib/model.dart`:  Definisce i modelli per i dati relativi a post e commenti.
- `lib/dao.dart`: Illustra i Data Access Object (DAO) per la manipolazione di post e commenti.
- `lib/widgets.dart`: Alloggia i widget per la visualizzazione e l'interazione con post e commenti.

Procedendo con l'analisi del documento `lib/widgets.dart`, notiamo che il widget `PostAndCommentsWidget` è un `StatefulWidget` che regola lo stato di post e commenti, offrendo funzioni per la loro aggiunta, cancellazione e caricamento.

```dart
class PostAndCommentsWidget extends StatefulWidget {...}
class _PostAndCommentsWidgetState extends State<PostAndCommentsWidget> {...}
```

Nella funzione `initState`, invochiamo `_loadData` per ottenere i post dal database all'inizio dell'attivazione del widget.

```dart
@override
void initState() {
  super.initState();
  _loadData();
}
```

La funzione `_loadData` si occupa di estrarre i post dal database e di aggiornare lo stato dell'app con i dati acquisiti.
```dart
Future<void> _loadData() async {...}
```

La funzione `_addPost` accoglie un titolo, genera un post nuovo con questo titolo, lo registra nel database e successivamente aggiorna l'elenco dei post.

dart


```dart
Future<void> _addPost(String title) async {...}
```

La funzione `_loadCommentsForPost` richiede un ID di post e raccoglie tutti i commenti relativi da database. Se l'ID del post in esame corrisponde all'ID fornito, la lista dei commenti viene azzerata; altrimenti, i commenti del post specificato vengono caricati.

```dart
Future<void> _loadCommentsForPost(int postId) async {...}
```

La funzione `_addCommentToPost` riceve un ID di post e un testo, crea un commento nuovo con tale contenuto per il dato post, lo inserisce nel database e poi aggiorna l'elenco dei commenti per tale post.

```dart
Future<void> _addCommentToPost(int postId, String content) async {...}
```

La funzione `_deletePost` utilizza un ID di post per eliminare tutti i suoi commenti e poi il post stesso dal database. Infine, rinfresca l'elenco dei post e carica i commenti per il primo post elencato.

```dart
Future<void> _deletePost(int postId) async {...}
```

La funzione `_deleteComment` si avvale di un ID di commento per rimuovere il commento specificato dal database e poi aggiorna i commenti per il post in questione.

```dart
Future<void> _deleteComment(int commentId) async {...}
```

In conclusione, la funzione `build` offre un widget `Scaffold` che presenta un catalogo di post, un'area di testo e un bottone per l'aggiunta di un post nuovo. Ogni post elencato dispone di un menu contestuale per la sua eliminazione o per l'aggiunta di un commento. Analogamente, ogni commento presenta un menu per la sua rimozione.

```dart
@override
Widget build(BuildContext context) {...}
```

Ciò completa la revisione del documento `lib/widgets.dart`, preservando l'intento originale in formato readme.