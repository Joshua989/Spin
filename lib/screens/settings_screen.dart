import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spin/bloc/spin_cubit/spin_cubit.dart';
import 'package:spin/bloc/spin_cubit/spin_state.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:spin/models/exported_report.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.currentState});

  final SpinState currentState;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final lookbackController = TextEditingController();
  final startHighlightController = TextEditingController();
  final lookbackKey = GlobalKey<FormState>();
  final startHighlightKey = GlobalKey<FormState>();

  List<String> previousReports = [];

  @override
  void initState() {
    lookbackController.text = widget.currentState.spinsToLookBack.toString();
    startHighlightController.text =
        widget.currentState.startHighlightAt.toString();
    getPreviousReports();
    super.initState();
  }

  Future<void> getPreviousReports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    previousReports = prefs.getStringList('previousReports') ?? [];
    setState(() {});
  }

  Future<void> saveCurrentReport() async {
    final nameController = TextEditingController(
      text: DateTime.now().toString(),
    );
    bool? shouldSave = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Report Name"),
          content: TextFormField(
            controller: nameController,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );

    if (shouldSave == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      previousReports.add(nameController.text);
      prefs.setStringList('previousReports', previousReports);
      prefs.setString(
          nameController.text, jsonEncode(widget.currentState.toJson()));
      previousReports = prefs.getStringList('previousReports') ?? [];
      setState(() {});
    }
  }

  Future<void> loadReport(String name) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Load Report"),
          content: const Text(
              "Are you sure you want to load this report? This will replace all current data."),
          actions: [
            TextButton(
              onPressed: () {
                SharedPreferences.getInstance().then((prefs) {
                  String? report = prefs.getString(name);
                  if (report != null) {
                    SpinState spinState =
                        SpinState.fromJson(jsonDecode(report));
                    context.read<SpinCubit>().loadState(spinState);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                });
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  void deleteReport(String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Report"),
          content: const Text(
              "Are you sure you want to delete this report? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                SharedPreferences.getInstance().then((prefs) {
                  prefs.remove(name);
                  previousReports.remove(name);
                  prefs.setStringList('previousReports', previousReports);
                  setState(() {});
                  Navigator.pop(context);
                });
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  Future<void> exportReport(String name) async {
    SharedPreferences.getInstance().then((prefs) {
      String? report = prefs.getString(name);
      if (report != null) {
        SpinState spinState = SpinState.fromJson(jsonDecode(report));
        final export = ExportedReport(report: spinState, name: name);
        final reportString = jsonEncode(export.toJson());
        final blob = html.Blob([reportString], 'application/json');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", "$name.json")
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    });
  }

  Future<void> importReport() async {
    final input = html.FileUploadInputElement()
      ..accept = 'application/json'
      ..click();

    input.onChange.listen((e) {
      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsText(file);
      reader.onLoadEnd.listen((e) {
        final report = jsonDecode(reader.result as String);
        final exportedReport = ExportedReport.fromJson(report);
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString(
              exportedReport.name, jsonEncode(exportedReport.report));
          previousReports.add(exportedReport.name);
          prefs.setStringList('previousReports', previousReports);
          setState(() {});
        });
      });
    });
  }

  void clearSpins() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Clear Spins"),
          content: const Text(
            "Are you sure you want to clear all spins? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<SpinCubit>().clearSpins();
                Navigator.pop(context);
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpinCubit, SpinState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ListView(
            children: [
              const SizedBox(height: 12.0),
              Row(
                children: [
                  CupertinoSwitch(
                    value: state.isAbove,
                    activeColor: Colors.red,
                    onChanged: (v) {
                      context.read<SpinCubit>().toggleIsAbove();
                    },
                  ),
                  const SizedBox(width: 4.0),
                  const Text("Highlight above"),
                ],
              ),
              const SizedBox(height: 12.0),
              /// Dropdown to switch between SpinType
              const Text("Select Type"),
              DropdownButton<SpinType>(
                value: state.spinType,
                hint: const Text("Select Type"),
                onChanged: (v) {
                  if (v != null) {
                    context.read<SpinCubit>().setSpinType(v);
                  }
                },
                items: SpinType.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.toString().split('.').last),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 12.0),
              Form(
                key: lookbackKey,
                child: TextFormField(
                  controller: lookbackController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Spins to look back",
                  ),
                  onChanged: (v) {
                    if (lookbackKey.currentState!.validate()) {
                      context.read<SpinCubit>().setSpinsToLookBack(
                            int.parse(v),
                          );
                    }
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }

                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12.0),
              Form(
                key: startHighlightKey,
                child: TextFormField(
                  controller: startHighlightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Start highlighting at",
                  ),
                  onChanged: (v) {
                    if (startHighlightKey.currentState!.validate()) {
                      context.read<SpinCubit>().setStartHighlightAt(
                            double.parse(v),
                          );
                    }
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) > 1 || double.parse(value) < 0) {
                      return 'Please enter a value between 0 and 1';
                    }

                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12.0),
              TextButton(
                onPressed: clearSpins,
                child: const Text("Clear Spins"),
              ),
              TextButton(
                onPressed: saveCurrentReport,
                child: const Text("Save Current Report"),
              ),
              TextButton(
                onPressed: importReport,
                child: const Text("Import Report"),
              ),
              const SizedBox(height: 12.0),
              const Text(
                "Previous Reports",
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              const SizedBox(height: 12.0),
              ...previousReports.map<Widget>((v) {
                return ListTile(
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () => exportReport(v),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteReport(v),
                      ),
                    ],
                  ),
                  title: Text(v),
                  onTap: () => loadReport(v),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
