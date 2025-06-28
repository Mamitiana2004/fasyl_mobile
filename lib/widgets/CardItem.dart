import 'package:flutter/material.dart';

class CardItem extends StatefulWidget {
  const CardItem({super.key});

  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
      child: Row(
        spacing: 10,
        children: [
          Container(
            width: 100,
            height: 100,
            color: Colors.grey,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                      child: Text(
                        "Se loger",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ))),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    "Hotel gasy",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Antananrivo",
                    style: TextStyle(fontSize: 12, color: Color(0xFF939393)),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
