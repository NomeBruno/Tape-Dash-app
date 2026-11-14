import 'package:flutter/material.dart';
import 'package:tap_dash/colors/cor.dart';
import 'package:tap_dash/services/audio_service.dart';

class Buttons extends StatefulWidget {
  final String texto;
  final Color cor;
  final VoidCallback onTap;

  const Buttons({
    super.key,
    required this.texto,
    required this.cor,
    required this.onTap,
  });

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.forward();

  void _onTapUp(_) {
    _ctrl.reverse();
    AudioService.instance.playClick();
    widget.onTap();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) => Transform.scale(
            scale: _scale.value,
            child: child,
          ),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: tdPrimary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              widget.texto.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: tdMainText,
                letterSpacing: 3.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
