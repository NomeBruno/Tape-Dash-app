import 'package:audioplayers/audioplayers.dart';

/// Serviço singleton de áudio — mantém os players quentes para latência mínima.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _hit = AudioPlayer();
  final AudioPlayer _miss = AudioPlayer();
  final AudioPlayer _click = AudioPlayer();
  final AudioPlayer _start = AudioPlayer();

  Future<void> init() async {
    // Pré-carrega os arquivos reduzindo latência no primeiro toque
    await _hit.setSource(AssetSource('sounds/hit.wav'));
    await _miss.setSource(AssetSource('sounds/miss.wav'));
    await _click.setSource(AssetSource('sounds/menu_click.wav'));
    await _start.setSource(AssetSource('sounds/start.wav'));

    // Volume padrão
    await _hit.setVolume(0.8);
    await _miss.setVolume(0.9);
    await _click.setVolume(0.6);
    await _start.setVolume(0.8);
  }

  Future<void> playHit() async {
    await _hit.seek(Duration.zero);
    await _hit.resume();
  }

  Future<void> playMiss() async {
    await _miss.seek(Duration.zero);
    await _miss.resume();
  }

  Future<void> playClick() async {
    await _click.seek(Duration.zero);
    await _click.resume();
  }

  Future<void> playStart() async {
    await _start.seek(Duration.zero);
    await _start.resume();
  }

  void dispose() {
    _hit.dispose();
    _miss.dispose();
    _click.dispose();
    _start.dispose();
  }
}
