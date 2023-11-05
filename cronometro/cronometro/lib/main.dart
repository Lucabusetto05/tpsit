import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MyCustomApp());
}

class MyCustomApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CustomTimerApp(),
    );
  }
}

class CustomTimerApp extends StatefulWidget {
  @override
  _CustomTimerAppState createState() => _CustomTimerAppState();
}

class _CustomTimerAppState extends State<CustomTimerApp> {
  late StreamController<int> _customTimerController;
  late StreamSubscription<int> _customTimerSubscription;
  int _elapsedTime = 0;
  bool _isTimerPaused = false;

  @override
  void initState() {
    super.initState();

    _customTimerController = StreamController<int>();
    _customTimerSubscription = _customTimerController.stream.listen((int elapsed) {
      if (!_isTimerPaused) {
        setState(() {
          _elapsedTime = elapsed;
        });
      }
    });

    startCustomTimer();
  }

  void startCustomTimer() {
    const oneSecond = Duration(seconds: 1);
    Timer.periodic(oneSecond, (Timer timer) {
      _customTimerController.add(_elapsedTime + 1);
    });
  }

  void pauseCustomTimer() {
    setState(() {
      _isTimerPaused = true;
    });
  }

  void resumeCustomTimer() {
    setState(() {
      _isTimerPaused = false;
    });
  }

  void resetCustomTimer() {
    setState(() {
      _elapsedTime = 0;
    });
  }

  @override
  void dispose() {
    _customTimerController.close();
    _customTimerSubscription.cancel();
    super.dispose();
  }

  String _formatElapsedTime(int timeInSeconds) {
    int hours = timeInSeconds ~/ 3600;
    int minutes = (timeInSeconds ~/ 60) % 60;
    int seconds = timeInSeconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cronometro'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tempo:',
              style: TextStyle(fontSize: 15),
            ),
            Text(
              _formatElapsedTime(_elapsedTime),
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isTimerPaused ? resumeCustomTimer : pauseCustomTimer,
                  child: Text(_isTimerPaused ? 'Riprendi' : 'Pausa'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: resetCustomTimer,
                  child: Text('Riavvia'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}