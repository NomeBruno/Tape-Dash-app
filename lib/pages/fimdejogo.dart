import 'package:flutter/material.dart';
import 'package:tap_dash/colors/cor.dart';
import 'package:tap_dash/services/audio_service.dart';
import 'package:tap_dash/widget/fimdejogomenu.dart';

class FimDeJogo extends StatefulWidget {
  final int pontos;
  final String tempo;

  const FimDeJogo({super.key, required this.pontos, required this.tempo});

  @override
  State<FimDeJogo> createState() => _FimDeJogoState();
}

class _FimDeJogoState extends State<FimDeJogo>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nomeController = TextEditingController();

  late AnimationController _entradaCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _nomeController.addListener(() => setState(() {}));

    _entradaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _entradaCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entradaCtrl, curve: Curves.easeOut));

    // Toca o som de game over e anima a tela
    AudioService.instance.playMiss();
    _entradaCtrl.forward();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _entradaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBG,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.3,
            colors: [Color(0xFF1F0A0A), tdBG],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Título GAME OVER
                    Text(
                      "GAME",
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withValues(alpha: 0.08),
                        letterSpacing: 6,
                        height: 1,
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFF4E4E), Color(0xFFFF9A3C)],
                      ).createShader(bounds),
                      child: const Text(
                        "OVER",
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 6,
                          height: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Cards de estatística
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            "PONTOS",
                            widget.pontos.toString(),
                            Colors.cyanAccent,
                            Icons.star_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            "TEMPO",
                            widget.tempo,
                            Colors.orangeAccent,
                            Icons.timer_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Campo de nome
                    Text(
                      "SEU NOME",
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 11,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 240,
                      child: TextField(
                        controller: _nomeController,
                        maxLength: 5,
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          color: Colors.cyanAccent,
                          fontSize: 30,
                          letterSpacing: 10,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: "_ _ _",
                          hintStyle: TextStyle(
                            fontFamily: 'Orbitron',
                            color: Colors.white.withValues(alpha: 0.1),
                            fontSize: 30,
                            letterSpacing: 10,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.cyanAccent, width: 2),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    FimDeJogoMenu(
                      nomeJogador: _nomeController.text,
                      pontos: widget.pontos,
                      tempo: widget.tempo,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color accent, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: accent.withValues(alpha: 0.7), size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              color: accent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Orbitron',
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
