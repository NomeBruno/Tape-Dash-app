import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tap_dash/pages/fimdejogo.dart';
import 'package:tap_dash/services/audio_service.dart';
import '../colors/cor.dart';

class TapeJogo extends StatefulWidget {
  const TapeJogo({super.key});

  @override
  State<TapeJogo> createState() => _TapeJogoState();
}

class _TapeJogoState extends State<TapeJogo> with TickerProviderStateMixin {
  Color corAtiva = Colors.transparent;
  int pontuacao = 0;
  double tempoLimiteMs = 1500.0;
  Timer? gameTimer;
  Timer? cronometroDisplayTimer;
  Stopwatch cronometroGlobal = Stopwatch();
  bool jogoIniciado = false;
  String tempoFormatado = "00:00.00";

  // Progresso da barra de tempo (1.0 = cheio, 0.0 = vazio)
  double _progressoTempo = 1.0;
  Timer? _progressoTimer;

  // Flash de fundo no acerto
  Color _corFundo = tdBG;
  Timer? _flashTimer;

  // Animação de pulso dos alvos
  late AnimationController _pulsoCtrl;
  late Animation<double> _pulsoAnim;

  // Animação de entrada dos alvos (pop-in)
  late AnimationController _entradaCtrl;
  late Animation<double> _entradaAnim;

  // Shake de tela quando o tempo está crítico
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  bool _shakeAtivo = false;

  List<Offset> posicoesAlvos = [const Offset(100, 200)];

  final List<Color> coresDisponiveis = [
    Colors.cyanAccent,
    Colors.purpleAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.pinkAccent,
    Colors.yellowAccent,
    Colors.redAccent,
    Colors.indigoAccent,
    Colors.limeAccent,
    Colors.deepPurpleAccent,
    Colors.deepOrangeAccent,
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    corAtiva = coresDisponiveis[Random().nextInt(coresDisponiveis.length)];

    // Pulso: vai de 1.0 → 1.12 → 1.0 em loop
    _pulsoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..repeat(reverse: true);
    _pulsoAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulsoCtrl, curve: Curves.easeInOut),
    );

    // Entrada: escala 0 → 1 quando um novo alvo aparece
    _entradaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _entradaAnim = CurvedAnimation(parent: _entradaCtrl, curve: Curves.elasticOut);

    // Shake: oscilação horizontal quando tempo está crítico (< 30%)
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
    );
    _shakeAnim = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.linear),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      iniciarRodada();
    });
  }

  void atualizarCronometro() {
    cronometroDisplayTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted && cronometroGlobal.isRunning) {
        setState(() {
          final minutos = cronometroGlobal.elapsed.inMinutes.toString().padLeft(2, '0');
          final segundos = (cronometroGlobal.elapsed.inSeconds % 60).toString().padLeft(2, '0');
          final centesimos =
              ((cronometroGlobal.elapsed.inMilliseconds % 1000) / 10)
                  .toStringAsFixed(0)
                  .padLeft(2, '0');
          tempoFormatado = "$minutos:$segundos.$centesimos";
        });
      }
    });
  }

  void _iniciarProgressoBarra() {
    _progressoTimer?.cancel();
    _shakeAtivo = false;
    _shakeCtrl.stop();

    setState(() => _progressoTempo = 1.0);

    final int intervalMs = 30;
    final int totalSteps = (tempoLimiteMs / intervalMs).ceil();
    int step = 0;

    _progressoTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      step++;
      final double novoProgresso = 1.0 - (step / totalSteps);

      // Ativa shake quando progresso cai abaixo de 30%
      if (novoProgresso < 0.30 && !_shakeAtivo) {
        _shakeAtivo = true;
        _shakeCtrl.repeat(reverse: true);
      }

      setState(() => _progressoTempo = novoProgresso.clamp(0.0, 1.0));

      if (step >= totalSteps) timer.cancel();
    });
  }

  void iniciarRodada() {
    if (!jogoIniciado) {
      cronometroGlobal.start();
      atualizarCronometro();
      jogoIniciado = true;
    }

    final larguraTela = MediaQuery.of(context).size.width - 80;
    final alturaTela = MediaQuery.of(context).size.height - 250;

    setState(() {
      corAtiva = coresDisponiveis[Random().nextInt(coresDisponiveis.length)];
      posicoesAlvos.clear();

      int quantidade = (pontuacao >= 30) ? 2 : 1;

      for (int i = 0; i < quantidade; i++) {
        Offset novaPosicao;
        bool muitoPerto;

        do {
          muitoPerto = false;
          novaPosicao = Offset(
            Random().nextDouble() * larguraTela,
            (Random().nextDouble() * alturaTela) + 150,
          );

          for (var posExistente in posicoesAlvos) {
            if ((novaPosicao - posExistente).distance < 80) {
              muitoPerto = true;
            }
          }
        } while (muitoPerto);

        posicoesAlvos.add(novaPosicao);
      }

      if (pontuacao >= 30 && tempoLimiteMs > 600) {
        tempoLimiteMs -= 20;
      }
    });

    // Animação pop-in dos alvos
    _entradaCtrl.forward(from: 0);

    // Reinicia barra de progresso
    _iniciarProgressoBarra();

    gameTimer?.cancel();
    gameTimer = Timer(Duration(milliseconds: tempoLimiteMs.toInt()), () {
      finalizarJogo();
    });
  }

  void _acertouAlvo(Offset pos) {
    _flashTimer?.cancel();
    AudioService.instance.playHit();

    // Reseta shake
    _shakeAtivo = false;
    _shakeCtrl.stop();
    _shakeCtrl.reset();

    setState(() {
      pontuacao++;
      posicoesAlvos.remove(pos);
    });

    if (posicoesAlvos.isEmpty) {
      iniciarRodada();
    }
  }

  void finalizarJogo() {
    if (!jogoIniciado) return;

    gameTimer?.cancel();
    cronometroDisplayTimer?.cancel();
    _progressoTimer?.cancel();
    _flashTimer?.cancel();
    _shakeCtrl.stop();
    cronometroGlobal.stop();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FimDeJogo(pontos: pontuacao, tempo: tempoFormatado),
        ),
      );
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    gameTimer?.cancel();
    cronometroDisplayTimer?.cancel();
    _progressoTimer?.cancel();
    _flashTimer?.cancel();
    _pulsoCtrl.dispose();
    _entradaCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cor da barra de tempo: verde → amarelo → vermelho
    final Color corBarra = _progressoTempo > 0.5
        ? Color.lerp(Colors.yellowAccent, Colors.cyanAccent,
            (_progressoTempo - 0.5) * 2)!
        : Color.lerp(Colors.redAccent, Colors.yellowAccent,
            _progressoTempo * 2)!;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _shakeAnim,
        builder: (context, child) {
          final double shakeOffset = _shakeAtivo ? _shakeAnim.value : 0.0;
          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: child,
          );
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => finalizarJogo(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: double.infinity,
            height: double.infinity,
            color: _corFundo,
            child: Stack(
              children: [
                // HUD
                Positioned(
                  top: 50,
                  left: 25,
                  right: 25,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _hudItem("PONTOS", "$pontuacao", Colors.cyanAccent),
                      _hudItem("TEMPO", tempoFormatado, Colors.white),
                    ],
                  ),
                ),

                // BARRA DE TEMPO
                Positioned(
                  top: 110,
                  left: 25,
                  right: 25,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 30),
                          height: 6,
                          width: (MediaQuery.of(context).size.width - 50) *
                              _progressoTempo,
                          decoration: BoxDecoration(
                            color: corBarra,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: corBarra.withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ALVOS com pop-in e pulso
                ...posicoesAlvos.map((pos) => Positioned(
                      left: pos.dx,
                      top: pos.dy,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _acertouAlvo(pos),
                        child: ScaleTransition(
                          scale: _entradaAnim,
                          child: AnimatedBuilder(
                            animation: _pulsoAnim,
                            builder: (context, child) => Transform.scale(
                              scale: _pulsoAnim.value,
                              child: child,
                            ),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: corAtiva,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: corAtiva.withValues(alpha: 0.5),
                                    blurRadius: 14,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hudItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Orbitron',
            color: Colors.white24,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Orbitron',
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
