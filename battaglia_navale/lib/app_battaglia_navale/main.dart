import 'dart:async';

import 'package:battaglia_navalee/client/client.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naviation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FirstPage(title: 'Login'),
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  TextEditingController _textFieldController = TextEditingController();
  String userInput = '';
  Client client = new Client();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _ipController = TextEditingController();
    final TextEditingController _portController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _ipController,
              decoration:
                  const InputDecoration(labelText: 'Inserisci l\'indirizzo IP'),
            ),
            TextField(
              controller: _portController,
              decoration:
                  const InputDecoration(labelText: 'Inserisci la porta'),
              keyboardType:
                  TextInputType.number, // Assicura che l'input sia numerico.
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textFieldController,
              decoration:
                  const InputDecoration(labelText: 'Inserisci il tuo username'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                String ip = _ipController.text;
                int port = int.tryParse(_portController.text) ??
                    0; // Se l'input non è un numero valido, impostiamo la porta a 0.
                String username = _textFieldController.text;

                await client.initializeSocket(ip, port);
                client.login(
                    username); // Supponendo che il tuo metodo di login accetti tre argomenti: username, IP e porta.

                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SecondPage(title: 'Battaglia Navale', client: client);
                }));
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({super.key, required this.title, required this.client});
  final String title;
  final Client client;
  @override
  _SecondPageState createState() => _SecondPageState(client);
}

class _SecondPageState extends State<SecondPage> {
  final Client client;
  String lastServer = "";
  Timer? _timer; // Aggiungi una variabile per il Timer
  bool en = false;

  void updateTable(String table) {
    setState(() {
      // Qui puoi modificare cellValues come desiderato
      // Ad esempio, qui modifichiamo una cella casuale ogni 100 millisecondi
      print("lunghezza table: ${table.split("\n").length} \ntable\n$table");

      for (int y = 0; y < table.split("\n").length - 1; y++) {
        for (int x = 1; x < table.split("\n")[y].split("|").length - 1; x++) {
          cellValues[y][x - 1] = table.split("\n")[y].split("|")[x];
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Inizializza il Timer
    _timer = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      if (lastServer != client.serverResponse) {
        print("server dice: \n" + client.serverResponse);
        lastServer = client.serverResponse;
      }
      if (client.serverResponse.startsWith("table;") ||
          client.serverResponse.startsWith("turn;")) {
        updateTable(client.serverResponse.split(";")[1]);
      }

      if (client.serverResponse.startsWith("winner;")) {
        _showWinnerDialog();
      }
    });
  }

  void _showWinnerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Congratulazioni"),
          content: Text("Hai Vinto!"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Chiude il dialog
              },
            ),
          ],
        );
      },
    );
  }

  List<List<String?>> cellValues = List.generate(
    11,
    (rowIndex) => List.generate(11, (colIndex) => null),
  );

  String? selectedString;
  String? selectedNum;

  _SecondPageState(this.client);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Table(
            children: List.generate(11, (rowIndex) {
              return TableRow(
                children: List.generate(11, (colIndex) {
                  // Assegna un colore diverso in base al valore della cella
                  Color cellColor;
                  switch (cellValues[rowIndex][colIndex]) {
                    case ' ':
                      cellColor = Colors.lightBlue;
                      break;
                    case 'S':
                      cellColor = Colors.grey;
                      break;
                    case 'M':
                      cellColor = Colors.blue[800]!;
                      break;
                    case 'C':
                      cellColor = Colors.red;
                      break;
                    default:
                      cellColor = Colors.transparent;
                  }

                  return TableCell(
                    child: InkWell(
                      onTap: client.enemy != null ||
                              (!client.start && !client.attac && client.fight)
                          ? () {
                              setState(() {
                                if ((!client.start &&
                                    !client.attac &&
                                    client.fight)) {
                                  if (rowIndex > 0 && colIndex > 0) {
                                    client.bomb((rowIndex - 1).toString(),
                                        (colIndex - 1).toString());
                                  }
                                } else {
                                  if ((selectedString != null &&
                                          selectedNum != null) &&
                                      (client.start && !client.attac) &&
                                      (rowIndex > 0 && colIndex > 0)) {
                                    client.putShip(
                                        selectedNum!,
                                        (rowIndex - 1).toString(),
                                        (colIndex - 1).toString(),
                                        selectedString!);
                                  }
                                }
                              });
                            }
                          : null,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: cellColor, // Imposta il colore della cella qui
                          border: Border.all(),
                        ),
                        alignment: Alignment.center,
                        child: Text(cellValues[rowIndex][colIndex] ?? ""),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
          SizedBox(height: 20),
          // Pulsanti "1", "2", "3", "4", "O" e "V"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedNum = "1";
                  });
                },
                child: Text("1"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedNum = "2";
                  });
                },
                child: Text("2"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedNum = "3";
                  });
                },
                child: Text("3"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedNum = "4";
                  });
                },
                child: Text("4"),
              ),
              
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedString = "O";
                  });
                },
                child: Text("O"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedString = "V";
                  });
                },
                child: Text("V"),
              ),
          ],
          ),
          SizedBox(height: 20),
          // Visualizza il valore selezionato
          Text(
            selectedString != null
                ? "Valore stringa selezionato: $selectedString + $selectedNum"
                : "Nessun valore selezionato",
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
