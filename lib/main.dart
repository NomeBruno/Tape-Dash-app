import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:tap_dash/pages/tapehome.dart';
import 'package:tap_dash/services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase não tem suporte nativo para Linux desktop
  if (!Platform.isLinux) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Pré-carrega os sons
  await AudioService.instance.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TapeDashHome(),
    );
  }
}
