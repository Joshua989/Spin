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
  final lookbackShortTermController = TextEditingController();
  final lookbackLongTermController = TextEditingController();
  final startHighlightShortTermController = TextEditingController();
  final startHighlightLongTermController = TextEditingController();
  final lookbackShortTermKey = GlobalKey<FormState>();
  final lookbackLongTermKey = GlobalKey<FormState>();
  final startHighlightShortTermKey = GlobalKey<FormState>();
  final startHighlightLongTermKey = GlobalKey<FormState>();

  List<String> previousReports = [];

  @override
  void initState() {
    lookbackShortTermController.text = widget.currentState.spinsToLookBackShortTerm.toString();
    lookbackLongTermController.text = widget.currentState.spinsToLookBackLongTerm.toString();
    startHighlightShortTermController.text = widget.currentState.startHighlightAtShortTerm.toString();
    startHighlightLongTermController.text = widget.currentState.startHighlightAtLongTerm.toString();
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
        final anchor = html.AnchorElement(href: url)
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
              const Text("Short-Term Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12.0),
              Form(
                key: lookbackShortTermKey,
                child: TextFormField(
                  controller: lookbackShortTermController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Short-Term Spins to look back",
                  ),
                  onChanged: (v) {
                    if (lookbackShortTermKey.currentState!.validate()) {
                      context.read<SpinCubit>().setSpinsToLookBackShortTerm(
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
                key: startHighlightShortTermKey,
                child: TextFormField(
                  controller: startHighlightShortTermController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Start highlighting short-term at",
                  ),
                  onChanged: (v) {
                    if (startHighlightShortTermKey.currentState!.validate()) {
                      context.read<SpinCubit>().setStartHighlightAtShortTerm(
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
              Row(
                children: [
                  CupertinoSwitch(
                    value: state.isAboveShortTerm,
                    activeColor: Colors.red,
                    onChanged: (v) {
                      context.read<SpinCubit>().toggleIsAboveShortTerm();
                    },
                  ),
                  const SizedBox(width: 4.0),
                  const Text("Highlight short-term above"),
                ],
              ),
              const SizedBox(height: 12.0),
              const Divider(),
              const SizedBox(height: 12.0),
              const Text("Long-Term Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12.0),
              Form(
                key: lookbackLongTermKey,
                child: TextFormField(
                  controller: lookbackLongTermController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Long-Term Spins to look back",
                  ),
                  onChanged: (v) {
                    if (lookbackLongTermKey.currentState!.validate()) {
                      context.read<SpinCubit>().setSpinsToLookBackLongTerm(
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
                key: startHighlightLongTermKey,
                child: TextFormField(
                  controller: startHighlightLongTermController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Start highlighting long-term at",
                  ),
                  onChanged: (v) {
                    if (startHighlightLongTermKey.currentState!.validate()) {
                      context.read<SpinCubit>().setStartHighlightAtLongTerm(
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
              Row(
                children: [
                  CupertinoSwitch(
                    value: state.isAboveLongTerm,
                    activeColor: Colors.red,
                    onChanged: (v) {
                      context.read<SpinCubit>().toggleIsAboveLongTerm();
                    },
                  ),
                  const SizedBox(width: 4.0),
                  const Text("Highlight long-term above"),
                ],
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
