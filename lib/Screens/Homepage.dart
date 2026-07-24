import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:household_vtt/Widgets/CardPersonaggio.dart';
import 'package:household_vtt/Widgets/CardPersonaggioA.dart';
import 'package:household_vtt/Widgets/ChatColumn.dart';
import 'package:household_vtt/Widgets/SidebarRetrattile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final CollectionReference _personaggiRef = FirebaseFirestore.instance.collection('personaggi');
  final CollectionReference _attiviRef = FirebaseFirestore.instance.collection('Personaggi attivi');
  final DocumentReference _configRef = FirebaseFirestore.instance.collection('impostazioni').doc('ambiente');

  String? _usernameLoggato;
  String _stanzaSelezionata = "Salone"; // Default

  @override
  void initState() {
    super.initState();
    _caricaUsername();
    _listenStanza(); // aggiungi questo
  }

  void _listenStanza() {
    _configRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final nuovaStanza = snapshot['stanzaCorrente'] ?? "Salone";
        if (nuovaStanza != _stanzaSelezionata) {
          setState(() => _stanzaSelezionata = nuovaStanza);
        }
      }
    });
  }

  Future<void> _caricaUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('account')
          .where('email', isEqualTo: user.email)
          .get();
      if (doc.docs.isNotEmpty) {
        setState(() => _usernameLoggato = doc.docs.first['username']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_usernameLoggato == null) {
      return const Scaffold(
        backgroundColor: Color(0xfffdfcf0),
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    final bool isMaster = _usernameLoggato == "Master";



    return Scaffold(
          body: Stack(
            children: [
              // SFONDO DINAMICO
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final meta = constraints.maxWidth / 2;
                    return Row(
                    children: [
                    SizedBox(
                    width: meta,
                    child: OverflowBox(
                    alignment: Alignment.centerRight,
                    maxWidth: double.infinity,
                    child: Image.asset(
                    'assets/$_stanzaSelezionata 1.jpg',
                    fit: BoxFit.cover,
                    height: double.infinity,
                    ),
                    ),
                    ),
                    SizedBox(
                    width: meta,
                    child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: double.infinity,
                    child: Image.asset(
                    'assets/$_stanzaSelezionata 2.jpg',
                    fit: BoxFit.cover,
                    height: double.infinity,
                    ),
                    ),
                    ),
                    ],
                    );
                  },
                ),
              ),

              // Contenuto principale
              StreamBuilder<List<QuerySnapshot>>(
                stream: Rx.combineLatest2(
                  _personaggiRef.snapshots(),
                  _attiviRef.snapshots(),
                      (QuerySnapshot s1, QuerySnapshot s2) => [s1, s2],
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.green));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Errore: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  }
                  if (!snapshot.hasData || snapshot.data![0].docs.isEmpty || snapshot.data![1].docs.isEmpty) {
                    return const Center(child: Text('Nessun personaggio attivo.'));
                  }

                  final tuttiPersonaggi = snapshot.data![0].docs;
                  final attiviDocs = snapshot.data![1].docs;

                  // 1. Trova TUTTI i personaggi attivi associati a questo utente
                  final iMieiDocumentiAttivi = attiviDocs.cast<QueryDocumentSnapshot>().where(
                          (doc) => (doc.data() as Map<String, dynamic>)['giocatore'] == _usernameLoggato
                  ).toList();

                  // Estrai la lista dei nomi dei personaggi controllati dall'utente loggato
                  final iMieiNomi = iMieiDocumentiAttivi
                      .map((doc) => (doc.data() as Map<String, dynamic>)['nome'] as String)
                      .toSet();

                  // Nomi di tutti i personaggi attivi sul tavolo (per mostrare le carte a schermo)
                  final nomiAttivi = attiviDocs.map((doc) => (doc.data() as Map<String, dynamic>)['nome'] as String).toSet();

                  final personaggiFiltrati = tuttiPersonaggi.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return nomiAttivi.contains(data['Nome']);
                  }).toList();

                  // Personaggi da passare alla chat (tutti quelli dell'utente o tutti per il Master)
                  var mioPersonaggioPerChat = tuttiPersonaggi.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return iMieiNomi.contains(data['Nome']);
                  }).toList();

                  if (isMaster){
                    mioPersonaggioPerChat = personaggiFiltrati;
                  }

                  final int numeroCarte = personaggiFiltrati.length;

                  return SidebarRetrattile(
                    pannelloContent: Chatcolumn(
                      listaPersonaggi: mioPersonaggioPerChat,
                      chatRef: FirebaseFirestore.instance.collection('chat'),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double larghezzaIdealeRow = (260 * numeroCarte) + (30 * (numeroCarte - 1));
                            final double larghezzaTarget = constraints.maxWidth < larghezzaIdealeRow
                                ? constraints.maxWidth
                                : larghezzaIdealeRow;

                            return SizedBox(
                              width: larghezzaTarget,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: personaggiFiltrati.map((doc) {
                                  final data = doc.data() as Map<String, dynamic>;
                                  final isMioPersonaggio = iMieiNomi.contains(data['Nome']);

                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                      child: isMioPersonaggio || isMaster
                                          ? CardPersonaggioA(docId: doc.id, dati: data)
                                          : CardPersonaggio(docId: doc.id, dati: data),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              // MENU A TENDINA STANZE (Basso a destra)
              if (isMaster)
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xfffdfcf0).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _stanzaSelezionata,
                        dropdownColor: const Color(0xfffdfcf0),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.green, size: 20),
                        style: const TextStyle(color: Colors.green, fontSize: 14),
                        items: ["Camera", "Cantina", "Pranzo", "Salone"]
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.green))))
                            .toList(),
                        onChanged: (val) {
                          // Aggiorna su Firestore invece di fare solo setState
                          _configRef.update({'stanzaCorrente': val});
                        },
                      ),
                    ),
                  ),
                ),

              // Tasto per aggiungere nuovo personaggio (Solo Master)
              if (isMaster)
                Positioned(
                  bottom: 80,
                  left: 20, // Posizionato in basso a destra
                  child: FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Colors.green,
                    foregroundColor: Color(0xfffdfcf0),
                    child: Icon(Icons.add),
                    //icon: const Icon(Icons.add),
                    //label: const Text("Nuovo Personaggio"),
                    onPressed: () async {
                      // Logica di creazione
                      final docRef = await FirebaseFirestore.instance.collection('personaggi').add({
                        "Nome": "Nuovo Avventuriero",
                        "Popolo": "",
                        "Professione": "",
                        "Vocazione": "",
                        "Lingue": "",
                        "Monete": 0,
                        "Nazione": "del Reame",
                        "Decoro": 1,
                        "Ricchezza": 1,
                        "Stress": 0,
                        "BBC": 0,
                        "Abilità": {
                          "Arte": 1, "Atletica": 1, "Autorità": 1, "Cautela": 1, "Combattimento": 1,
                          "Cultura": 1, "Cura": 1, "Destrezza": 1, "Eloquenza": 1, "Elusione": 1,
                          "Esplorazione": 1, "Etichetta": 1, "Fascino": 1, "Forza": 1, "Grazia": 1,
                          "Indagine": 1, "Intuito": 1, "Tecnica": 1, "Tiro": 1, "Volontà": 1
                        },
                        "Ambiti": { "Accademia": 1, "Guerra": 1, "Società": 1, "Strada": 1 },
                        "Assi": { "Cuori": false, "Quadri": false, "Fiori": false, "Picche": false, "Jolly": false },
                        "Condizioni": {
                          "Umiliato": false, "Confuso": false, "Ferito": false, "Spaventato": false,
                          "Stanco": false, "Malato": false, "Avvelenato": false, "Spezzato": false
                        },
                        "CondizioneS1": { "attiva": false, "nome": "" },
                        "CondizioneS2": { "attiva": false, "nome": "" },
                        "Contratto1": { "Titolo": "", "Concessione": "", "Controparte": "", "Rotto": false },
                        "Contratto2": { "Rotto": false },
                        "Manovra1": { "Espediente": "", "Usata": false, "Cuori": false, "Quadri": false, "Fiori": false, "Picche": false },
                        "Manovra2": { "Usata": false, "Cuori": false, "Quadri": false, "Fiori": false, "Picche": false },
                        "Manovra3": { "Usata": false, "Cuori": false, "Quadri": false, "Fiori": false, "Picche": false },
                        "Memorie": {},
                        "Esperienze": {},
                        "Tratti": {},
                        "Nome Equipaggiamento": ["", "", "", "", ""],
                        "Descrizione Equipaggiamento": ["", "", "", "", ""],
                        "imageUrl": ""
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Nuovo personaggio creato!")),
                      );
                    },
                  ),
                ),

              // Logout
              Positioned(
                top: 20,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.green, size: 20),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  tooltip: "Logout",
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        );
  }
}