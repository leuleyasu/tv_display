import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'feature/tv_display/presentation/screen/tv_display_auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TvDisplayApp());
}

class TvDisplayApp extends StatelessWidget {
  const TvDisplayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicQ TV Display',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const TvDisplayAuthGate(),
    );
  }
}
