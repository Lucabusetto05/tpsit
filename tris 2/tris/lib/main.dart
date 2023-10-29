import 'package:flutter/material.dart';

void main() {
  runApp(TrisApp());
}

class TrisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TrisGame(),
    );
  }
}

class TrisGame extends StatefulWidget {
  @override
  _TrisGameState createState() => _TrisGameState();
}

class _TrisGameState extends State<TrisGame> {
  List<String> board = List.filled(9, ''); // Creiamo una lista di 9 elementi per rappresentare la scacchiera
  bool playerX = true; // Il giocatore X inizia

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tris'),
      ),
      backgroundColor: Colors.blue, // Impostiamo lo sfondo a blu
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Gestiamo il tocco su una casella della scacchiera
              if (board[index] == '') {
                setState(() {
                  // Aggiorniamo la scacchiera con il simbolo del giocatore corrente
                  board[index] = playerX ? 'X' : 'O';
                  if (checkForWinner()) {
                    showWinnerDialog(playerX ? 'X' : 'O');
                  } else if (!board.contains('')) {
                    showDrawDialog();
                  } else {
                    playerX = !playerX; // Cambiamo il turno al prossimo giocatore
                  }
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: Center(
                child: Text(
                  board[index],
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool checkForWinner() {
    // Implementiamo la logica per verificare se c'è un vincitore
    for (int i = 0; i < 3; i++) {
      // Controllo orizzontale
      if (board[i * 3] != '' &&
          board[i * 3] == board[i * 3 + 1] &&
          board[i * 3 + 1] == board[i * 3 + 2]) {
        return true;
      }
      // Controllo verticale
      if (board[i] != '' && board[i] == board[i + 3] && board[i + 3] == board[i + 6]) {
        return true;
      }
    }

    // Controllo diagonale da in alto a sinistra verso in basso a destra
    if (board[0] != '' && board[0] == board[4] && board[4] == board[8]) {
      return true;
    }

    // Controllo diagonale da in alto a destra verso in basso a sinistra
    if (board[2] != '' && board[2] == board[4] && board[4] == board[6]) {
      return true;
    }

    return false;
  }

  void showWinnerDialog(String winner) {
    // Mostra una finestra di dialogo con il vincitore
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vittoria di $winner'),
          actions: <Widget>[
            TextButton(
              child: Text('Nuova partita'),
              onPressed: () {
                // Inizia una nuova partita resettando la scacchiera
                setState(() {
                  board = List.filled(9, '');
                  playerX = true;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showDrawDialog() {
    // Mostra una finestra di dialogo per il pareggio
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pareggio!'),
          actions: <Widget>[
            TextButton(
              child: Text('Nuova partita'),
              onPressed: () {
                // Inizia una nuova partita resettando la scacchiera
                setState(() {
                  board = List.filled(9, '');
                  playerX = true;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}