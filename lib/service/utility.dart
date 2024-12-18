import 'package:flutter/material.dart';

class Utility {

  static Widget createCustomIconButton(IconData iconName,
      String btnText,
      Widget screen, {
        bool horizontal = false,
        bool isGrid = false,
        required BuildContext context,
        Color backgroundColor = const Color(0xff323465),
      }) {
    double buttonSize = MediaQuery
        .of(context)
        .size
        .width * 0.18;

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      child: horizontal
          ? Row(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(iconName),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              btnText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),
          ),
        ],
      )
          : Padding(
            padding: const EdgeInsets.only(left: 20,right: 20),
            child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
            Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.10,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.4,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 3,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(iconName, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 5.0),
            Text(
              btnText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15.5, color: Colors.black),
            ),
                    ],
                  ),
          ),
    );
  }
}