import 'package:flutter/material.dart';
import 'package:spin/bloc/spin_cubit/spin_state.dart';
import 'package:spin/constants/colour.dart';
import 'package:spin/constants/spin_util.dart';

class AddSpinDialogue extends StatelessWidget {
  const AddSpinDialogue(this.type, {super.key});

  final SpinType type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Spin"),
      ),
      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: getOptions(context),
        ),
      ),
    );
  }

  List<Widget> getOptions(BuildContext context) {
     return generateThirds(context);
    // if (type == SpinType.thirds) {
    //   return generateThirds(context);
    // } else if (type == SpinType.sixths) {
    //   return generateSixths(context);
    // } else {
    //   return generateColumns(context);
    // }
  }

  List<Widget> generateThirds(BuildContext context) {
    return List.generate(
      3,
      (v) {
        return Column(
          children: List.generate(13, (i) {
            String thisValue = (((v) * 12) + i).toString();
            if (v == 1 && i == 0) {
              thisValue = "00";
            } else if (v == 2) {
              thisValue = (((v) * 12) + i + 1).toString();
            }

            if (thisValue == "37") {
              return const SizedBox();
            }
            return button(thisValue, context);
          }).toList(),
        );
      },
    ).toList();
  }

  List<Widget> generateSixths(BuildContext context) {
    return List.generate(
      6,
      (v) {
        return Column(
          children: [
            if (v == 0) ...[
              button("0", context),
            ],
            if (v == 1) ...[
              button("00", context),
            ],
            ...List.generate(7, (i) {
              String thisValue = (((v) * 6) + i).toString();
              if (v == 5) {
                thisValue = (((v) * 6) + i + 1).toString();
              }
              if ((v != 0 && v != 5 && i == 0) || thisValue == "37" || thisValue == "0") {
                return const SizedBox();
              }

              return button(thisValue, context);
            }),
          ],
        );
      },
    ).toList();
  }

  List<Widget> generateColumns(BuildContext context) {
    List<List<int>> columns = [
      SpinUtil.getColumn(0),
      SpinUtil.getColumn(1),
      SpinUtil.getColumn(2),
    ];

    return List.generate(
      3,
      (v) {
        return Column(
          children: [
            if (v == 0) ...[
              button("0", context),
            ],
            if (v == 1) ...[
              button("00", context),
            ],
            ...List.generate(12, (i) {
              String thisValue = columns[v][i].toString();
              return button(thisValue, context);
            }),
          ],
        );
      },
    ).toList();
  }

  Widget button(String thisValue, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: TextButton(
        onPressed: () {
          Navigator.pop(context, thisValue);
        },
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            const EdgeInsets.all(
              12,
            ),
          ),
          backgroundColor: MaterialStateProperty.all(
            Colour.rouletteWheel(int.parse(thisValue)),
          ),
        ),
        child: Text(
          thisValue,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
