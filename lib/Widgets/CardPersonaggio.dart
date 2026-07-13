import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardPersonaggio extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> dati;

  const CardPersonaggio({
    super.key,
    required this.docId,
    required this.dati,
  });

  @override
  State<CardPersonaggio> createState() => _CardPersonaggioState();
}

class _CardPersonaggioState extends State<CardPersonaggio> {
  bool _isHovered = false;

  int _hoveredStressIndex = 0;
  int _hoveredAssoHashCode = 0;

  Future<void> _aggiornaStressOnline(int nuovoStress) async {
    await FirebaseFirestore.instance
        .collection('personaggi')
        .doc(widget.docId)
        .update({'Stress': nuovoStress});
  }

  Future<void> _aggiornaAssoOnline(String nomeSeme, bool statoAttuale) async {
    await FirebaseFirestore.instance
        .collection('personaggi')
        .doc(widget.docId)
        .update({
      'Assi.$nomeSeme': !statoAttuale,
    });
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = widget.dati['imageUrl'] ?? 'https://via.placeholder.com/220x660';
    final String nome = widget.dati['Nome'] ?? 'Nome Personaggio';

    final String popolo = widget.dati['Popolo'] ?? '';
    final String nazione = widget.dati['Nazione'] ?? '';
    final String professione = widget.dati['Professione'] ?? '';
    final String vocazione = widget.dati['Vocazione'] ?? '';
    final String info = "$popolo $nazione, $professione $vocazione".trim().replaceAll(RegExp(r'\s+'), ' ');

    final int stressAttuale = widget.dati['Stress'] ?? 0;
    final Map<String, dynamic> assiOnline = widget.dati['Assi'] ?? {};

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastEaseInToSlowEaseOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastEaseInToSlowEaseOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.zero,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.5 : 0.3),
                blurRadius: _isHovered ? 16 : 4,
                offset: _isHovered ? const Offset(0, 4) : const Offset(0, 2),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 1 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              clipBehavior: Clip.hardEdge,
              child: Container(
                color: const Color(0xFF000000),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double cardWidth = constraints.maxWidth;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 1. IMMAGINE DI SFONDO
                        Positioned(
                          top: -1, left: -1, right: -1, bottom: -1,
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            placeholder: (context, url) => AspectRatio(
                              aspectRatio: 1, // Mantiene un quadrato perfetto 1:1
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),                            errorWidget: (context, url, error) => Icon(Icons.error),   // Cosa mostrare se fallisce
                            fit: BoxFit.cover,
                          ),
                        ),

                        // 2. GRADIENTE
                        Positioned(
                          top: -1, left: -1, right: -1, bottom: -1,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF000000),
                                ],
                                stops: [0.4, 1],
                              ),
                            ),
                          ),
                        ),

                        // 3. CONTENUTO
                        Positioned(
                          left: 6, right: 6, bottom: 20,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                nome,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: cardWidth * 0.09,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                info.isEmpty ? 'Nessuna specifica' : info,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: cardWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Divider(color: Colors.white30, thickness: 1, height: 16),
                              Text(
                                'Stress',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: cardWidth * 0.06,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // STRESS
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 2,
                                  children: List.generate(12, (index) {
                                    final int valoreQuadratino = index + 1;
                                    final bool isSpecial = index == 7;
                                    final double size = isSpecial ? 18.0 : 14.0;

                                    final bool isAttivo = valoreQuadratino <= stressAttuale;
                                    final bool isHovered = _hoveredStressIndex > 0 && valoreQuadratino <= _hoveredStressIndex;

                                    double opacitaOverlay = 0.0;
                                    if (isAttivo) {
                                      opacitaOverlay = 1.0;
                                    } else if (isHovered) {
                                      opacitaOverlay = 0.5;
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 0.5),
                                      child: SizedBox(
                                        width: size,
                                        height: size,
                                        child: Stack(
                                          children: [
                                            Image.asset(
                                              isSpecial ? "Assets/Stress special vuoto.png" : "Assets/Stress vuoto.png",
                                              fit: BoxFit.contain, width: size, height: size,
                                            ),
                                            AnimatedOpacity(
                                              duration: const Duration(milliseconds: 100),
                                              opacity: opacitaOverlay,
                                              child: Image.asset(
                                                isSpecial ? "Assets/Stress special.png" : "Assets/Stress.png",
                                                fit: BoxFit.contain, width: size, height: size,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),

                              const Divider(color: Colors.white30, thickness: 1, height: 16),
                              Text(
                                'Assi nella manica',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: cardWidth * 0.06,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 9),

                              // ASSI
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final larghezzaTotale = constraints.maxWidth - constraints.maxWidth*0.2;
                                  const double rapportoImmagine = 1247 / 471;
                                  final altezzaTotale = larghezzaTotale / rapportoImmagine;

                                  return SizedBox(
                                    width: larghezzaTotale,
                                    height: altezzaTotale,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Image.asset("Assets/Assi.png", fit: BoxFit.contain),
                                        ),
                                        Positioned(
                                          left: larghezzaTotale * 0.09, top: altezzaTotale * 0.46,
                                          child: _buildBottoneAssoOnline(seme: "Cuori", size: larghezzaTotale * 0.085, assiMap: assiOnline),
                                        ),
                                        Positioned(
                                          left: larghezzaTotale * 0.27, top: altezzaTotale * 0.285,
                                          child: _buildBottoneAssoOnline(seme: "Quadri", size: larghezzaTotale * 0.09, assiMap: assiOnline),
                                        ),
                                        Positioned(
                                          left: larghezzaTotale * 0.453, top: altezzaTotale * 0.23,
                                          child: _buildBottoneAssoOnline(seme: "Fiori", size: larghezzaTotale * 0.095, assiMap: assiOnline),
                                        ),
                                        Positioned(
                                          left: larghezzaTotale * 0.64, top: altezzaTotale * 0.29,
                                          child: _buildBottoneAssoOnline(seme: "Picche", size: larghezzaTotale * 0.09, assiMap: assiOnline),
                                        ),
                                        Positioned(
                                          left: larghezzaTotale * 0.81, top: altezzaTotale * 0.45,
                                          child: _buildBottoneAssoOnline(seme: "Jolly", size: larghezzaTotale * 0.11, assiMap: assiOnline),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottoneAssoOnline({
    required String seme,
    required double size,
    required Map<String, dynamic> assiMap,
  }) {
    final bool isAttivo = assiMap[seme] ?? false;
    final int semeHash = seme.hashCode;
    final bool isHovered = _hoveredAssoHashCode == semeHash;

    double opacita = 0.0;
    if (isAttivo) {
      opacita = 1.0;
    } else if (isHovered) {
      opacita = 0.5;
    }

    final String assetPath = "Assets/$seme assi.png";

    return SizedBox(
      width: size,
      height: size,
      child: ClipRect(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: opacita,
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}