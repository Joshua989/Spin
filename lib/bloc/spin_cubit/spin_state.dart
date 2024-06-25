// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

import 'package:spin/constants/spin_util.dart';

part 'spin_state.g.dart';

enum SpinType {
  thirds,
  columns,
  sixths;
}

@JsonSerializable()
class SpinState {
  final List<String> spins;
  final bool isAbove;
  final List<double> betResults;
  final List<double> betResults2;
  final int spinsToLookBack;
  final double startHighlightAt;
  final SpinType spinType;
  final List<double> totalModifiers;

  double resultAt(int index) {
    double result = betResults.sublist(0, index + 1).fold<double>(
          0,
          (a, b) => a + b,
        );
    double totalModifier = totalModifiers.sublist(0, index + 1).fold<double>(
          0,
          (a, b) => a + b,
        );
    return result + totalModifier;
  }

  const SpinState({
    this.spins = const [],
    this.isAbove = false,
    this.betResults = const [],
    this.betResults2 = const [],
    this.spinsToLookBack = 4,
    this.startHighlightAt = 0.01,
    this.spinType = SpinType.thirds,
    this.totalModifiers = const [],
  });

  /// Takes the given [index] and returns the list of [spins]
  List<String> lastSpins(int index) => (index + 1) - spinsToLookBack <= 0
      ? spins.sublist(0, index + 1)
      : spins.sublist((index + 1) - spinsToLookBack, index + 1);
  double get betTotal => betResults.fold(0, (a, b) => a + b);

  /// Return the percentage of spins within the [lastSpins] list that are between 0 and 12

  double percentage(int third, int index) {
    if (spinType == SpinType.thirds) {
      return _thirds(third, index);
    } else if (spinType == SpinType.columns) {
      return _columns(third, index);
    } else {
      return _sixths(third, index);
    }
  }

  double _thirds(int third, int index) {
    int count = 0;
    if (third == 0) {
      count = lastSpins(index)
          .where((element) =>
              int.tryParse(element) != null &&
              element != "00" &&
              element != "0" &&
              int.parse(element) <= 12)
          .length;
    } else if (third == 1) {
      count = lastSpins(index)
          .where((element) => (int.tryParse(element) != null &&
              element != "0" &&
              int.parse(element) > 12 &&
              int.parse(element) <= 24))
          .length;
    } else {
      count = lastSpins(index)
          .where((element) =>
              int.tryParse(element) != null && int.parse(element) > 24)
          .length;
    }

    return count / lastSpins(index).length;
  }

  // One version would be using columns instead of dozens/thirds. So if you look at the image, there are three rows (called columns if you look at them from the right), they have 2-1 at the right of each of them. So instead of 1 to 12, it would be 1,4,7,10,13,16,19,22,25,28,31,34 for the first third, then the row above for the second third and then the top row for the third third. So it would be the same app but with different numbers instead of 1-12, etc.
  /// First column:
  double _columns(int third, int index) {
    List<int> thisColumn = SpinUtil.getColumn(third);
    int count = lastSpins(index)
        .where((element) =>
            int.tryParse(element) != null &&
            thisColumn.contains(int.parse(element)))
        .length;

    return count / lastSpins(index).length;
  }

  double _sixths(int third, int index) {
    int count = 0;
    if (third == 0) {
      count = lastSpins(index)
          .where((element) =>
              int.tryParse(element) != null &&
              element != "00" &&
              element != "0" &&
              int.parse(element) <= 6)
          .length;
    } else if (third == 1) {
      count = lastSpins(index)
          .where((element) => (int.tryParse(element) != null &&
              element != "0" &&
              int.parse(element) > 6 &&
              int.parse(element) <= 12))
          .length;
    } else if (third == 2) {
      count = lastSpins(index)
          .where((element) => (int.tryParse(element) != null &&
              element != "0" &&
              int.parse(element) > 12 &&
              int.parse(element) <= 18))
          .length;
    } else if (third == 3) {
      count = lastSpins(index)
          .where((element) => (int.tryParse(element) != null &&
              element != "0" &&
              int.parse(element) > 18 &&
              int.parse(element) <= 24))
          .length;
    } else if (third == 4) {
      count = lastSpins(index)
          .where((element) => (int.tryParse(element) != null &&
              element != "0" &&
              int.parse(element) > 24 &&
              int.parse(element) <= 30))
          .length;
    } else {
      count = lastSpins(index)
          .where((element) => (int.tryParse(element) != null &&
              element != "0" &&
              int.parse(element) > 30 &&
              int.parse(element) <= 36))
          .length;
    }

    return count / lastSpins(index).length;
  }

  SpinState copyWith({
    List<String>? spins,
    bool? isAbove,
    List<double>? betResults,
    List<double>? betResults2,
    int? spinsToLookBack,
    double? startHighlightAt,
    SpinType? spinType,
    List<double>? totalModifiers,

  }) {
    return SpinState(
      spins: spins ?? this.spins,
      isAbove: isAbove ?? this.isAbove,
      betResults: betResults ?? this.betResults,
      betResults2: betResults2 ?? this.betResults2,
      spinsToLookBack: spinsToLookBack ?? this.spinsToLookBack,
      startHighlightAt: startHighlightAt ?? this.startHighlightAt,
      spinType: spinType ?? this.spinType,
      totalModifiers: totalModifiers ?? this.totalModifiers,
    );
  }

  factory SpinState.fromJson(Map<String, dynamic> json) =>
      _$SpinStateFromJson(json);
  Map<String, dynamic> toJson() => _$SpinStateToJson(this);
}
