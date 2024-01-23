import 'dart:io';

class Player {
  late Socket socket;
  late String username;
  bool isReady = false;
  String? enemy;

  List<List<String>>? myGrid =  List.generate(10, (index) => List.generate(10, (index) => ' '));
  List<List<String>>? enemyGrid =  List.generate(10, (index) => List.generate(10, (index) => ' '));



  Player({required this.socket, required this.username});

  String printGrid(){
    String returnable ="| |0|1|2|3|4|5|6|7|8|9|\n";
      for (int i = 0; i < myGrid!.length; i++) {
        returnable+='|$i';
        for (int j = 0; j < myGrid![i].length; j++) {
          returnable+=('|${myGrid![i][j]}');
        }

      returnable+=('|\n');
    }
    return returnable;
  }

  void placeShip(int length, int x, int y, String orientation) {
  // Verifica che la nave sia completamente all'interno della tabella
  orientation = orientation.toUpperCase();
    if (orientation == 'V' && x + length <= myGrid!.length) {
      for (int i = 0; i < length; i++) {
        myGrid![x + i][y] = 'S';
      }
    } else if (orientation == 'O' && y + length <= myGrid![0].length) {
      for (int i = 0; i < length; i++) {
        myGrid![x][y + i] = 'S';
      }
    } else {
      print('Posizione non valida per la nave di lunghezza $length.');
    }
  }

  String shoot(int x, int y){
    if(myGrid![x][y] == 'S'){
      myGrid![x][y] = 'C';
      return "C";
    }
    myGrid![x][y] = 'M';
    return "M";
  }

  void updateTable(int x, int y, String update){
    enemyGrid![x][y] = update; 
  }

  String printEnemyGrid(){
    String returnable ="| |0|1|2|3|4|5|6|7|8|9|\n";
    for (int i = 0; i < enemyGrid!.length; i++) {
        returnable+='|$i';
        for (int j = 0; j < enemyGrid![i].length; j++) {
          returnable+=('|${enemyGrid![i][j]}');
        }
      returnable+=('|\n');
    }
    return returnable;
  }

  bool victory(){
    for (int i = 0; i < myGrid!.length; i++) {

        for (int j = 0; j < myGrid![i].length; j++) {
            if(myGrid![i][j] == 'S'){
              return false;
            }
        }

    }
    return true;
  }
}