import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spin/bloc/spin_cubit/spin_cubit.dart';
import 'package:spin/bloc/spin_cubit/spin_state.dart';
import 'package:spin/constants/colour.dart';
import 'package:spin/constants/spin_util.dart';
import 'package:spin/screens/add_spin_dialogue.dart';
import 'package:spin/screens/settings_screen.dart';

class SpinScreen extends StatefulWidget {
  const SpinScreen({super.key});

  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen> {
  final scrollController = ScrollController();

  void addSpin(context, SpinType type, SpinCubit cubit) async {
    String? spin = await showCupertinoModalPopup(
      context: context,
      builder: (context) => Padding(
        /// Ensure that the dialog resizes itself when the keyboard is displayed
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddSpinDialogue(type),
      ),
    );
    if (spin != null) {
      cubit.addSpin(spin);

      /// wait for the element to be added to the list before scrolling
      await Future.delayed(const Duration(milliseconds: 100));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void setBet(int index, SpinState state, SpinCubit cubit,
      {bool isSecond = false}) {
    final newValueController = TextEditingController(
      text: state.betResults[index] != 0
          ? isSecond ? state.betResults2[index].toStringAsFixed(2) : state.betResults[index].toStringAsFixed(2)
          : "",
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Bet"),
        content: TextField(
          controller: newValueController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Bet",
            hintText: "Enter the result for this spin",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final double? value = double.tryParse(newValueController.text);
              if (value != null) {
                if (isSecond) {
                  cubit.setBet2(index, value);
                } else {
                  cubit.setBet(index, value);
                }
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void setTotalModifier(int index, SpinState state, SpinCubit cubit) {
    final newValueController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Total"),
        content: TextField(
          controller: newValueController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Total",
            hintText: "Enter a total modifier for this spin",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final double? value = double.tryParse(newValueController.text);
              if (value != null) {
                cubit.setTotalModifier(index, value);
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpinCubit, SpinState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text("Spin Tracker"),
              Row(
                children: [
                  TextButton(
                    onPressed: () => addSpin(
                      context,
                      state.spinType,
                      context.read<SpinCubit>(),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      fixedSize: MaterialStateProperty.all(const Size(100, 50)),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.all(10.0),
                      ),
                    ),
                    child: const Text(
                      "SPIN",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  TextButton(
                    onPressed: () => context.read<SpinCubit>().setSpinType(
                          state.spinType == SpinType.thirds
                              ? SpinType.columns
                              : SpinType.thirds,
                        ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      fixedSize: MaterialStateProperty.all(const Size(100, 50)),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.all(10.0),
                      ),
                    ),
                    child: Text(
                      "SWITCH TO ${state.spinType == SpinType.thirds ? "COLUMNS" : "THIRDS"}",
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => context.read<SpinCubit>().undo(),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(currentState: state),
                  ),
                );
              },
            ),
          ],
        ),
        body: ListView(
          controller: scrollController,
          children: [
            ...state.spins.mapIndexed<Widget>(
              (index, spin) {
                /// 6 columns. The first column should be the spin number, then three columns with the % then a column with the result of the bet and the last column be a running total of the Bet column.
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      cell(
                        (index + 1).toString(),
                        "Spin",
                        state.spinType,
                        halfSize: true,
                      ),
                      cell(
                        spin,
                        "Spin",
                        state.spinType,
                        colour: Colour.thirdColor(
                                SpinUtil.getThird(spin, state.spinType))
                            .withOpacity(0.4),
                      ),
                      ...List.generate(
                          state.spinType == SpinType.sixths ? 6 : 3, (v) {
                        final double value = state.percentage(v, index);
                        final bool shouldHighlight = state.isAbove
                            ? value >= state.startHighlightAt
                            : value < state.startHighlightAt;
                        return cell(
                          "${(state.percentage(v, index) * 100).toStringAsFixed(0)}%",
                          "Percentage of ${v + 1}${v == 0 ? "st" : v == 1 ? "nd" : v == 2 ? "rd" : "th"}",
                          state.spinType,
                          colour: shouldHighlight
                              ? Colour.thirdColor(v).withOpacity(0.4)
                              : null,
                        );
                      }),
                      GestureDetector(
                        onTap: () =>
                            setBet(index, state, context.read<SpinCubit>()),
                        child: cell(
                          state.betResults[index].toStringAsFixed(2),
                          "Bet",
                          state.spinType,
                          colour: state.betResults[index] > 0
                              ? Colors.green.withOpacity(0.5)
                              : state.betResults[index] < 0
                                  ? Colors.red.withOpacity(0.5)
                                  : null,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setBet(
                          index,
                          state,
                          context.read<SpinCubit>(),
                          isSecond: true,
                        ),
                        child: cell(
                          state.betResults2[index].toStringAsFixed(2),
                          "Bet",
                          state.spinType,
                          colour: state.betResults2[index] > 0
                              ? Colors.green.withOpacity(0.5)
                              : state.betResults2[index] < 0
                                  ? Colors.red.withOpacity(0.5)
                                  : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget cell(String value, String title, SpinType spinType,
      {Color? colour, bool? halfSize}) {
    return Container(
      padding: const EdgeInsets.all(3.0),
      width: MediaQuery.of(context).size.width /
          (halfSize == true
              ? 15
              : spinType == SpinType.sixths
                  ? 10
                  : 6.5),
      height: 36.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
        color: colour,
      ),
      child: Column(
        children: [
          AutoSizeText(
            title,
            maxFontSize: 8,
            minFontSize: 1,
            maxLines: 1,
          ),
          Expanded(
            child: AutoSizeText(
              value,
              minFontSize: 1.0,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
