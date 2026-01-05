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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      systemIconName: "star.fill",
                      width: 60,
                      height: 60,
                      color: Colors.amber,
                      textColor: Colors.yellow,
                      borderRadius: 30, // Circular
                    ),
                    SizedBox(width: 20),
                    CupertinoButton(
                      systemIconName: "heart.fill",
                      width: 60,
                      height: 60,
                      color: Colors.red,
                      textColor: Colors.white,
                      borderRadius: 20, // Squircleish
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
                  text: "Play Music",
                  systemIconName: "play.circle.fill",
                  width: 220,
                  height: 55,
                  borderRadius: 27.5,
                ),

                const SizedBox(height: 30),
                const Text(
                  "Legacy Style (Liquid Disabled)",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                const CupertinoButton(
                  text: "Legacy Button",
                  enableLiquid: false,
                  color: Colors.blue,
                  textColor: Colors.white,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
