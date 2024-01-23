import 'dart:io';
import 'dart:typed_data';




bool start = false;
bool attac = false;
bool sent = false;
bool fight = false;

String? username;
String? enemy;
String serverResponse = "";
List<int> ship = [2, 2, 1, 1];
Future<void> main() async {
  final socket = await Socket.connect("172.20.10.4", 3000);
  print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

  socket.listen(
    (Uint8List data) {
      String message = String.fromCharCodes(data);
      List<String> decript = message.split(";");
      int index = 0;
      for(int i = 0; i < decript.length;i++){
          if(decript[i] == "end" && i + 2 != decript.length){
            index = i;
          }
      }

      message = "";
      for(int i = index; i < decript.length -1; i++){

         message+=decript[i]+";";
      }


      serverResponse = message;
      if(serverResponse.split(";")[0] == "access"){

      }

      if(serverResponse.split(";")[0] == "table"){
          print(serverResponse.split(";")[1]);
      }


      if(serverResponse.split(";")[0] == "enemy"){
        enemy = serverResponse.split(";")[1];
        print("my enemy $enemy");
        start = true;
        print("posiziona: \n -2 navi lunghe 1 \n -2 navi lunghe 2");

      }


      try{
        if(start && !attac){

          print("posiziona una nave: \n formato: lunghezza nave; x; y; V/O (verticale o orrizzontale)");
          String? comand;

          comand = stdin.readLineSync();

          if(ship[int.parse(comand!.split(";")[0])-1] > 0 && int.parse(comand.split(";")[0]) < 5){
            sendToServer(socket, "put;$username;$comand;end;");
            ship[int.parse(comand.split(";")[0])-1] = ship[int.parse(comand.split(";")[0])-1] - 1;
          } else {
            print("nave troppo lunga o hai finito il massimo di navi inseribili per ${comand.split(";")[0]}");
            sendToServer(socket, "err;$username;end;");
          }

          for(int i = 0; i < ship.length; i++){
            if(ship[i] == 0){
                attac = true;
                start = false;
            } else{
                start = true;
                attac = false;
              break;
            }
          }
        } 


        if(!start && attac){
          if(!sent){
            sendToServer(socket, "ready;$username;end;");
            sent = true;
          }
          if(serverResponse.split(";")[0] == "fight"){
            fight = true;
            attac = false;
            start = false;
          }
        }

        if(!start && !attac && fight){
          print("la fase di battaglia ha inizio!");
          if(serverResponse.split(";")[0] == "turn"){
            print("nemico:\n${serverResponse.split(";")[1]}");
            print("scrivi le coordinate y; x a cui vuoi tirare il colpo");
            String? comand;
            comand = stdin.readLineSync();
            sendToServer(socket, "turn;$username;$comand;end;");
          } else if(serverResponse.split(";")[0] == "winner"){
            print("HAI VINTO!");
            fight = false;
          } else if(serverResponse.split(";")[0] == "loser"){
            print("hai perso :(");
            fight = false;
          } 
        }
      }
      catch(e){
        print("hai inserito un dato sbagliato");
        sendToServer(socket, "err;$username;end;");
      }

    },
    // handle errors
    onError: (error) {
      print(error);
      socket.destroy();
    },

    // handle server ending connection
    onDone: () {
      print('Server left.');
      socket.destroy();
    },
  );

// Ask user for its username


  do {
    print("Please enter your username");
    username = stdin.readLineSync();
  } while (username == null);
  sendToServer(socket, "join;$username;end;");


}

Future<void> sendToServer(Socket socket, String message) async {

      socket.write(message+"\r");

}
