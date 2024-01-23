import 'dart:io';
import 'dart:typed_data';

import '../server_models/player.dart';

int clone = 1;
Future<void> main() async {
  final ip = InternetAddress.anyIPv4;
  final server = await ServerSocket.bind(ip, 3000);
  print("Server is running on: ${ip.address}:3000");

  server.listen((Socket client) {
    handleConnection(client);
  });
}

List<Player> players = [];

void handleConnection(Socket client) {
  print("Connection from ${client.remoteAddress.address}:${client.remotePort}");

  client.listen(
    (Uint8List data) async {
      String message = String.fromCharCodes(data).trim();

      List<String> decript = message.split(";");
      print(message);
      int index = 0;
      for (int i = 0; i < decript.length; i++) {
        if (decript[i] == "end" && i + 2 != decript.length) {
          index = i;
        }
      }

      message = "";
      for (int i = index; i < decript.length - 1; i++) {
        message += decript[i] + ";";
      }

      print("Received message: $message");

      if (message.startsWith("join;")) {
        var username = message.split(";")[1];
        print("User $username joined");

        for (int i = 0; i < players.length; i++) {
          if (players[i].username == username) {
            username = "$username$clone";
            clone++;
          }
        }

        var player = Player(socket: client, username: username);
        players.add(player);
        await sendMessageToPlayer(username, "access;end;");

        if (players.length % 2 == 0) {
          players[players.length - 1].enemy =
              players[players.length - 2].username;
          players[players.length - 2].enemy =
              players[players.length - 1].username;

          await sendMessageToPlayer(players[players.length - 1].username,
              "enemy;${players[players.length - 1].enemy};end;");
          await sendMessageToPlayer(players[players.length - 2].username,
              "enemy;${players[players.length - 2].enemy};end;");
        }
      } else if (message.startsWith("stm;")) {
        String camp = "";
        for (int i = 0; i < players.length; i++) {
          if (players[i].username == message.split(";")[1]) {
            camp = players[i].printGrid();
          }
        }
        sendMessageToPlayer(message.split(";")[1], "table;$camp;end;");
      } else if (message.startsWith("put;")) {
        try {
          String camp = "";
          for (int i = 0; i < players.length; i++) {
            if (players[i].username == message.split(";")[1]) {
              players[i].placeShip(
                  int.parse(message.split(";")[2]),
                  int.parse(message.split(";")[3]),
                  int.parse(message.split(";")[4]),
                  message.split(";")[5]);
              camp = players[i].printGrid();
            }
          }

          sendMessageToPlayer(message.split(";")[1], "table;$camp;end;");
        } catch (e) {
          print("client ha inserito un dato sbagliato");
          sendMessageToPlayer(message.split(";")[1], "ok");
        }
      } else if (message.startsWith("ready;")) {
        for (int i = 0; i < players.length; i++) {
          if (players[i].username == message.split(";")[1]) {
            players[i].isReady = true;
            for (int e = 0; e < players.length; e++) {
              if (players[e].username == players[i].enemy) {
                if (players[e].isReady) {
                  sendMessageToPlayer(message.split(";")[1], "fight;end;");
                  sendMessageToPlayer(players[e].username, "fight;end;");
                  sendMessageToPlayer(players[e].username,
                      "turn;${players[e].printEnemyGrid()};end;");
                } else {
                  sendMessageToPlayer(message.split(";")[1],
                      "player ${players[i].enemy} is not ready");
                }
              }
            }
          }
        }
      } else if (message.startsWith("turn;")) {
        String camp = "";
        int en = 0;
        for (int i = 0; i < players.length; i++) {
          if (players[i].username == message.split(";")[1]) {
            camp += players[i].printGrid();
            for (int e = 0; e < players.length; e++) {
              if (players[e].username == players[i].enemy) {
                en = e;
                players[i].updateTable(
                    int.parse(message.split(";")[2]),
                    int.parse(message.split(";")[3]),
                    players[e].shoot(int.parse(message.split(";")[2]),
                        int.parse(message.split(";")[3])));
              }
            }
          }
        }

        if (players[en].victory()) {
          sendMessageToPlayer(players[en].username, "loser;end;");
          sendMessageToPlayer(message.split(";")[1], "winner;end;");
        } else {
          sendMessageToPlayer(players[en].username,
              "turn;${players[en].printEnemyGrid()};end;");
          sendMessageToPlayer(message.split(";")[1], "table;$camp;end;");
        }
      } else if (message.startsWith("err;")) {
        sendMessageToPlayer(message.split(";")[1], "error;end;");
      }
    },
    onError: (error) {
      print(error);
      client.close();
      players.removeWhere((element) => element.socket == client);
    },
    onDone: () {
      print('Client left');
      client.close();
      players.removeWhere((element) => element.socket == client);
    },
  );
}

Future<void> sendMessageToPlayer(String username, String message) async {
  for (int i = 0; i < players.length; i++) {
    if (players[i].username == username) {
      players[i].socket.write(message);
      await Future.delayed(Duration(milliseconds: 250));
    }
  }
}
