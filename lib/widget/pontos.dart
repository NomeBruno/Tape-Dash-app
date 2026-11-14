import 'package:flutter/material.dart';

class PontosHUD extends StatelessWidget {
  final int pontuacao;
  final String tempo;

  const PontosHUD({
    super.key,
    required this.pontuacao,
    required this.tempo,
  });

  @override
  Widget build(BuildContext context) {
    // Mantém sempre o layout em Row (lado a lado)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildItem("PONTOS", "$pontuacao", Colors.cyanAccent),
        _buildItem("TEMPO", tempo, Colors.white),
      ],
    );
  }

  Widget _buildItem(String label, String valor, Color corValor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinhamento padrão à esquerda
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Orbitron',
            color: Colors.white24,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontFamily: 'Orbitron',
            color: corValor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                // Uso do withOpacity para garantir compatibilidade com o Flutter da QI
                color: corValor.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}