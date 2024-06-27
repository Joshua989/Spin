import 'package:spin/bloc/spin_cubit/spin_state.dart';

class SpinUtil {
  static int getThird(String spin, SpinType spinType) {
    if (spinType == SpinType.thirds) {
      return _getThird(spin);
    } else if (spinType == SpinType.columns) {
      return getColumnFromSpin(spin);
    } else {
      return _getSixth(spin);
    }
  }

  static int _getThird(String spin) {
    if (spin == "00" || spin == "0") {
      return 3;
    } else if ((int.tryParse(spin) != null &&
        int.parse(spin) > 12 &&
        int.parse(spin) <= 24)) {
      return 1;
    } else if (int.tryParse(spin) != null && int.parse(spin) <= 12) {
      return 0;
    } else {
      return 2;
    }
  }


  static List<int> getColumn(int third) {
    switch (third) {
      case 0:
        return [1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34];
      case 1:
        return [2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 35];
      default:
        return [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36];
    }
  }

  static int getColumnFromSpin(String spin) {
    List<int> firstColumn = getColumn(0);
    List<int> secondColumn = getColumn(1);
    if (spin == "00" || spin == "0") {
      return 3;
    }
    int thisSpin = int.parse(spin);
    if (firstColumn.contains(thisSpin)) {
      return 0;
    } else if (secondColumn.contains(thisSpin)) {
      return 1;
    } else {
      return 2;
    }
  }

  static int _getSixth(String spin) {
    if (spin == "00" || spin == "0") {
      return 6;
    } else if (int.tryParse(spin) != null && int.parse(spin) <= 6) {
      return 0;
    } else if (int.tryParse(spin) != null && int.parse(spin) <= 12) {
      return 1;
    } else if (int.tryParse(spin) != null && int.parse(spin) <= 18) {
      return 2;
    } else if (int.tryParse(spin) != null && int.parse(spin) <= 24) {
      return 3;
    } else if (int.tryParse(spin) != null && int.parse(spin) <= 30) {
      return 4;
    } else {
      return 5;
    }
  }
}
