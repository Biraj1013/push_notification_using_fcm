import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class NotificationBadege extends StatelessWidget {
  //also take a total notification value
  final int totalNotification;

  NotificationBadege({Key? key, required this.totalNotification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
      child: Center(
          child: Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          "$totalNotification",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      )),
    );
  }
}
