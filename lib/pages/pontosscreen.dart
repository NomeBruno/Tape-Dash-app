import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para ler os dados
import 'package:tap_dash/colors/cor.dart';
import 'package:tap_dash/pages/tapehome.dart';
import 'package:tap_dash/widget/homemenu.dart';

class PontosScreen extends StatelessWidget {
  const PontosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF1A1A2E), Colors.black],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            children: [
              const Text(
                "TOP 10",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: tdMainText,
                  fontSize: 48,
                  letterSpacing: 2.0,
                  fontFamily: 'Orbitron',
                ),
              ),
              const SizedBox(height: 20),

              // LISTA DE PONTUAÇÃO EM TEMPO REAL
              Expanded(
                child: Platform.isLinux
                    // Firebase não suporta Linux: exibe aviso amigável
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off, color: Colors.white38, size: 48),
                            SizedBox(height: 16),
                            Text(
                              "Placar online não\ndisponível no Linux",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                color: Colors.white38,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : StreamBuilder<QuerySnapshot>(
                        // Busca no Firebase ordenando pelos maiores pontos
                        stream: FirebaseFirestore.instance
                            .collection('ranking')
                            .orderBy('pontos', descending: true)
                            .limit(10)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                                child: Text("Erro ao carregar",
                                    style: TextStyle(color: Colors.red)));
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.cyanAccent));
                          }

                          final dados = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: dados.length,
                            itemBuilder: (context, index) {
                              var item = dados[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${index + 1}. ${item['jogador']}",
                                      style: const TextStyle(
                                          fontFamily: 'Orbitron',
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text("${item['pontos']} PTS",
                                            style: const TextStyle(
                                                color: Colors.cyanAccent,
                                                fontWeight:
                                                    FontWeight.bold)),
                                        Text(item['tempo'],
                                            style: const TextStyle(
                                                color: Colors.white38,
                                                fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),

              Buttons(
                texto: "VOLTAR",
                cor: tdButtonBG,
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TapeDashHome()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
