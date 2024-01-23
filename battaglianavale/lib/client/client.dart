import 'dart:async';
import 'dart:io';
import 'dart:typed_data';


class Client {
  bool start = false;
  bool attac = false;
  bool sent = false;
  bool fight = false;

  String? username;
  String? enemy;
  String serverResponse = "";
  List<int> ship = [2, 2, 1, 1];
  late Socket socket;

  Future<void> initializeSocket(String ip, int port) async {
    // Inizializzazione del socket
    socket = await Socket.connect("172.20.10.4", 3000);
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


          if(serverResponse.split(";")[0] == "enemy"){
            enemy = serverResponse.split(";")[1];
            print("my enemy $enemy");
            start = true;
            print("posiziona: \n -2 shiphe lunghe 1 \n -2 shiphe lunghe 2 \n -1 shipa lunga 3 \n -1 shipa lunga 4");
          }


        try{
        if(start && !attac){
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

              if(serverResponse.split(";")[0] == "winner"){
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
  }

  Future<void> login(String usernam) async {
    username = usernam;
    sendToServer(this.socket, "join;$username;end;");
  }

  Future<void> putShip(String len, String x, String y, String orientation) async {
    if(ship[int.parse(len)-1] > 0){
      ship[int.parse(len)-1] = ship[int.parse(len)-1] - 1;
      sendToServer(this.socket, "put;$username;$len;$x;$y;$orientation;end;");  
    } else {
      sendToServer(socket, "err;$username;end;");
    }

  }

  Future<void> bomb(String x, String y)async {
    if(serverResponse.split(";")[0] == "turn"){
      print("scrivi le coordinate x; y a cui vuoi tirare il colpo");
      sendToServer(socket, "turn;$username;$x;$y;end;");

    }
  }
  Future<void> sendToServer(Socket socket, String message) async {
      socket.write(message+"\r");
  }
}
