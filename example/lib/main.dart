import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino/flutter_cupertino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _sliderValue = 0.5;
  bool _switchValue = false;
  int _segmentedValue = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[850],
        appBar: AppBar(
          title: const Text('Cupertino Liquid Button'),
          backgroundColor: Colors.black54,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Default Liquid Button",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),

                const Text(
                  "Icons & Symbols (SF Symbols)",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CupertinoButton(
                      systemIconName: "star.fill",
                      width: 60,
                      height: 60,
                      color: Colors.amber,
                      textColor: Colors.yellow,
                      borderRadius: 30, // Circular
                    ),
                    const SizedBox(width: 20),
                    CupertinoButton(
                      systemIconName: "checkmark",
                      isCircle: true,
                      height: 50,
                      width: 50,
                      controlSize: CupertinoControlSize.large,
                      //color: Colors.red,
                      textColor: Colors.white,
                      style: CupertinoButtonStyle.glass,
                      onPressed: () {
                        log("Pressed");
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                const Text(
                  "Icon + Text",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                const CupertinoButton(
                  style: CupertinoButtonStyle.glass,
                  text: "Play Music",
                  controlSize: CupertinoControlSize.large,
                  systemIconName: "play.circle.fill",
                  width: 220,
                  height: 55,
                  borderRadius: 27.5,
                ),

                const SizedBox(height: 30),
                const CupertinoButton(
                  style: CupertinoButtonStyle.glass,
                  text: "Play Music",
                  controlSize: CupertinoControlSize.large,
                  systemIconName: "play.circle.fill",
                  //iconBytes: Icons.home.toBytes(),
                  width: 220,
                  height: 55,
                  borderRadius: 27.5,
                ),

                const SizedBox(height: 30),
                const Text(
                  "Glass Styles",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                const CupertinoButton(
                  text: "Glass Button",
                  style: CupertinoButtonStyle.glass,
                  color: Colors.blue,
                ),
                const SizedBox(height: 10),
                const CupertinoButton(
                  text: "Prominent Glass",
                  style: CupertinoButtonStyle.glassProminent,
                  color: Colors.purple,
                ),

                const SizedBox(height: 30),
                const Text(
                  "SwiftUI Styles",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                const CupertinoButton(
                  text: "Filled Style",
                  style: CupertinoButtonStyle.filled,
                  color: Colors.blue,
                ),
                const SizedBox(height: 10),
                const CupertinoButton(
                  text: "Tinted Style",
                  style: CupertinoButtonStyle.tinted,
                  color: Colors.purple,
                ),
                const SizedBox(height: 10),
                const CupertinoButton(
                  text: "Gray Style",
                  style: CupertinoButtonStyle.gray,
                  textColor: Colors.orange,
                ),
                const SizedBox(height: 10),
                const CupertinoButton(
                  text: "Plain Style",
                  style: CupertinoButtonStyle.plain,
                  textColor: Colors.red,
                ),

                const SizedBox(height: 30),
                const Text(
                  "Custom Text Style & Filled (Liquid)",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                const CupertinoButton(
                  text: "Styled Button",
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  color: Colors.purple,
                ),

                const SizedBox(height: 40),
                FutureBuilder<String?>(
                  future: FlutterCupertino.getPlatformVersion(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        'Platform: ${snapshot.data}',
                        style: const TextStyle(color: Colors.grey),
                      );
                    } else if (snapshot.hasError) {
                      return const Text(
                        'Error getting platform version',
                        style: TextStyle(color: Colors.red),
                      );
                    }
                    return const CircularProgressIndicator(strokeWidth: 2);
                  },
                ),

                const SizedBox(height: 30),
                const Text(
                  "Cupertino Slider",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                CupertinoSlider(
                  value: _sliderValue,
                  onChanged: (value) {
                    setState(() {
                      _sliderValue = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
                Text(
                  "Value: ${_sliderValue.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 30),
                const Text(
                  "Cupertino Switch",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoSwitch(
                      value: _switchValue,
                      onChanged: (value) {
                        setState(() {
                          _switchValue = value;
                        });
                      },
                      activeColor: Colors.blueAccent,
                    ),
                    const SizedBox(width: 20),
                    CupertinoSwitch(
                      value: !_switchValue,
                      label: "Mute",
                      labelsHidden: false,
                      // width: 100, // Explicit width removed, using auto-calculation
                      onChanged: (value) {
                        setState(() {
                          _switchValue = !value;
                        });
                      },
                      activeColor: Colors.purpleAccent,
                    ),
                  ],
                ),
                CupertinoSwitch(
                  value: !_switchValue,
                  label: "Mute",
                  labelsHidden: false,
                  // width: 100, // Explicit width removed, using auto-calculation
                  onChanged: (value) {
                    setState(() {
                      _switchValue = !value;
                    });
                  },
                  activeColor: Colors.purpleAccent,
                ),
                Text(
                  "Switch: $_switchValue",
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 30),
                const Text(
                  "Cupertino Segmented Control",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CupertinoSegmentedControl<int>(
                    children: const {0: "Map", 1: "Transit", 2: "Satellite"},
                    groupValue: _segmentedValue,
                    onValueChanged: (value) {
                      setState(() {
                        _segmentedValue = value;
                      });
                    },
                    // activeColor: Colors.blue,
                  ),
                ),

                const SizedBox(height: 30),
                const Text(
                  "Cupertino Popup Menu (Glass)",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                CupertinoMenu(
                  label: "Options",
                  systemIconName: "ellipsis.circle",
                  width: 140,
                  children: [
                    CupertinoMenuItem(
                      label: "Share",
                      systemIconName: "square.and.arrow.up",
                      onPressed: () => debugPrint("Share pressed"),
                    ),
                    CupertinoMenuItem(
                      label: "Favorite",
                      systemIconName: "star",
                      onPressed: () => debugPrint("Favorite pressed"),
                    ),
                    const CupertinoMenuDivider(),
                    CupertinoMenuItem(
                      label: "More...",
                      systemIconName: "ellipsis.circle",
                      children: [
                        CupertinoMenuItem(
                          label: "Print",
                          systemIconName: "printer",
                          onPressed: () => debugPrint("Print pressed"),
                        ),
                        CupertinoMenuItem(
                          label: "Save to Files",
                          systemIconName: "folder",
                          onPressed: () => debugPrint("Save pressed"),
                        ),
                      ],
                    ),
                    const CupertinoMenuDivider(),
                    CupertinoMenuItem(
                      label: "Delete",
                      systemIconName: "trash",
                      isDestructive: true,
                      onPressed: () => debugPrint("Delete pressed"),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                const Text(
                  "Popover Mode (Glass Prominent)",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                CupertinoMenu(
                  systemIconName: "chart.bar.doc.horizontal",
                  style: CupertinoButtonStyle.glassProminent,
                  usePopover: true,
                  width: 60,
                  children: [
                    CupertinoMenuItem(
                      label: "View Report",
                      systemIconName: "doc.text",
                      onPressed: () => debugPrint("View Report"),
                    ),
                    CupertinoMenuItem(
                      label: "Analysis",
                      systemIconName: "chart.pie",
                      onPressed: () => debugPrint("Analysis"),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                CupertinoButton(
                  text: "Show Alert",
                  color: Colors.orange,
                  textColor: Colors.white,
                  width: 200,
                  onPressed: () {
                    log("Show Alert");
                    CupertinoAlert.show(
                      context,
                      title: "Liquid Alert",
                      content: "This is a custom alert with liquid buttons.",

                      actions: [
                        CupertinoActionButton(
                          text: "Cancel",
                          style: CupertinoActionStyle.destructive,
                          onPressed: () => debugPrint("Cancel pressed"),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
