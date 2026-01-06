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
                ),

                const SizedBox(height: 30),
                const CupertinoButton(
                  style: CupertinoButtonStyle.glass,
                  text: "Play Music",
                  controlSize: CupertinoControlSize.large,
                  systemIconName: "play.circle.fill",

                  //iconBytes: Icons.home.toBytes(),
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
                  "Cupertino Popup Menu (Glass & Large)",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                CupertinoMenu(
                  label: "Options",
                  controlSize: CupertinoControlSize.large,
                  systemIconName: "ellipsis.circle",
                  width: 140,
                  height: 38,
                  sections: [
                    CupertinoMenuActionRow(
                      items: [
                        CupertinoMenuItem(
                          label: "Label",
                          systemIconName: "star.fill",
                          onPressed: () => debugPrint("Star Header"),
                        ),
                        CupertinoMenuItem(
                          label: "Label",
                          systemIconName: "star.fill",
                          onPressed: () => debugPrint("Star Header 2"),
                        ),
                        CupertinoMenuItem(
                          label: "Destructive",
                          systemIconName: "star.fill",
                          isDestructive: true,
                          onPressed: () => debugPrint("Destructive Header"),
                        ),
                      ],
                    ),
                    CupertinoMenuSection(
                      title: "Section Title",
                      items: [
                        CupertinoMenuItem(
                          label: "Label",
                          systemIconName: "selection.pin.in.out",
                          trailingIconName: "command",
                          onPressed: () => debugPrint("Label pressed"),
                        ),
                        CupertinoMenuItem(
                          label: "Disabled Action",
                          systemIconName: "selection.pin.in.out",
                          isEnabled: false,
                        ),
                        CupertinoMenuItem(
                          label: "Destructive Action",
                          systemIconName: "selection.pin.in.out",
                          isDestructive: true,
                          onPressed: () => debugPrint("Destructive Action"),
                        ),
                      ],
                    ),
                    CupertinoMenuSection(
                      items: [
                        CupertinoMenuItem(
                          label: "Action",
                          systemIconName: "selection.pin.in.out",
                          onPressed: () => debugPrint("Action pressed"),
                        ),
                      ],
                    ),
                    CupertinoMenuSection(
                      title: "Section Title",
                      items: [
                        CupertinoMenuItem(
                          label: "Submenu",
                          children: [
                            CupertinoMenuItem(label: "Child 1"),
                            CupertinoMenuItem(label: "Child 2"),
                          ],
                        ),
                        CupertinoMenuItem(
                          label: "Submenu",
                          children: [CupertinoMenuItem(label: "Child 1")],
                        ),
                        CupertinoMenuItem(
                          label: "Submenu with a long title",
                          children: [CupertinoMenuItem(label: "Child 1")],
                        ),
                      ],
                    ),
                    CupertinoMenuSection(
                      title: "Section Title",
                      items: [
                        CupertinoMenuItem(
                          label: "Action",
                          systemIconName: "selection.pin.in.out",
                          trailingIconName: "command",
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                const Text(
                  "Medium & Small Menus",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoMenu(
                      label: "Med",
                      controlSize: CupertinoControlSize.regular,
                      systemIconName: "list.bullet",
                      width: 100,
                      height: 40,
                      sections: [
                        CupertinoMenuSection(
                          items: [
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
                      ],
                    ),
                    const SizedBox(width: 20),
                    CupertinoMenu(
                      label: "Small",
                      controlSize: CupertinoControlSize.small,
                      systemIconName: "gear",
                      width: 80,
                      height: 32,
                      sections: [
                        CupertinoMenuSection(
                          items: [
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
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                const Text(
                  "Popup Icon-Only (Glass Prominent)",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                CupertinoMenu(
                  systemIconName: "chart.bar.doc.horizontal",
                  style: CupertinoButtonStyle.glassProminent,
                  width: 60,
                  sections: [
                    CupertinoMenuSection(
                      items: [
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
                        CupertinoMenuItem(
                          label: "Delete",
                          isDestructive: true,
                          systemIconName: "trash",
                        ),
                      ],
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
