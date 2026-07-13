import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Schedapage extends StatefulWidget {
  final String docId;

  const Schedapage({
    super.key,
    required this.docId,
  });

  @override
  State<Schedapage> createState() => _SchedapageState();
}

class _SchedapageState extends State<Schedapage> {
  final Color backgroundColor = const Color(0xFFE8F5E9);
  int _hoveredBBCIndex = 0;

  String rimuoviPrimaParola(String testo) {
    int primoSpazio = testo.indexOf(' ');
    if (primoSpazio == -1) return "";
    return testo.substring(primoSpazio + 1);
  }

  Future<void> _toggleCondizione(String condizione, bool statoAttuale) async {
    await FirebaseFirestore.instance
        .collection('personaggi')
        .doc(widget.docId)
        .update({
      'Condizioni.$condizione': !statoAttuale,
    });
  }

  Future<void> _toggleContratto1(String condizione, bool statoAttuale) async {
    await FirebaseFirestore.instance
        .collection('personaggi')
        .doc(widget.docId)
        .update({
      'Contratto1.$condizione': !statoAttuale,
    });
  }

  Future<void> _toggleContratto2(String condizione, bool statoAttuale) async {
    await FirebaseFirestore.instance
        .collection('personaggi')
        .doc(widget.docId)
        .update({
      'Contratto2.$condizione': !statoAttuale,
    });
  }

  Future<void> _toggleAssi(String condizione, bool statoAttuale) async {
    await FirebaseFirestore.instance
        .collection('personaggi')
        .doc(widget.docId)
        .update({
      'Assi.$condizione': !statoAttuale,
    });
  }

  Future<void> _toggleManovra1(String condizione, bool statoAttuale) async {
    await FirebaseFirestore.instance
        .collection('personaggi')
        .doc(widget.docId)
        .update({
      'Manovra1.$condizione': !statoAttuale,
    });
  }

  Future<void> _toggleManovra2(String condizione, bool statoAttuale) async {
    await FirebaseFirestore.instance
        .collection('personaggi')
        .doc(widget.docId)
        .update({
      'Manovra2.$condizione': !statoAttuale,
    });
  }

  Future<void> _toggleManovra3(String condizione, bool statoAttuale) async {
    await FirebaseFirestore.instance
        .collection('personaggi')
        .doc(widget.docId)
        .update({
      'Manovra3.$condizione': !statoAttuale,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        width: 40,
        height: 40,
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 25),
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            backgroundColor: Colors.black38,
            shape: const CircleBorder(),
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: AspectRatio(
            aspectRatio: 1523 / 1078,
            child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('personaggi')
                    .doc(widget.docId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text("Errore"));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final Map<String, dynamic> dati = snapshot.data!.data() as Map<String, dynamic>;
                  final dynamic rawEsperienze = dati["Esperienze"];
                  final dynamic rawMemorie = dati["Memorie"];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final Map<String, dynamic> contratto1 = Map<String, dynamic>.from(dati["Contratto1"] ?? {});
                        final Map<String, dynamic> contratto2 = Map<String, dynamic>.from(dati["Contratto2"] ?? {});
                        final Map<String, dynamic> condizioni = Map<String, dynamic>.from(dati["Condizioni"] ?? {});
                        final Map<String, dynamic> Assi = Map<String, dynamic>.from(dati["Assi"] ?? {});
                        final Map<String, dynamic> Manovra1 = Map<String, dynamic>.from(dati["Manovra1"] ?? {});
                        final Map<String, dynamic> Manovra2 = Map<String, dynamic>.from(dati["Manovra2"] ?? {});
                        final Map<String, dynamic> Manovra3 = Map<String, dynamic>.from(dati["Manovra3"] ?? {});
                        final Map<String, dynamic> abilita = Map<String, dynamic>.from(dati["Abilità"] ?? {});
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset('assets/scheda.png', fit: BoxFit.contain),
                            ),

                            // Campi Testo Statici
                            _buildField(constraints, 0.374, 0.825, dati['Nome'] ?? ''),
                            _buildField(constraints, 0.397, 0.825, dati['Popolo'] ?? ''),
                            _buildField(constraints, 0.421, 0.825, rimuoviPrimaParola(dati['Nazione'] ?? '')),
                            _buildField(constraints, 0.445, 0.825, dati['Professione'] ?? ''),
                            _buildField(constraints, 0.469, 0.825, dati['Vocazione'] ?? ''),
                            _buildField(constraints, 0.492, 0.825, dati['Lingue'] ?? ''),


                            // Immagine Personaggio
                            Positioned(
                              top: constraints.maxHeight * 0.0495,
                              left: constraints.maxWidth * 0.759,
                              child: SizedBox(
                                width: constraints.maxWidth * 0.211,
                                height: constraints.maxHeight * 0.2776,
                                child: CachedNetworkImage(
                                  imageUrl: dati["imageUrl"] ?? "",
                                  placeholder: (context, url) => AspectRatio(
                                    aspectRatio: 1, // Mantiene un quadrato perfetto 1:1
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),   // Cosa mostrare se fallisce
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                            ),

                            // Immagine Simbolo
                            Positioned(
                              bottom: constraints.maxHeight * 0.643,
                              left: constraints.maxWidth * 0.8395,
                              child: SizedBox(
                                width: constraints.maxWidth * 0.05,
                                //height: constraints.maxHeight * 0.0976,
                                child: Image.asset("Assets/Simbolo.png"),
                              ),
                            ),

                            // Memorie Dinamiche
                            ..._buildDataList(rawMemorie, constraints, 0.6, 0.78),

                            // Esperienze Dinamiche
                            ..._buildDataList(rawEsperienze, constraints, 0.863, 0.765),

                            // Contratto 1
                            _buildContrattoBox(
                              constraints,
                              0.527,
                              0.535,
                              contratto1["Titolo"] ?? "", // Accesso corretto alla mappa
                              contratto1, // Passiamo tutta la mappa
                            ),

                            ButtonToggle(
                              c: constraints,
                              top: 0.6105,
                              left: 0.521,
                              size: 0.013,
                              nomeCondizione: "Rotto",
                              attivo: contratto1["Rotto"] ?? true,
                              assetPath: "assets/Cerchio.png",
                              onToggle: _toggleContratto1,
                            ),

                            // Contratto 2
                            _buildContrattoBox(
                              constraints,
                              0.766,
                              0.535,
                              contratto2["Titolo"] ?? "", // Accesso corretto alla mappa
                              contratto2, // Passiamo tutta la mappa
                            ),

                            ButtonToggle(
                              c: constraints,
                              top: 0.849,
                              left: 0.521,
                              size: 0.013,
                              nomeCondizione: "Rotto",
                              attivo: contratto2["Rotto"] ?? true,
                              assetPath: "assets/Cerchio.png",
                              onToggle: _toggleContratto2,
                            ),

                            // Condizzioni
                            ButtonToggle(
                              c: constraints,
                              top: 0.335,
                              left: 0.615,
                              size: 0.0085,
                              nomeCondizione: "Umiliato",
                              attivo: condizioni["Umiliato"] ?? true,
                              assetPath: "assets/Cuori.svg",
                              onToggle: _toggleCondizione,
                            ),

                            ButtonToggle(
                              c: constraints,
                              top: 0.3565,
                              left: 0.615,
                              size: 0.0085,
                              nomeCondizione: "Confuso",
                              attivo: condizioni["Confuso"] ?? true,
                              assetPath: "assets/Quadri.svg",
                              onToggle: _toggleCondizione,
                            ),

                            ButtonToggle(
                              c: constraints,
                              top: 0.383,
                              left: 0.614,
                              size: 0.01,
                              nomeCondizione: "Ferito",
                              attivo: condizioni["Ferito"] ?? true,
                              assetPath: "assets/Fiori.svg",
                              onToggle: _toggleCondizione,
                            ),

                            ButtonToggle(
                              c: constraints,
                              top: 0.406,
                              left: 0.616,
                              size: 0.0078,
                              nomeCondizione: "Spaventato",
                              attivo: condizioni["Spaventato"] ?? true,
                              assetPath: "assets/Picche.svg",
                              onToggle: _toggleCondizione,
                            ),

                            ButtonToggle(
                              c: constraints,
                              top: 0.3355,
                              left: 0.721,
                              size: 0.0077,
                              nomeCondizione: "Stanco",
                              attivo: condizioni["Stanco"] ?? true,
                              assetPath: "assets/Quadrato.png",
                              onToggle: _toggleCondizione,
                            ),

                            ButtonToggle(
                              c: constraints,
                              top: 0.36,
                              left: 0.721,
                              size: 0.0077,
                              nomeCondizione: "Malato",
                              attivo: condizioni["Malato"] ?? true,
                              assetPath: "assets/Quadrato.png",
                              onToggle: _toggleCondizione,
                            ),

                            ButtonToggle(
                              c: constraints,
                              top: 0.383,
                              left: 0.721,
                              size: 0.0077,
                              nomeCondizione: "Avvelenato",
                              attivo: condizioni["Avvelenato"] ?? true,
                              assetPath: "assets/Quadrato.png",
                              onToggle: _toggleCondizione,
                            ),

                            ButtonToggle(
                              c: constraints,
                              top: 0.407,
                              left: 0.721,
                              size: 0.0077,
                              nomeCondizione: "Spezzato",
                              attivo: condizioni["Spezzato"] ?? true,
                              assetPath: "assets/Quadrato.png",
                              onToggle: _toggleCondizione,
                            ),

                            // Condizzioni speciali
                            CondizioneToggleSpeciale(
                              c: constraints,
                              top: 0.431, left: 0.721, size: 0.0077,
                              docId: widget.docId,
                              campo: "CondizioneS1",
                              attiva: (dati["CondizioneS1"]?["attiva"] ?? true),
                              assetPath: "assets/Quadrato.png",
                            ),
                            CondizioneNomeInput(
                              c: constraints,
                              top: 0.423, left: 0.528, width: 0.18,
                              docId: widget.docId,
                              campo: "CondizioneS1",
                              nome: (dati["CondizioneS1"]?["nome"] ?? ""),
                            ),

                            CondizioneToggleSpeciale(
                              c: constraints,
                              top: 0.455, left: 0.721, size: 0.0077,
                              docId: widget.docId,
                              campo: "CondizioneS2",
                              attiva: (dati["CondizioneS2"]?["attiva"] ?? true),
                              assetPath: "assets/Quadrato.png",
                            ),
                            CondizioneNomeInput(
                              c: constraints,
                              top: 0.4445, left: 0.528, width: 0.18,
                              docId: widget.docId,
                              campo: "CondizioneS2",
                              nome: (dati["CondizioneS2"]?["nome"] ?? ""),
                            ),

                            // Stress
                            StressBar(
                              c: constraints,
                              top: 0.225,
                              left: 0.5305,
                              size: 0.012,
                              gap: 0.00216,
                              docId: widget.docId,
                              stressAttuale: dati["Stress"] ?? 0,
                            ),

                            // Decoro
                            DecoroButton(c: constraints, top: 0.0938, left: 0.5509, size: 0.0195, valore: 1, decoroAttuale: dati["Decoro"] ?? 0, docId: widget.docId, assetPath: "Assets/Decoro.png"),
                            DecoroButton(c: constraints, top: 0.102, left: 0.5845, size: 0.0195, valore: 2, decoroAttuale: dati["Decoro"] ?? 0, docId: widget.docId, assetPath: "Assets/Decoro.png"),
                            DecoroButton(c: constraints, top: 0.0938, left: 0.6185, size: 0.0195, valore: 3, decoroAttuale: dati["Decoro"] ?? 0, docId: widget.docId, assetPath: "Assets/Decoro.png"),
                            DecoroButton(c: constraints, top: 0.1, left: 0.652, size: 0.0195, valore: 4, decoroAttuale: dati["Decoro"] ?? 0, docId: widget.docId, assetPath: "Assets/Decoro.png"),
                            DecoroButton(c: constraints, top: 0.089, left: 0.6855, size: 0.0195, valore: 5, decoroAttuale: dati["Decoro"] ?? 0, docId: widget.docId, assetPath: "Assets/Decoro.png"),

                            // BBC
                            BBCButton(c: constraints, top: 0.73, left: 0.585, size: 0.013, valore: 1, BBCAttuale: dati["BBC"] ?? 0, hoveredIndex: _hoveredBBCIndex, docId: widget.docId, assetPath: "Assets/Cerchio.png", onHover: (v) => setState(() => _hoveredBBCIndex = v), onExit: () => setState(() => _hoveredBBCIndex = 0)),
                            BBCButton(c: constraints, top: 0.73, left: 0.61, size: 0.013, valore: 2, BBCAttuale: dati["BBC"] ?? 0, hoveredIndex: _hoveredBBCIndex, docId: widget.docId, assetPath: "Assets/Cerchio.png", onHover: (v) => setState(() => _hoveredBBCIndex = v), onExit: () => setState(() => _hoveredBBCIndex = 0)),
                            BBCButton(c: constraints, top: 0.73, left: 0.634, size: 0.013, valore: 3, BBCAttuale: dati["BBC"] ?? 0, hoveredIndex: _hoveredBBCIndex, docId: widget.docId, assetPath: "Assets/Cerchio.png", onHover: (v) => setState(() => _hoveredBBCIndex = v), onExit: () => setState(() => _hoveredBBCIndex = 0)),
                            BBCButton(c: constraints, top: 0.73, left: 0.658, size: 0.013, valore: 4, BBCAttuale: dati["BBC"] ?? 0, hoveredIndex: _hoveredBBCIndex, docId: widget.docId, assetPath: "Assets/Cerchio.png", onHover: (v) => setState(() => _hoveredBBCIndex = v), onExit: () => setState(() => _hoveredBBCIndex = 0)),
                            BBCButton(c: constraints, top: 0.73, left: 0.6825, size: 0.013, valore: 5, BBCAttuale: dati["BBC"] ?? 0, hoveredIndex: _hoveredBBCIndex, docId: widget.docId, assetPath: "Assets/Cerchio.png", onHover: (v) => setState(() => _hoveredBBCIndex = v), onExit: () => setState(() => _hoveredBBCIndex = 0)),

                            // Assi
                            ButtonToggle(
                              c: constraints,
                              top: 0.1233,
                              left: 0.29,
                              size: 0.013,
                              nomeCondizione: "Cuori",
                              attivo: Assi["Cuori"] ?? true,
                              assetPath: "assets/Cuori assi.png",
                              onToggle: _toggleAssi,
                            ),

                            ButtonToggle(
                              c: constraints,
                              top: 0.109,
                              left: 0.319,
                              size: 0.0115,
                              nomeCondizione: "Quadri",
                              attivo: Assi["Quadri"] ?? true,
                              assetPath: "assets/Quadri assi.png",
                              onToggle: _toggleAssi,
                            ),

                            ButtonToggle(
                              c: constraints,
                              top: 0.104,
                              left: 0.346,
                              size: 0.015,
                              nomeCondizione: "Fiori",
                              attivo: Assi["Fiori"] ?? true,
                              assetPath: "assets/Fiori assi.png",
                              onToggle: _toggleAssi,
                            ),

                            ButtonToggle(
                              c: constraints,
                              top: 0.109,
                              left: 0.376,
                              size: 0.013,
                              nomeCondizione: "Picche",
                              attivo: Assi["Picche"] ?? true,
                              assetPath: "assets/Picche assi.png",
                              onToggle: _toggleAssi,
                            ),

                            ButtonToggle(
                              c: constraints,
                              top: 0.1236,
                              left: 0.402,
                              size: 0.0175,
                              nomeCondizione: "Jolly",
                              attivo: Assi["Jolly"] ?? true,
                              assetPath: "assets/Jolly assi.png",
                              onToggle: _toggleAssi,
                            ),

                            // Tratti
                            ..._buildTratti(constraints, 0.233, 0.24, 0.23, dati["Tratti"]),

                            // Manovra 1
                            ..._buildManovra(constraints, 0.53, 0.24, 0.23, dati["Manovra1"]),

                            ButtonToggle(
                              c: constraints,
                              top: 0.551,
                              left: 0.467,
                              size: 0.013,
                              nomeCondizione: "Usata",
                              attivo: Manovra1["Usata"] ?? true,
                              assetPath: "assets/Cerchio.png",
                              onToggle: _toggleManovra1,
                            ),

                            if ((dati["Manovra1"]?["Cuori"] ?? false) == true)
                              _buildImmagineAsset(constraints, 0.5765, 0.423, 0.009, "Assets/Cuori.svg"),
                            if ((dati["Manovra1"]?["Quadri"] ?? false) == true)
                              _buildImmagineAsset(constraints, 0.5755, 0.4355, 0.0085, "Assets/Quadri.svg"),
                            if ((dati["Manovra1"]?["Fiori"] ?? false) == true)
                              _buildImmagineAsset(constraints, 0.5765, 0.447, 0.011, "Assets/Fiori.svg"),
                            if ((dati["Manovra1"]?["Picche"] ?? false) == true)
                              _buildImmagineAsset(constraints, 0.5765, 0.462, 0.009, "Assets/Picche.svg"),


                            // Manovra 2
                            ..._buildManovra(constraints, 0.6126, 0.24, 0.23, dati["Manovra2"]),

                            ButtonToggle(
                              c: constraints,
                              top: 0.635,
                              left: 0.467,
                              size: 0.013,
                              nomeCondizione: "Usata",
                              attivo: Manovra2["Usata"] ?? true,
                              assetPath: "assets/Cerchio.png",
                              onToggle: _toggleManovra2,
                            ),

                            if ((dati["Manovra2"]?["Cuori"] ?? false) == true)
                              _buildImmagineAsset(constraints, 0.66, 0.423, 0.009, "Assets/Cuori.svg"),
                            if ((dati["Manovra2"]?["Quadri"] ?? false) == true)
                              _buildImmagineAsset(constraints, 0.659, 0.4355, 0.0085, "Assets/Quadri.svg"),
                            if ((dati["Manovra2"]?["Fiori"] ?? false) == true)
                              _buildImmagineAsset(constraints, 0.66, 0.447, 0.011, "Assets/Fiori.svg"),
                            if ((dati["Manovra2"]?["Picche"] ?? false) == true)
                              _buildImmagineAsset(constraints, 0.66, 0.462, 0.009, "Assets/Picche.svg"),

                            // Manovra 3
                            ..._buildManovra(constraints, 0.697, 0.24, 0.23, dati["Manovra3"]),

                            ButtonToggle(
                              c: constraints,
                              top: 0.718,
                              left: 0.467,
                              size: 0.013,
                              nomeCondizione: "Usata",
                              attivo: Manovra3["Usata"] ?? true,
                              assetPath: "assets/Cerchio.png",
                              onToggle: _toggleManovra3,
                            ),

                            if ((dati["Manovra3"]?["Cuori"] ?? false) == true)
                              _buildImmagineAsset(constraints, 0.744, 0.423, 0.009, "Assets/Cuori.svg"),
                            if ((dati["Manovra3"]?["Quadri"] ?? false) == true)
                              _buildImmagineAsset(constraints, 0.743, 0.4355, 0.0085, "Assets/Quadri.svg"),
                            if ((dati["Manovra3"]?["Fiori"] ?? false) == true)
                              _buildImmagineAsset(constraints, 0.744, 0.447, 0.011, "Assets/Fiori.svg"),
                            if ((dati["Manovra3"]?["Picche"] ?? false) == true)
                              _buildImmagineAsset(constraints, 0.744, 0.462, 0.009, "Assets/Picche.svg"),

                            // Monete
                            TestoInput(
                              c: constraints,
                              top: 0.789, left: 0.438, width: 0.02,
                              docId: widget.docId,
                              campo: "Monete",
                              valore: dati["Monete"] ?? "",
                            ),

                            // Ricchezza
                            RicchezzaButton(c: constraints, top: 0.791, left: 0.275, size: 0.009, valore: 1, ricchezzaAttuale: dati["Ricchezza"] ?? 0, docId: widget.docId, assetPath: "Assets/Cerchio.png"),
                            RicchezzaButton(c: constraints, top: 0.811, left: 0.275, size: 0.009, valore: 2, ricchezzaAttuale: dati["Ricchezza"] ?? 0, docId: widget.docId, assetPath: "Assets/Cerchio.png"),
                            RicchezzaButton(c: constraints, top: 0.791, left: 0.355, size: 0.009, valore: 3, ricchezzaAttuale: dati["Ricchezza"] ?? 0, docId: widget.docId, assetPath: "Assets/Cerchio.png"),
                            RicchezzaButton(c: constraints, top: 0.811, left: 0.355, size: 0.009, valore: 4, ricchezzaAttuale: dati["Ricchezza"] ?? 0, docId: widget.docId, assetPath: "Assets/Cerchio.png"),

                            // Equipaggiamento
                            EquipaggiamentoInput(c: constraints, top: 0.837, left: 0.038, width: 0.118, docId: widget.docId, campo: "Nome Equipaggiamento", indice: 0, valore: (dati["Nome Equipaggiamento"]?[0] ?? "")),
                            EquipaggiamentoInput(c: constraints, top: 0.8608, left: 0.038, width: 0.118, docId: widget.docId, campo: "Nome Equipaggiamento", indice: 1, valore: (dati["Nome Equipaggiamento"]?[1] ?? "")),
                            EquipaggiamentoInput(c: constraints, top: 0.885, left: 0.038, width: 0.118, docId: widget.docId, campo: "Nome Equipaggiamento", indice: 2, valore: (dati["Nome Equipaggiamento"]?[2] ?? "")),
                            EquipaggiamentoInput(c: constraints, top: 0.908, left: 0.038, width: 0.118, docId: widget.docId, campo: "Nome Equipaggiamento", indice: 3, valore: (dati["Nome Equipaggiamento"]?[3] ?? "")),
                            EquipaggiamentoInput(c: constraints, top: 0.932, left: 0.038, width: 0.118, docId: widget.docId, campo: "Nome Equipaggiamento", indice: 4, valore: (dati["Nome Equipaggiamento"]?[4] ?? "")),

                            EquipaggiamentoInput(c: constraints, top: 0.837, left: 0.17, width: 0.297, docId: widget.docId, campo: "Descrizione Equipaggiamento", indice: 0, valore: (dati["Descrizione Equipaggiamento"]?[0] ?? "")),
                            EquipaggiamentoInput(c: constraints, top: 0.8608, left: 0.17, width: 0.297, docId: widget.docId, campo: "Descrizione Equipaggiamento", indice: 1, valore: (dati["Descrizione Equipaggiamento"]?[1] ?? "")),
                            EquipaggiamentoInput(c: constraints, top: 0.885, left: 0.17, width: 0.297, docId: widget.docId, campo: "Descrizione Equipaggiamento", indice: 2, valore: (dati["Descrizione Equipaggiamento"]?[2] ?? "")),
                            EquipaggiamentoInput(c: constraints, top: 0.908, left: 0.17, width: 0.297, docId: widget.docId, campo: "Descrizione Equipaggiamento", indice: 3, valore: (dati["Descrizione Equipaggiamento"]?[3] ?? "")),
                            EquipaggiamentoInput(c: constraints, top: 0.932, left: 0.17, width: 0.297, docId: widget.docId, campo: "Descrizione Equipaggiamento", indice: 4, valore: (dati["Descrizione Equipaggiamento"]?[4] ?? "")),

                            // Ambiti
                            _buildAmbitoIndicatore(constraints, 0.0535, 0.137, 0.013, dati["Ambiti"], "Società", "Assets/Cuori.svg"),
                            _buildAmbitoIndicatore(constraints, 0.24, 0.137, 0.012, dati["Ambiti"], "Accademia", "Assets/Quadri.svg"),
                            _buildAmbitoIndicatore(constraints, 0.4332, 0.1358, 0.0145, dati["Ambiti"], "Guerra", "Assets/Fiori.svg"),
                            _buildAmbitoIndicatore(constraints, 0.625, 0.1372, 0.012, dati["Ambiti"], "Strada", "Assets/Picche.svg"),

                            // Abilità
                            _buildAbilitaPallini(constraints, 0.084, 0.164, 0.0092, 0.0037, abilita, "Arte", "Assets/Cuori.svg"),
                            _buildAbilitaPallini(constraints, 0.108, 0.164, 0.0092, 0.0037, abilita, "Fascino", "Assets/Cuori.svg"),
                            _buildAbilitaPallini(constraints, 0.132, 0.164, 0.0092, 0.0037, abilita, "Eloquenza", "Assets/Cuori.svg"),
                            _buildAbilitaPallini(constraints, 0.156, 0.164, 0.0092, 0.0037, abilita, "Etichetta", "Assets/Cuori.svg"),
                            _buildAbilitaPallini(constraints, 0.179, 0.164, 0.0092, 0.0037, abilita, "Grazia", "Assets/Cuori.svg"),
                            _buildAbilitaPallini(constraints, 0.2725, 0.163, 0.011, 0.0022, abilita, "Cura", "Assets/Quadri.svg"),
                            _buildAbilitaPallini(constraints, 0.296, 0.163, 0.011, 0.0022, abilita, "Tecnica", "Assets/Quadri.svg"),
                            _buildAbilitaPallini(constraints, 0.32, 0.163, 0.011, 0.0022, abilita, "Cultura", "Assets/Quadri.svg"),
                            _buildAbilitaPallini(constraints, 0.3435, 0.163, 0.011, 0.0022, abilita, "Intuito", "Assets/Quadri.svg"),
                            _buildAbilitaPallini(constraints, 0.368, 0.163, 0.011, 0.0022, abilita, "Indagine", "Assets/Quadri.svg"),
                            _buildAbilitaPallini(constraints, 0.4647, 0.1634, 0.0099, 0.0033, abilita, "Atletica", "Assets/Fiori.svg"),
                            _buildAbilitaPallini(constraints, 0.488, 0.1634, 0.0099, 0.0033, abilita, "Autorità", "Assets/Fiori.svg"),
                            _buildAbilitaPallini(constraints, 0.512, 0.1634, 0.0099, 0.0033, abilita, "Combattimento", "Assets/Fiori.svg"),
                            _buildAbilitaPallini(constraints, 0.536, 0.1634, 0.0099, 0.0033, abilita, "Forza", "Assets/Fiori.svg"),
                            _buildAbilitaPallini(constraints, 0.5595, 0.1634, 0.0099, 0.0033, abilita, "Volontà", "Assets/Fiori.svg"),
                            _buildAbilitaPallini(constraints, 0.6552, 0.1635, 0.0097, 0.0034, abilita, "Cautela", "Assets/Picche.svg"),
                            _buildAbilitaPallini(constraints, 0.679, 0.1635, 0.0097, 0.0034, abilita, "Destrezza", "Assets/Picche.svg"),
                            _buildAbilitaPallini(constraints, 0.703, 0.1635, 0.0097, 0.0034, abilita, "Elusione", "Assets/Picche.svg"),
                            _buildAbilitaPallini(constraints, 0.727, 0.1635, 0.0097, 0.0034, abilita, "Esplorazione", "Assets/Picche.svg"),
                            _buildAbilitaPallini(constraints, 0.751, 0.1635, 0.0097, 0.0034, abilita, "Tiro", "Assets/Picche.svg"),
                          ],
                        );
                      },
                    ),
                  );
                }
            ),
          ),
        ),
      ),
    );
  }


  //TODO:

  // Metodo unico per gestire Map o List e posizionarle nello Stack
  List<Widget> _buildDataList(dynamic data, BoxConstraints c, double startTop, double left) {
    List<Widget> widgets = [];

    if (data is Map) {
      int index = 0;
      data.forEach((key, value) {
        String Chiave = rimuoviPrimaParola(key);
        widgets.add(_posizionaTesto(index, c, startTop, left, "$Chiave: ", value.toString()));
        index++;
      });
    } else if (data is List) {
      for (int i = 0; i < data.length; i++) {
        widgets.add(_posizionaTesto(i, c, startTop, left, "Item ${i + 1}: ", data[i].toString()));
      }
    }
    return widgets;
  }

  Widget _posizionaTesto(int index, BoxConstraints c, double startTop, double left, String label, String value) {
    return Positioned(
      top: c.maxHeight * (startTop + (index * 0.024)),
      left: c.maxWidth * left,
      width: c.maxWidth * 0.202,
      child: RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: TextStyle(fontSize: c.maxWidth * 0.008, color: Colors.black),
          children: [
            TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BoxConstraints c, double top, double left, String text) {
    return Positioned(
      top: c.maxHeight * top,
      left: c.maxWidth * left,
      child: Text(text, style: TextStyle(fontSize: c.maxWidth * 0.009, fontWeight: FontWeight.w600)),
    );
  }
}

Widget _buildContrattoBox(BoxConstraints c, double top, double left, String titolo, Map<String, dynamic> dati) {
  final double fontSize = c.maxWidth * 0.010; // Leggermente aumentato per EB Garamond
  final double lineHeight = c.maxWidth * 0.0162;

  // Stile base usando GoogleFonts.ebGaramond
  final baseStyle = GoogleFonts.ebGaramond(fontSize: fontSize, color: Colors.black, fontWeight: FontWeight.w600);

  return Positioned(
    top: c.maxHeight * top,
    left: c.maxWidth * left,
    width: c.maxWidth * 0.194,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titolo
        Text(titolo, style: GoogleFonts.ebGaramond(fontSize: c.maxWidth * 0.012, fontWeight: FontWeight.bold)),
        SizedBox(height: c.maxHeight * 0.003),

        ...dati.entries.expand((entry) {
          if (entry.key == "Titolo" || entry.key == "Rotto") return [const SizedBox()];

          final List<String> parti = entry.value.toString().split('|');

          return [
            // Riga 1: RichText con font esplicito
            SizedBox(
              height: lineHeight,
              child: RichText(
                text: TextSpan(
                  style: baseStyle, // Applica lo stile base qui
                  children: [
                    TextSpan(
                        text: "${entry.key}: ",
                        style: baseStyle.copyWith(fontWeight: FontWeight.w800) // Grassetto per la chiave
                    ),
                    TextSpan(text: parti[0]),
                  ],
                ),
              ),
            ),

            // Righe successive
            ...List.generate(parti.length - 1, (i) => SizedBox(
              height: lineHeight,
              child: Text(
                parti[i + 1],
                style: baseStyle, // Anche qui usa il font esplicito
                softWrap: false,
                overflow: TextOverflow.visible,
              ),
            )),
            SizedBox(height: c.maxHeight * 0.004),
          ];
        }).toList(),
      ],
    ),
  );
}

List<Widget> _buildTratti(BoxConstraints c, double startTop, double left, double width, dynamic rawTratti) {
  if (rawTratti == null) return [];

  final Map<String, dynamic> tratti = Map<String, dynamic>.from(rawTratti);
  final List<Widget> widgets = [];

  final double fontSize = c.maxWidth * 0.010; // Leggermente più grande per leggibilità
  final double boxWidth = c.maxWidth * width;
  final double lineHeight = c.maxHeight * 0.0215;

  // Stile base EB Garamond con peso w600 per maggiore corposità
  final baseStyle = GoogleFonts.ebGaramond(
      fontSize: fontSize,
      color: Colors.black,
      fontWeight: FontWeight.w600
  );

  double currentTop = c.maxHeight * startTop;

  for (final entry in tratti.entries) {
    final String chiaveCompleta = entry.key;
    final String descrizione = entry.value.toString();
    final int primoSpazio = chiaveCompleta.indexOf(' ');
    final String nome = primoSpazio == -1 ? chiaveCompleta : chiaveCompleta.substring(primoSpazio + 1);

    final List<String> parti = descrizione.split('|');

    // Riga 1: nome (bold) + prima parte
    widgets.add(Positioned(
      top: currentTop,
      left: c.maxWidth * left,
      width: boxWidth,
      child: RichText(
        text: TextSpan(
          style: baseStyle, // Applica lo stile base
          children: [
            TextSpan(
                text: "$nome: ",
                style: baseStyle.copyWith(fontWeight: FontWeight.w800) // Grassetto marcato per il nome
            ),
            TextSpan(text: parti[0]),
          ],
        ),
      ),
    ));
    currentTop += lineHeight;

    // Righe successive
    for (int i = 1; i < parti.length; i++) {
      widgets.add(Positioned(
        top: currentTop,
        left: c.maxWidth * left,
        width: boxWidth,
        child: Text(
          parti[i],
          style: baseStyle, // Applica lo stile base
        ),
      ));
      currentTop += lineHeight;
    }

    currentTop += c.maxHeight * 0.004;
  }

  return widgets;
}

List<Widget> _buildManovra(BoxConstraints c, double startTop, double left, double width, dynamic rawManovra) {
  if (rawManovra == null) return [];

  final Map<String, dynamic> manovra = Map<String, dynamic>.from(rawManovra);
  final List<Widget> widgets = [];

  final double fontSize = c.maxWidth * 0.010;
  final double boxWidth = c.maxWidth * width;
  final double lineHeight = c.maxHeight * 0.0215;

  // Stile base EB Garamond con peso w600 per coerenza
  final baseStyle = GoogleFonts.ebGaramond(
      fontSize: fontSize,
      color: Colors.black,
      fontWeight: FontWeight.w600
  );

  double currentTop = c.maxHeight * startTop;

  for (final entry in manovra.entries) {
    if (entry.key == "Usata" || entry.key == "Cuori" || entry.key == "Quadri" ||
        entry.key == "Fiori" || entry.key == "Picche") continue;

    final String nome = entry.key;
    final String descrizione = entry.value.toString();
    final List<String> parti = descrizione.split('|');

    // Riga 1: Nome (Bold) + Prima parte
    widgets.add(Positioned(
      top: currentTop,
      left: c.maxWidth * left,
      width: boxWidth,
      child: RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(
                text: "$nome: ",
                style: baseStyle.copyWith(fontWeight: FontWeight.w800) // Nome in grassetto marcato
            ),
            TextSpan(text: parti[0]),
          ],
        ),
      ),
    ));
    currentTop += lineHeight;

    // Righe successive
    for (int i = 1; i < parti.length; i++) {
      widgets.add(Positioned(
        top: currentTop,
        left: c.maxWidth * left,
        width: boxWidth,
        child: Text(
          parti[i],
          style: baseStyle, // Usa lo stile base costante
        ),
      ));
      currentTop += lineHeight;
    }

    currentTop += c.maxHeight * 0.004;
  }

  return widgets;
}

Widget _buildImmagineAsset(BoxConstraints c, double top, double left, double size, String assetPath) {
  return Positioned(
    top: c.maxHeight * top,
    left: c.maxWidth * left,
    width: c.maxWidth * size,
    child: SvgPicture.asset(assetPath, fit: BoxFit.contain),
  );
}

Widget _buildAmbitoIndicatore(BoxConstraints c, double top, double left, double size, dynamic rawAmbiti, String chiave, String assetPath) {
  final Map<String, dynamic> ambiti = Map<String, dynamic>.from(rawAmbiti ?? {});
  final int valore = ambiti[chiave] ?? 0;

  if (valore != 2) return const SizedBox();

  return Positioned(
    top: c.maxHeight * top,
    left: c.maxWidth * left,
    width: c.maxWidth * size,
    child: SvgPicture.asset(assetPath, fit: BoxFit.contain),
  );
}

Widget _buildAbilitaPallini(BoxConstraints c, double top, double left, double size, double gap, Map<String, dynamic> abilita, String chiave, String assetPath) {
  final int valore = abilita[chiave] ?? 1;
  final int numeroPallini = valore - 1;

  if (numeroPallini <= 0) return const SizedBox();

  return Positioned(
    top: c.maxHeight * top,
    left: c.maxWidth * left,
    child: Row(
      children: List.generate(numeroPallini, (index) {
        return Padding(
          padding: EdgeInsets.only(right: c.maxWidth * gap),
          child: SizedBox(
            width: c.maxWidth * size,
            height: c.maxWidth * size,
            child: SvgPicture.asset(assetPath, fit: BoxFit.contain),
          ),
        );
      }),
    ),
  );
}

class ButtonToggle extends StatefulWidget {
  final BoxConstraints c;
  final double top;
  final double left;
  final double size;
  final String nomeCondizione;
  final bool attivo;
  final String assetPath;
  final Future<void> Function(String, bool) onToggle;

  const ButtonToggle({
    super.key,
    required this.c,
    required this.top,
    required this.left,
    required this.size,
    required this.nomeCondizione,
    required this.attivo,
    required this.assetPath,
    required this.onToggle,
  });

  @override
  State<ButtonToggle> createState() => _ButtonToggleState();
}

class _ButtonToggleState extends State<ButtonToggle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final double opacity = widget.attivo
        ? 1.0
        : (_hovered ? 0.5 : 0.0);

    final bool isSvg = widget.assetPath.toLowerCase().endsWith('.svg');
    final double size = widget.c.maxWidth * widget.size;

    return Positioned(
      top: widget.c.maxHeight * widget.top,
      left: widget.c.maxWidth * widget.left,
      child: GestureDetector(
        onTap: () => widget.onToggle(widget.nomeCondizione, widget.attivo),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: SizedBox(
            width: size,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: opacity,
              child: isSvg
                  ? SvgPicture.asset(widget.assetPath)
                  : Image.asset(widget.assetPath),
            ),
          ),
        ),
      ),
    );
  }
}

class CondizioneToggleSpeciale extends StatefulWidget {
  final BoxConstraints c;
  final double top;
  final double left;
  final double size;
  final String docId;
  final String campo; // "CondizioneS1" o "CondizioneS2"
  final bool attiva;
  final String assetPath;

  const CondizioneToggleSpeciale({
    super.key,
    required this.c,
    required this.top,
    required this.left,
    required this.size,
    required this.docId,
    required this.campo,
    required this.attiva,
    required this.assetPath,
  });

  @override
  State<CondizioneToggleSpeciale> createState() => _CondizioneToggleSpecialeState();
}

class _CondizioneToggleSpecialeState extends State<CondizioneToggleSpeciale> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final double opacity = widget.attiva
        ? 1.0
        : (_hovered ? 0.5 : 0.0);

    return Positioned(
      top: widget.c.maxHeight * widget.top,
      left: widget.c.maxWidth * widget.left,
      child: GestureDetector(
        onTap: () => FirebaseFirestore.instance
            .collection('personaggi')
            .doc(widget.docId)
            .update({'${widget.campo}.attiva': !widget.attiva}),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: SizedBox(
            width: widget.c.maxWidth * widget.size,
            child: Opacity(
              opacity: opacity,
              child: Image.asset(widget.assetPath),
            ),
          ),
        ),
      ),
    );
  }
}

class CondizioneNomeInput extends StatefulWidget {
  final BoxConstraints c;
  final double top;
  final double left;
  final double width;
  final String docId;
  final String campo;
  final String nome;

  const CondizioneNomeInput({
    super.key,
    required this.c,
    required this.top,
    required this.left,
    required this.width,
    required this.docId,
    required this.campo,
    required this.nome,
  });

  @override
  State<CondizioneNomeInput> createState() => _CondizioneNomeInputState();
}

class _CondizioneNomeInputState extends State<CondizioneNomeInput> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.nome);
  }

  @override
  void didUpdateWidget(CondizioneNomeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nome != widget.nome && !_controller.selection.isValid) {
      _controller.text = widget.nome;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String valore) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      FirebaseFirestore.instance
          .collection('personaggi')
          .doc(widget.docId)
          .update({'${widget.campo}.nome': valore});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.c.maxHeight * widget.top,
      left: widget.c.maxWidth * widget.left,
      width: widget.c.maxWidth * widget.width,
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        textCapitalization: TextCapitalization.characters,
        style: TextStyle(fontSize: widget.c.maxWidth * 0.01, fontWeight: FontWeight.w800),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 2),
        ),
      ),
    );
  }
}

class StressBar extends StatefulWidget {
  final BoxConstraints c;
  final double top;
  final double left;
  final double size;
  final double gap;
  final int stressAttuale;
  final String docId;

  const StressBar({
    super.key,
    required this.c,
    required this.top,
    required this.left,
    required this.size,
    required this.gap,
    required this.stressAttuale,
    required this.docId,
  });

  @override
  State<StressBar> createState() => _StressBarState();
}

class _StressBarState extends State<StressBar> {
  int _hoveredIndex = 0;

  Future<void> _aggiornaStress(int nuovoValore) async {
    await FirebaseFirestore.instance
        .collection('personaggi')
        .doc(widget.docId)
        .update({'Stress': nuovoValore});
  }

  @override
  Widget build(BuildContext context) {
    final double baseSize = widget.c.maxWidth * widget.size;
    final double specialSize = baseSize * 1.15;
    final double gap = widget.c.maxWidth * widget.gap;

    return Positioned(
      top: widget.c.maxHeight * widget.top,
      left: widget.c.maxWidth * widget.left,
      child: Row(
        //mainAxisSize: MainAxisSize.min,
        children: List.generate(12, (index) {
          final bool isSpecial = index == 7;
          final int valore = index + 1;
          final double size = isSpecial ? specialSize : baseSize;

          final bool isAttivo = valore <= widget.stressAttuale;
          final bool isHovered = _hoveredIndex > 0 && valore <= _hoveredIndex;
          final double opacity = isAttivo ? 1.0 : (isHovered ? 0.5 : 0.0);

          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = valore),
            onExit: (_) => setState(() => _hoveredIndex = 0),
            cursor: SystemMouseCursors.click,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gap),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final int nuovo = widget.stressAttuale == valore ? valore - 1 : valore;
                  _aggiornaStress(nuovo);
                },
                child: SizedBox(
                  width: size,
                  height: size,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 100),
                    opacity: opacity,
                    child: Image.asset(
                      isSpecial ? "Assets/Stress special.png" : "Assets/Stress.png",
                      fit: BoxFit.contain,
                      width: size,
                      height: size,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class DecoroButton extends StatefulWidget {
  final BoxConstraints c;
  final double top;
  final double left;
  final double size;
  final int valore;        // 1-5, il valore di questo pulsante
  final int decoroAttuale;
  final String docId;
  final String assetPath;

  const DecoroButton({
    super.key,
    required this.c,
    required this.top,
    required this.left,
    required this.size,
    required this.valore,
    required this.decoroAttuale,
    required this.docId,
    required this.assetPath,
  });

  @override
  State<DecoroButton> createState() => _DecoroButtonState();
}

class _DecoroButtonState extends State<DecoroButton> {
  bool _hovered = false;

  Future<void> _aggiornaDecoro() async {
    final int nuovo = widget.decoroAttuale == widget.valore
        ? widget.valore - 1
        : widget.valore;
    await FirebaseFirestore.instance
        .collection('personaggi')
        .doc(widget.docId)
        .update({'Decoro': nuovo});
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.c.maxWidth * widget.size;

    final bool isAttivo = widget.valore <= widget.decoroAttuale;
    final bool isHovered = !isAttivo && _hovered;
    final double opacity = isAttivo ? 1.0 : (isHovered ? 0.5 : 0.0);

    return Positioned(
      top: widget.c.maxHeight * widget.top,
      left: widget.c.maxWidth * widget.left,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: _aggiornaDecoro,
          child: SizedBox(
            width: size,
            height: size,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: opacity,
              child: Image.asset(widget.assetPath, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

class BBCButton extends StatelessWidget {
  final BoxConstraints c;
  final double top;
  final double left;
  final double size;
  final int valore;
  final int BBCAttuale;
  final int hoveredIndex;  // ← dal parent
  final String docId;
  final String assetPath;
  final ValueChanged<int> onHover;   // ← notifica al parent
  final VoidCallback onExit;

  const BBCButton({
    super.key,
    required this.c,
    required this.top,
    required this.left,
    required this.size,
    required this.valore,
    required this.BBCAttuale,
    required this.hoveredIndex,
    required this.docId,
    required this.assetPath,
    required this.onHover,
    required this.onExit,
  });

  Future<void> _aggiorna() async {
    final int nuovo = BBCAttuale == valore ? valore - 1 : valore;
    await FirebaseFirestore.instance
        .collection('personaggi')
        .doc(docId)
        .update({'BBC': nuovo});
  }

  @override
  Widget build(BuildContext context) {
    final double s = c.maxWidth * size;

    final bool isAttivo = valore <= BBCAttuale;
    final bool isHovered = !isAttivo && valore <= hoveredIndex;
    final double opacity = isAttivo ? 0.7 : (isHovered ? 0.5 : 0.0);

    return Positioned(
      top: c.maxHeight * top,
      left: c.maxWidth * left,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => onHover(valore),
        onExit: (_) => onExit(),
        child: GestureDetector(
          onTap: _aggiorna,
          child: SizedBox(
            width: s,
            height: s,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: opacity,
              child: Image.asset(assetPath, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

class TestoInput extends StatefulWidget {
  final BoxConstraints c;
  final double top;
  final double left;
  final double width;
  final String docId;
  final String campo;
  final String valore;

  const TestoInput({
    super.key,
    required this.c,
    required this.top,
    required this.left,
    required this.width,
    required this.docId,
    required this.campo,
    required this.valore,
  });

  @override
  State<TestoInput> createState() => _TestoInputState();
}

class _TestoInputState extends State<TestoInput> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.valore);
  }

  @override
  void didUpdateWidget(TestoInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valore != widget.valore && !_controller.selection.isValid) {
      _controller.text = widget.valore;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String valore) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      FirebaseFirestore.instance
          .collection('personaggi')
          .doc(widget.docId)
          .update({widget.campo: valore});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.c.maxHeight * widget.top,
      left: widget.c.maxWidth * widget.left,
      width: widget.c.maxWidth * widget.width,
      child: TextField(
        textAlign: TextAlign.center,
        controller: _controller,
        onChanged: _onChanged,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(fontSize: widget.c.maxWidth * 0.015, fontWeight: FontWeight.w600),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 2),
        ),
      ),
    );
  }
}

class RicchezzaButton extends StatefulWidget {
  final BoxConstraints c;
  final double top;
  final double left;
  final double size;
  final int valore;        // 1-4
  final int ricchezzaAttuale;
  final String docId;
  final String assetPath;

  const RicchezzaButton({
    super.key,
    required this.c,
    required this.top,
    required this.left,
    required this.size,
    required this.valore,
    required this.ricchezzaAttuale,
    required this.docId,
    required this.assetPath,
  });

  @override
  State<RicchezzaButton> createState() => _RicchezzaButtonState();
}

class _RicchezzaButtonState extends State<RicchezzaButton> {
  bool _hovered = false;

  Future<void> _aggiornaRicchezza() async {
    final int nuovo = widget.ricchezzaAttuale == widget.valore
        ? 0
        : widget.valore;
    await FirebaseFirestore.instance
        .collection('personaggi')
        .doc(widget.docId)
        .update({'Ricchezza': nuovo});
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.c.maxWidth * widget.size;

    final bool isAttivo = widget.valore == widget.ricchezzaAttuale;
    final bool isHovered = !isAttivo && _hovered;
    final double opacity = isAttivo ? 1.0 : (isHovered ? 0.5 : 0.0);

    return Positioned(
      top: widget.c.maxHeight * widget.top,
      left: widget.c.maxWidth * widget.left,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: _aggiornaRicchezza,
          child: SizedBox(
            width: size,
            height: size,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: opacity,
              child: Image.asset(widget.assetPath, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

class EquipaggiamentoInput extends StatefulWidget {
  final BoxConstraints c;
  final double top;
  final double left;
  final double width;
  final String docId;
  final String campo; // "Nome Equipaggiamento" o "Descrizione Equipaggiamento"
  final int indice;    // 0-4
  final String valore;

  const EquipaggiamentoInput({
    super.key,
    required this.c,
    required this.top,
    required this.left,
    required this.width,
    required this.docId,
    required this.campo,
    required this.indice,
    required this.valore,
  });

  @override
  State<EquipaggiamentoInput> createState() => _EquipaggiamentoInputState();
}

class _EquipaggiamentoInputState extends State<EquipaggiamentoInput> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.valore);
  }

  @override
  void didUpdateWidget(EquipaggiamentoInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Aggiorna il testo solo se il valore dal DB è cambiato e l'utente non sta digitando
    if (oldWidget.valore != widget.valore && _controller.text != widget.valore) {
      final cursorPosition = _controller.selection;
      _controller.text = widget.valore;

      // Ripristina la posizione del cursore
      _controller.selection = cursorPosition.copyWith(
        baseOffset: cursorPosition.baseOffset.clamp(0, widget.valore.length),
        extentOffset: cursorPosition.extentOffset.clamp(0, widget.valore.length),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String valore) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      final docRef = FirebaseFirestore.instance.collection('personaggi').doc(widget.docId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        List<dynamic> array = List<dynamic>.from(snapshot.data()?[widget.campo] ?? List.filled(5, ""));

        // Verifica di sicurezza lunghezza
        while (array.length < 5) array.add("");

        array[widget.indice] = valore;
        transaction.update(docRef, {widget.campo: array});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.c.maxHeight * widget.top,
      left: widget.c.maxWidth * widget.left,
      width: widget.c.maxWidth * widget.width,
      child: TextField(
        textAlign: widget.campo == "Nome Equipaggiamento" ? TextAlign.center : TextAlign.start,
        controller: _controller,
        onChanged: _onChanged,
        // Usiamo esplicitamente GoogleFonts per coerenza totale
        style: GoogleFonts.ebGaramond(
          fontSize: widget.c.maxWidth * 0.011,
          // Usiamo w800 per il titolo (molto marcato) e w600 per la descrizione (spesso ma elegante)
          fontWeight: widget.campo == "Nome Equipaggiamento" ? FontWeight.w800 : FontWeight.w600,
          color: Colors.black,
        ),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 2),
        ),
      ),
    );
  }
}