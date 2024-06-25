import 'package:flutter/material.dart';
import 'package:spin/bloc/spin_cubit/spin_state.dart'; // Import custom spin state if applicable
import 'package:spin/constants/colour.dart'; // Import color constants
import 'package:spin/constants/spin_util.dart'; // Import utility functions for spin

class AddSpinDialogue extends StatefulWidget {
  final SpinType initialType; // Define initial SpinType

  const AddSpinDialogue({Key key, this.initialType}) : super(key: key);

  @override
  _AddSpinDialogueState createState() => _AddSpinDialogueState();
}

class _AddSpinDialogueState extends State<AddSpinDialogue> {
  SpinType currentType; // Define current SpinType

  @override
  void initState() {
    super.initState();
    currentType = widget.initialType ?? SpinType.blackRed; // Set initial type from widget or default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Spin"),
        actions: [
          // Toggle buttons for different even bet options
          IconButton(
            icon: Icon(Icons.circle, color: currentType == SpinType.blackRed ? Colors.red : Colors.grey),
            onPressed: () {
              setState(() {
                currentType = SpinType.blackRed;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_1, color: currentType == SpinType.oddsEvens ? Colors.blue : Colors.grey),
            onPressed: () {
              setState(() {
                currentType = SpinType.oddsEvens;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.trending_up, color: currentType == SpinType.highLow ? Colors.green : Colors.grey),
            onPressed: () {
              setState(() {
                currentType = SpinType.highLow;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: getOptions(context), // Render options based on selected type
        ),
      ),
    );
  }

  // Method to get options based on current SpinType
  List<Widget> getOptions(BuildContext context) {
    switch (currentType) {
      case SpinType.blackRed:
        return generateBlackRed(context); // Display Black/Red options
      case SpinType.oddsEvens:
        return generateOddsEvens(context); // Display Odds/Evens options
      case SpinType.highLow:
        return generateHighLow(context); // Display High/Low options
      default:
        return []; // Handle other types or provide a default
    }
  }

  // Method to generate buttons for Black/Red
  List<Widget> generateBlackRed(BuildContext context) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          button("Black", context),
          button("Red", context),
        ],
      ),
    ];
  }

  // Method to generate buttons for Odds/Evens
  List<Widget> generateOddsEvens(BuildContext context) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          button("Odd", context),
          button("Even", context),
        ],
      ),
    ];
  }

  // Method to generate buttons for High/Low
  List<Widget> generateHighLow(BuildContext context) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          button("1-18", context),
          button("19-36", context),
        ],
      ),
    ];
  }

  // Method to create a button widget
  Widget button(String thisValue, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: TextButton(
        onPressed: () {
          Navigator.pop(context, thisValue); // Return selected value when button is pressed
        },
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            EdgeInsets.all(12), // Set padding for button
          ),
          backgroundColor: MaterialStateProperty.all(
            Colour.rouletteWheel(thisValue), // Set background color based on value
          ),
        ),
        child: Text(
          thisValue, // Display button text
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
