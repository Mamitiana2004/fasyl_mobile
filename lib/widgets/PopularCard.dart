import 'package:flutter/material.dart';

class Popularcard extends StatelessWidget {
  const Popularcard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white, // Fond blanc pour une meilleure lisibilité
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, -2),
              )
            ],
            borderRadius: BorderRadius.circular(12)),
        width: 257,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 6),
                            child: Text(
                              "Se loger",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ))),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        Text(
                          "Hotel gasy",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "Antananrivo",
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFF939393)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ]));
  }
}
