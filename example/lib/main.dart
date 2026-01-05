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
                const CupertinoButton(text: "Liquid Glass"),

                const SizedBox(height: 30),
                const Text(
                  "Custom Colors (Tinted)",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                CupertinoButton(
                  text: "Pink Glass",
                  color: Colors.pinkAccent,
                  textColor: Colors.pink.shade100,
                  width: 200,
                ),
                const SizedBox(height: 10),
                const CupertinoButton(
                  text: "Teal Glass",
                  color: Colors.tealAccent,
                  textColor: Colors.teal,
                ),

                const SizedBox(height: 30),
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
                      systemIconName: "heart.fill",
                      width: 60,
                      height: 60,
                      //color: Colors.red,
                      textColor: Colors.white,
                      borderRadius: 20, // Squircleish
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
                  systemIconName: "play.circle.fill",
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
