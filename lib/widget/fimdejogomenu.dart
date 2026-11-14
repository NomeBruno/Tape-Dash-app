import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tap_dash/pages/pontosscreen.dart';
import 'package:tap_dash/services/audio_service.dart';
import '../pages/tapehome.dart';
import '../pages/tapejogo.dart';

class FimDeJogoMenu extends StatefulWidget {
  final String nomeJogador;
  final int pontos;
  final String tempo;

  const FimDeJogoMenu({
    super.key,
    required this.nomeJogador,
    required this.pontos,
    required this.tempo,
  });

  @override
  State<FimDeJogoMenu> createState() => _FimDeJogoMenuState();
}

class _FimDeJogoMenuState extends State<FimDeJogoMenu> {
  bool _estaSalvando = false;

  Future<void> _salvarNoFirebase() async {
    if (widget.nomeJogador.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite ao menos 3 letras!")),
      );
      return;
    }

    setState(() => _estaSalvando = true);

    try {
      await FirebaseFirestore.instance.collection('ranking').add({
        'jogador': widget.nomeJogador.toUpperCase(),
        'pontos': widget.pontos,
        'tempo': widget.tempo,
        'data': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recorde salvo com sucesso!")),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const PontosScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _estaSalvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLinux = Platform.isLinux;

    return Column(
      children: [
        // Salvar recorde — só disponível fora do Linux
        if (!isLinux) ...[
          _estaSalvando
              ? const SizedBox(
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.cyanAccent),
                  ),
                )
              : _buildBtn("SALVAR RECORDE", Colors.cyanAccent, _salvarNoFirebase),
          const SizedBox(height: 12),
        ],

        _buildBtn("JOGAR DE NOVO", Colors.greenAccent, () {
          AudioService.instance.playStart();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TapeJogo()),
          );
        }),

        const SizedBox(height: 12),

        _buildBtn("VER PLACAR", Colors.blueAccent, () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const PontosScreen()));
        }),

        const SizedBox(height: 12),

        _buildBtn("MENU", Colors.white24, () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const TapeDashHome()),
            (route) => false,
          );
        }),
      ],
    );
  }

  Widget _buildBtn(String texto, Color cor, VoidCallback acao) {
    return _AnimatedOutlineButton(texto: texto, cor: cor, onTap: acao);
  }
}

/// Botão outline com animação de press e som
class _AnimatedOutlineButton extends StatefulWidget {
  final String texto;
  final Color cor;
  final VoidCallback onTap;

  const _AnimatedOutlineButton({
    required this.texto,
    required this.cor,
    required this.onTap,
  });

  @override
  State<_AnimatedOutlineButton> createState() => _AnimatedOutlineButtonState();
}

class _AnimatedOutlineButtonState extends State<_AnimatedOutlineButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        AudioService.instance.playClick();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.cor.withValues(alpha: 0.5),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.texto,
            style: TextStyle(
              fontFamily: 'Orbitron',
              color: widget.cor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 2.5,
            ),
          ),
        ),
      ),
    );
  }
}
