import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../LogicaTiri.dart';

class Chatcolumn extends StatefulWidget {
  final List<QueryDocumentSnapshot> listaPersonaggi;
  final CollectionReference chatRef;

  const Chatcolumn({super.key, required this.listaPersonaggi, required this.chatRef});

  @override
  State<Chatcolumn> createState() => _ChatcolumnState();
}

class _ChatcolumnState extends State<Chatcolumn> {
  String? _personaggioId;
  String? _ambito;
  String? _abilita;
  int _numeroDadi = 0;

  static const Map<int, String> mappaRisultati = {
    1: "Cuori.png", 2: "Quadri.png", 3: "Fiori.png", 4: "Picche.png", 5: "Jolly.png", 6: "Chiave.png"
  };

  final Map<String, String> _mappaIcone = {
    "Società": "Cuori.png", "Accademia": "Quadri.png", "Guerra": "Fiori.png", "Strada": "Picche.png",
    "Arte": "Cuori.png", "Fascino": "Cuori.png", "Eloquenza": "Cuori.png", "Etichetta": "Cuori.png", "Grazia": "Cuori.png",
    "Cura": "Quadri.png", "Tecnica": "Quadri.png", "Cultura": "Quadri.png", "Intuito": "Quadri.png", "Indagine": "Quadri.png",
    "Atletica": "Fiori.png", "Autorità": "Fiori.png", "Combattimento": "Fiori.png", "Forza": "Fiori.png", "Volontà": "Fiori.png",
    "Cautela": "Picche.png", "Destrezza": "Picche.png", "Elusione": "Picche.png", "Esplorazione": "Picche.png", "Tiro": "Picche.png",
  };

  final List<String> _ambiti = ["Società", "Accademia", "Guerra", "Strada"];
  final List<String> _abilitaList = [
    "Arte", "Fascino", "Eloquenza", "Etichetta", "Grazia",
    "Cura", "Tecnica", "Cultura", "Intuito", "Indagine",
    "Atletica", "Autorità", "Combattimento", "Forza", "Volontà",
    "Cautela", "Destrezza", "Elusione", "Esplorazione", "Tiro"
  ];

  DocumentSnapshot? get _personaggioDoc {
    if (_personaggioId == null) return null;
    return widget.listaPersonaggi.firstWhere((p) => p.id == _personaggioId);
  }

  int _getBonus(String categoria, String nome) {
    if (_personaggioDoc == null) return 0;
    final data = _personaggioDoc!.data() as Map<String, dynamic>;
    final mappa = data[categoria] as Map<String, dynamic>? ?? {};
    return (mappa[nome] as num?)?.toInt() ?? 0;
  }

  bool _isRitiraInSicurezza(String abilita, Map<String, dynamic> data) {
    final List<dynamic>? listaSicure = data['RitiraInSicurezza'] as List<dynamic>?;
    return listaSicure?.contains(abilita) ?? false;
  }

  Future<void> _inviaTiro() async {
    if (_personaggioId == null || _ambito == null || _abilita == null || _personaggioDoc == null) return;

    final data = _personaggioDoc!.data() as Map<String, dynamic>;
    final String nomePersonaggio = data['Nome'] ?? "Sconosciuto";
    final int bonusAmbito = _getBonus('Ambiti', _ambito!);
    final int bonusAbilita = _getBonus('Abilità', _abilita!);
    int totaleDadi = bonusAmbito + bonusAbilita + _numeroDadi;

    if (totaleDadi>9) {
      totaleDadi = 9;
    }
    if (totaleDadi < 0) totaleDadi = 0;

    final Random random = Random();
    List<int> risultatiDadi = List.generate(totaleDadi, (_) => random.nextInt(6) + 1);
    final analisi = LogicaTiri.analizzaRisultato(risultatiDadi);
    risultatiDadi.sort();

    bool haSuccessi = (analisi["successi"] as Map).values.any((v) => v > 0);

    bool puoRitirare = (analisi["dadiRitirabili"] ?? 0) > 0 && haSuccessi;

    final String testoMessaggio = "$nomePersonaggio tira per $_ambito ($bonusAmbito) + $_abilita ($bonusAbilita) + ($_numeroDadi) = $totaleDadi dadi.";

    await widget.chatRef.add({
      "timestamp": FieldValue.serverTimestamp(),
      "testo": testoMessaggio,
      "personaggio": nomePersonaggio,
      "risultati": risultatiDadi,
      "analisi": analisi,
      "ritira": puoRitirare,
      //"ritiraInSicurezza": puoRitirareInSicurezza,
      "tipo": "Primo",
      "tuttooNiente": false,
    });

    setState(() {
      //_ambito = null;
      //_abilita = null;
      //_numeroDadi = 0;
    });
  }

  Widget _buildRiepilogoRisultati(Map<dynamic, dynamic> successi) {
    List<String> dettagli = [];
    successi.forEach((key, value) {
      if (value > 0) dettagli.add("$key: $value");
    });

    return Text(
      dettagli.isNotEmpty ? dettagli.join(" | ") : "Nessun successo",
      style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
    );
  }

  int _calcolaPunteggioPesato(Map<dynamic, dynamic> successi) {
    // Funzione locale per estrarre un intero in modo sicuro
    int getVal(String key) {
      var val = successi[key];
      if (val == null) return 0;
      // Se è un numero, lo convertiamo in intero.
      // Se è già un intero, non succede nulla.
      if (val is num) return val.toInt();
      return 0;
    }

    int punteggio = 0;
    punteggio += getVal("Base") * 1;
    punteggio += getVal("Critico") * 3;
    punteggio += getVal("Estremo") * 9;
    punteggio += getVal("Impossibile") * 27;
    punteggio += getVal("Successone") * 81;

    return punteggio;
  }

  Future<void> _eseguiRitiro(DocumentSnapshot doc, String tipoRitiro) async {

    await doc.reference.update({"usato": true});

    final data = doc.data() as Map<String, dynamic>;
    final List<int> vecchiRisultati = (data["risultati"] as List).map((e) => e as int).toList();
    final Map<String, dynamic> vecchiSuccessi = Map<String, dynamic>.from(data["analisi"]["successi"]);

    // 1. Identifica i dadi da tenere e quelli da ritirare
    final List<int> frequenze = (data["analisi"]["frequenze"] as List).map((e) => e as int).toList();
    List<int> nuoviDadiDaTirare = [];
    List<int> dadiDaTenere = [];

    for (int f = 0; f < 6; f++) {
      if (frequenze[f] == 1) {
        nuoviDadiDaTirare.add(f + 1); // Dadi con frequenza 1 da ritirare
      } else {
        for (int k = 0; k < frequenze[f]; k++) dadiDaTenere.add(f + 1);
      }
    }

    // 2. Tira i nuovi dadi
    final Random random = Random();
    List<int> nuoviTiri = List.generate(nuoviDadiDaTirare.length, (_) => random.nextInt(6) + 1);
    List<int> risultatiFinali = [...dadiDaTenere, ...nuoviTiri];

    // 3. Analisi
    final nuovaAnalisi = LogicaTiri.analizzaRisultato(risultatiFinali);
    final Map<String, dynamic> nuoviSuccessi = nuovaAnalisi["successi"];
    risultatiFinali.sort();


    // 4. Logica semplificata: confronta il totale dei successi pesati
    int totaleVecchi = _calcolaPunteggioPesato(vecchiSuccessi);
    int totaleNuovi = _calcolaPunteggioPesato(nuovaAnalisi["successi"]);
    bool migliorato = totaleNuovi > totaleVecchi;

    // 5. Invio nuovo messaggio di rilancio
    bool perdite = !migliorato && (tipoRitiro != "Ritira in Sicurezza");
    bool eraGiaTuttooNiente = data["tuttooNiente"] ?? false;
    bool abilitaTuttooNiente = migliorato && !eraGiaTuttooNiente && nuovaAnalisi["dadiRitirabili"]!=0;

    bool haSuccessi = (nuovaAnalisi["successi"] as Map).values.any((v) => v > 0);
    bool puoRitirare = (nuovaAnalisi["dadiRitirabili"] ?? 0) > 0 && haSuccessi;


    await widget.chatRef.add({
      "timestamp": FieldValue.serverTimestamp(),
      "testo": "$tipoRitiro: Risultato ${migliorato ? "Migliorato" : "Invariato"}",
      "personaggio": data["personaggio"],
      "risultati": risultatiFinali,
      "analisi": nuovaAnalisi,
      "Perdite": perdite,
      "tuttooNiente": abilitaTuttooNiente, // Il tutto per tutto è disponibile se il risultato è migliorato
      "ritira": puoRitirare, // Il rilancio non si può rilanciare (a meno che non sia tutto per tutto)
      "tipo": tipoRitiro
    });
  }

  Future<void> _cancellaTuttaLaChat() async {
    // Recupera tutti i documenti della collezione
    final snapshot = await widget.chatRef.get();

    // Crea un batch per cancellare tutto in una sola operazione (molto più veloce)
    final batch = FirebaseFirestore.instance.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    // Esegui la cancellazione
    await batch.commit();
  }

  DropdownMenuItem<String> _buildMenuItem(String nome) {
    return DropdownMenuItem(
      value: nome,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 16, height: 16, child: Image.asset('assets/${_mappaIcone[nome]}')),
          const SizedBox(width: 8),
          Expanded(child: Text(nome, style: const TextStyle(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_personaggioId != null && !widget.listaPersonaggi.any((p) => p.id == _personaggioId)) {
      _personaggioId = null;
    }
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: widget.chatRef.orderBy('timestamp', descending: true).limit(20).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final messaggi = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 20),
                    reverse: true,
                    itemCount: messaggi.length,
                    itemBuilder: (context, i) {
                      final data = messaggi[i].data() as Map<String, dynamic>;
                      final risultati = (data["risultati"] as List<dynamic>?)?.map((e) => e as int).toList() ?? [];

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nome personaggio e Timestamp
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(data['personaggio'] ?? "Sconosciuto", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                if (data['timestamp'] != null)
                                  Text(
                                    (data['timestamp'] as Timestamp).toDate().toString().substring(11, 16),
                                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Testo del tiro
                            Text(data['testo'] ?? "", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 10),
                            // Dadi
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 6, runSpacing: 6,
                              children: risultati.map((r) => Container(
                                width: 30, height: 30,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                                child: Padding(padding: const EdgeInsets.all(4.0), child: Image.asset('assets/${mappaRisultati[r]}', fit: BoxFit.contain)),
                              )).toList(),
                            ),
                            const SizedBox(height: 10),
                            // Riepilogo risultati dall'analisi
                            if (data['analisi'] != null)
                              _buildRiepilogoRisultati(data['analisi']['successi']),

                            // Dopo il testo del messaggio (data['testo'])
                            if (data['Perdite'] == true && data["tipo"]=="Rilancio")
                              const Text(
                                "Rilancio non riuscito: Perdi un successo",
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            if (data['Perdite'] == true && data["tipo"]=="Tutto o Niente")
                              const Text(
                                "Tutto o Niente non riuscito: Perdi tutti i successi",
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            // Bottoni azione
                            if ((data["usato"] != true) && (data["ritira"] == true) &&
                                ((data["tipo"] == "Primo") ||
                                    (data["tuttooNiente"] ?? false))) ...[
                              const SizedBox(height: 12),
                              Column(
                                children: [
                                  if (data["tipo"] == "Primo") SizedBox(width: double.infinity, child: _bottoncinoAzione("Rilancio", messaggi[i])),
                                  if (data["tipo"] == "Primo") SizedBox(height: 8,),
                                  if (data["tipo"] == "Primo") SizedBox(width: double.infinity, child: _bottoncinoAzione("Rilancio in Sicurezza", messaggi[i])),
                                  if (data["tuttooNiente"] ?? false) SizedBox(width: double.infinity, child: _bottoncinoAzione("Tutto o Niente", messaggi[i])),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: const Border(top: BorderSide(color: Colors.white10))),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.grey[900],
                    isExpanded: true,
                    menuMaxHeight: 250,
                    itemHeight: 48,
                    decoration: const InputDecoration(labelText: "Personaggio", labelStyle: TextStyle(color: Colors.white, fontSize: 12), contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                    items: widget.listaPersonaggi.map((p) {
                      final data = p.data() as Map<String, dynamic>;
                      return DropdownMenuItem(value: p.id, child: Text(data['Nome'] ?? 'Sconosciuto', style: const TextStyle(color: Colors.white, fontSize: 12)));
                    }).toList(),
                    selectedItemBuilder: (context) => widget.listaPersonaggi.map((p) {
                      final data = p.data() as Map<String, dynamic>;
                      return Text(data['Nome'] ?? 'Sconosciuto', style: const TextStyle(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis);
                    }).toList(),
                    onChanged: (v) => setState(() => _personaggioId = v),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: DropdownButtonFormField<String>(value: _ambito,dropdownColor: Colors.grey[900], isExpanded: true, menuMaxHeight: 250, itemHeight: 48, decoration: const InputDecoration(labelText: "Ambito", labelStyle: TextStyle(color: Colors.white, fontSize: 12), contentPadding: EdgeInsets.symmetric(horizontal: 8)), selectedItemBuilder: (context) => _ambiti.map((a) => Text(a, style: const TextStyle(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis)).toList(), items: _ambiti.map((a) => _buildMenuItem(a)).toList(), onChanged: (v) => setState(() => _ambito = v))),
                      const SizedBox(width: 8),
                      Expanded(child: DropdownButtonFormField<String>(value: _abilita,dropdownColor: Colors.grey[900], isExpanded: true, menuMaxHeight: 250, itemHeight: 48, decoration: const InputDecoration(labelText: "Abilità", labelStyle: TextStyle(color: Colors.white, fontSize: 12), contentPadding: EdgeInsets.symmetric(horizontal: 8)), selectedItemBuilder: (context) => _abilitaList.map((a) => Text(a, style: const TextStyle(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis)).toList(), items: _abilitaList.map((a) => _buildMenuItem(a)).toList(), onChanged: (v) => setState(() => _abilita = v))),
                      const SizedBox(width: 8),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          children: [
                            SizedBox(width: 20, child: Text("$_numeroDadi", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(onTap: () => setState(() => _numeroDadi++), child: const Icon(Icons.arrow_drop_up, color: Colors.white, size: 18)),
                                InkWell(onTap: () => setState(() => _numeroDadi = (_numeroDadi - 1).clamp(-99, 99)), child: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      (_ambito != null || _abilita != null)
                          ? "${_ambito ?? "Ambito"} (${_ambito != null ? _getBonus('Ambiti', _ambito!) : '0'}) + "
                          "${_abilita ?? "Abilità"} (${_abilita != null ? _getBonus('Abilità', _abilita!) : '0'}) + $_numeroDadi"
                          : "Seleziona ambito e abilità",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_personaggioId != null && _ambito != null && _abilita != null) ? _inviaTiro : null,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, disabledBackgroundColor: Colors.white.withOpacity(0.1), padding: const EdgeInsets.symmetric(vertical: 8)),
                      child: const Text("TIRA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        Positioned(
          right: 10,
          top: 10, // Regola questo valore per sollevarlo sopra il box dei dropdown
          child: FloatingActionButton(
            backgroundColor: Colors.grey[900],
            mini: true, // Lo rende un po' più piccolo e discreto
            onPressed: () async {
              bool conferma = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Elimina Chat"),
                  content: const Text("Sei sicuro di voler cancellare tutti i messaggi?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annulla")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Elimina", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (conferma == true) {
                await _cancellaTuttaLaChat();
              }
            },
            child: const Icon(Icons.delete_forever, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _bottoncinoAzione(String label, DocumentSnapshot doc) {
    return InkWell(
      onTap: () => _eseguiRitiro(doc, label),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.white24)),
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}