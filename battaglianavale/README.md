# Server del Gioco della Battaglia Navale

## Panoramica

Questo programma Dart funge da server di backend per un gioco della Battaglia Navale. Utilizza la libreria `dart:io` di Dart per gestire le connessioni socket e la comunicazione con i giocatori. Il gioco segue una struttura a turni, in cui i giocatori si uniscono, posizionano le loro navi e si alternano nel lanciare colpi alle griglie degli avversari fino a quando un giocatore emerge vittorioso.

## Struttura dei File

- **main.dart**: Punto di ingresso principale dell'applicazione del server. Si collega a un indirizzo IP e una porta specifici, resta in ascolto per le connessioni socket in arrivo e delega la gestione alla funzione `handleConnection`.
  
- **player.dart**: Contiene la definizione della classe `Player`, che rappresenta un giocatore nel gioco. Ogni giocatore ha un nome utente unico, una connessione socket e attributi correlati al gioco, come configurazioni della griglia e prontezza.

## Funzionalità

### Inizializzazione del Server

Il server si inizializza collegandosi a un indirizzo IP specifico (`172.20.10.4`) e a una porta (`3000`). Stampa un messaggio che indica che il server è in esecuzione.

### Gestione della Connessione dei Giocatori

Quando un giocatore si connette, il server stampa l'indirizzo remoto e la porta del client. Poi ascolta i dati in arrivo dal giocatore.

### Elaborazione dei Messaggi

Il server elabora i messaggi in arrivo in base a comandi predefiniti. I comandi significativi includono:
- `join`: Gestisce l'ingresso di un giocatore, assegna un nome utente unico e notifica al giocatore l'accesso riuscito.
- `stm`: Recupera e invia la griglia di gioco del giocatore al giocatore richiedente.
- `put`: Posiziona una nave sulla griglia del giocatore e aggiorna lo stato di gioco.
- `ready`: Indica che un giocatore è pronto per iniziare il gioco; controlla se entrambi i giocatori sono pronti per avviare la fase di battaglia.
- `turn`: Elabora il turno di un giocatore, aggiorna lo stato di gioco e verifica la presenza di un vincitore.

### Comunicazione con i Giocatori

Il server comunica con i giocatori inviando messaggi attraverso le loro connessioni socket. I messaggi sono formattati con comandi e parametri specifici, e ogni messaggio è terminato con la parola chiave `end`.

### Gestione degli Errori

Il server gestisce gli errori durante la comunicazione, chiude la connessione socket del client e rimuove il giocatore dalla lista dei giocatori attivi.

# Applicazione Client per il Gioco della Battaglia Navale

## Panoramica

Questa applicazione client è scritta in Dart utilizzando il framework Flutter. Il client si connette a un server di gioco della Battaglia Navale attraverso socket e offre un'interfaccia grafica per l'utente. Il gioco segue una struttura a turni, consentendo ai giocatori di effettuare il login, posizionare le proprie navi e partecipare a scontri contro avversari.

## Struttura dei File

- **main.dart**: Punto di ingresso principale dell'applicazione client. Avvia l'app Flutter e inizia con la visualizzazione di una schermata di login.
  
- **client.dart**: Contiene la definizione della classe `Client`, che gestisce la connessione al server e la comunicazione con il server attraverso socket.

## Funzionalità

### Schermata di Login

La schermata di login consente all'utente di inserire un nome utente. Una volta inserito il nome utente, l'app si connette al server e passa alla schermata successiva.

### Schermata del Gioco

La schermata del gioco visualizza una griglia di gioco interattiva. Gli utenti possono posizionare le proprie navi toccando le celle della griglia. Durante il gioco, la griglia viene aggiornata con le mosse dell'avversario. Se un giocatore vince, viene visualizzata una finestra di dialogo di congratulazioni.

### Pulsanti di Azione

Sulla schermata del gioco, sono presenti pulsanti di azione per piazzare navi e eseguire attacchi. La selezione del numero e del tipo di nave avviene tramite pulsanti dedicati.

### Aggiornamenti Live

La schermata del gioco viene aggiornata in tempo reale con le risposte dal server. Le informazioni sulla griglia di gioco, i turni e il vincitore vengono visualizzate dinamicamente.

### Gestione degli Errori

L'app gestisce gli errori durante la comunicazione con il server e li notifica all'utente. In caso di vittoria, viene visualizzata una finestra di dialogo di congratulazioni.
