import 'package:flutter/material.dart';

class Colour {
  static Color thirdColor(int value) {
    if (value == 0) {
      return Colors.red;
    } else if (value == 1) {
      return Colors.yellow;
    } else if (value == 2) {
      return Colors.blue;
    } else if (value == 3) {
      return Colors.green;
    } else if (value == 4) {
      return Colors.purple;
    } else if (value == 5) {
      return Colors.orange;
    } else {
      return Colors.black;
    }
  }

  static Color rouletteWheel(int number) {
    switch (number) {
      case 0:
        return Colors.green;
      case 1:
      case 3:
      case 5:
      case 7:
      case 9:
      case 12:
      case 14:
      case 16:
      case 18:
      case 19:
      case 21:
      case 23:
      case 25:
      case 27:
      case 30:
      case 32:
      case 34:
      case 36:
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
