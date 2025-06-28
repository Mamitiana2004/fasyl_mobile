import 'package:fasyl/core/config/constants.dart';
import 'package:fasyl/widgets/countdownTimer.dart';
import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.secondary,
        body: Center(
            child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "FASYL",
                      style: TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 7,
                          fontSize: 24),
                    ),
                    Container(
                      width: 327,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 30,
                        children: [
                          CountdownTimerScreen(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 16,
                            children: [
                              Text(
                                "Verification, patientez",
                                style: TextStyle(
                                  color: Colors.white,
                                    fontSize: 22, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                "Votre photo de profil est en train d'être étudié",
                                style: TextStyle(
                                  color: Colors.white,
                                    fontSize: 14, fontWeight: FontWeight.w300),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 327,
                      child: ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(AppColor.secondaryLight),
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                          color: AppColor.secondaryLighter,
                                          width: 1)))),
                          child: Text(
                            "RETOUR A L'INSCRIPTION",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          )),
                    )
                  ],
                ))));
  }
}
