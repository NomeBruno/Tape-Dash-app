import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tap_dash/colors/cor.dart';
import 'package:tap_dash/pages/pontosscreen.dart';
import 'package:tap_dash/pages/tapejogo.dart';
import 'package:tap_dash/services/audio_service.dart';
import 'package:tap_dash/widget/homemenu.dart';

class TapeDashHome extends StatefulWidget {
  const TapeDashHome({super.key});

  @override
  State<TapeDashHome> createState() => _TapeDashHomeState();
}

class _TapeDashHomeState extends State<TapeDashHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _titleCtrl;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  @override
  void initState() {
    super.initState();
    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _titleFade = CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut);
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, -0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut));

    _titleCtrl.forward();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBG,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.4,
            colors: [Color(0xFF1A1D2E), tdBG],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Título animado
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: Column(
                      children: [
                        // Linha decorativa acima do título
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _dividerLine(),
                            const SizedBox(width: 12),
                            Text(
                              "TAP",
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: tdMainText,
                                letterSpacing: 6,
                                shadows: [
                                  Shadow(
                                    color: tdPrimary.withValues(alpha: 0.6),
                                    blurRadius: 24,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _dividerLine(),
                          ],
                        ),
                        Text(
                          "DASH",
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                              ).createShader(
                                  const Rect.fromLTWH(0, 0, 220, 60)),
                            letterSpacing: 6,
                            shadows: [
                              Shadow(
                                color: tdPrimary.withValues(alpha: 0.5),
                                blurRadius: 28,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "TOQUE. REAJA. SOBREVIVA.",
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 9,
                            letterSpacing: 3,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Botões
                Buttons(
                  texto: "START",
                  cor: tdButtonBG,
                  onTap: () {
                    AudioService.instance.playStart();
                    Navigator.push(
                      context,
                      _fadeRoute(const TapeJogo()),
                    );
                  },
                ),
                Buttons(
                  texto: "PLACAR",
                  cor: tdButtonBG,
                  onTap: () {
                    Navigator.push(
                      context,
                      _fadeRoute(const PontosScreen()),
                    );
                  },
                ),
                Buttons(
                  texto: "SAIR",
                  cor: tdButtonBG,
                  onTap: () {
                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else if (Platform.isLinux || Platform.isWindows) {
                      exit(0);
                    }
                  },
                ),

                const Spacer(flex: 1),

                Text(
                  "v1.0.0",
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Orbitron',
                    color: Colors.white.withValues(alpha: 0.15),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dividerLine() {
    return Container(
      width: 32,
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            tdPrimary.withValues(alpha: 0.6),
          ],
        ),
      ),
    );
  }
}

PageRoute _fadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
  );
}
