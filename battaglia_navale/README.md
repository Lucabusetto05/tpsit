# Progetto Battaglia Navale

## Panoramica
Il nostro progetto implementa una versione della Battaglia Navale in Dart, con una parte server e client. Consente ai giocatori di unirsi, posizionare le navi e sfidarsi a vicenda.

## Caratteristiche Principali
- **Server:** Gestisce connessioni multiple, sessioni di gioco e comunicazione tra giocatori.
- **Client:** Rappresenta un giocatore, consentendo operazioni come unirsi e attaccare.

## Struttura del Progetto
- **Client.dart:** Implementa il client per l'interazione del giocatore.
- **Server.dart:** Gestisce il server, ascoltando connessioni e coordinando il gioco.
- **Player.dart:** Definisce la classe Player per le funzionalità del giocatore.

## Come Eseguire
1. **Avviare il Server:**
    - Esegui `Server.dart` per avviare il server sulla porta 3000.

2. **Eseguire i Client:**
    - Esegui `Client.dart` per simulare giocatori che si connettono al server.

## Regole del Gioco
- Ogni giocatore ha una griglia 10x10.
- Posiziona le navi e attacca a turno.
- Il gioco continua fino a quando una flotta è affondata.