import 'dart:async';
import 'package:fasyl/core/config/constants.dart';
import 'package:fasyl/core/views//abonnement/abonnement_screen.dart';
import 'package:flutter/material.dart';

class CountdownTimerScreen extends StatefulWidget {
  const CountdownTimerScreen({super.key});

  @override
  _CountdownTimerScreenState createState() => _CountdownTimerScreenState();
}

class _CountdownTimerScreenState extends State<CountdownTimerScreen> {
  int _remainingTime = 30; // 1 minute en secondes
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer.cancel();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AbonnementScreen()));
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Annule le timer pour éviter les fuites de mémoire
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _remainingTime / 30; // Progression de 1.0 à 0.0

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: progress, // Valeur de progression (1.0 à 0.0)
              strokeWidth: 8, // Épaisseur du cercle
              backgroundColor: AppColor.secondaryDark, // Couleur de fond
              valueColor: AlwaysStoppedAnimation<Color>(
                  AppColor.primaryDarker), // Couleur de progression
            ),
          ),
          SizedBox(height: 20), // Espacement
          // Affichage du temps restant
          Text(
            '$_remainingTime seconde',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300,color: Colors.white),
          ),
        ],
      ),
    );
  }
}
