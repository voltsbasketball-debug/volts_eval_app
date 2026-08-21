import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() { runApp(const VoltsEvalApp()); }

class VoltsEvalApp extends StatelessWidget {
  const VoltsEvalApp({super.key});
  @override Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Électriks Eval', 
      debugShowCheckedModeBanner: false, 
      home: ListeJoueursPage()
    );
  }
}
class ListeJoueursPage extends StatefulWidget {
  const ListeJoueursPage({super.key});
  @override State<ListeJoueursPage> createState() => _ListeJoueursPageState();
}

class _ListeJoueursPageState extends State<ListeJoueursPage> {
  final TextEditingController _pCtrl = TextEditingController();
  final TextEditingController _nCtrl = TextEditingController();
  final TextEditingController _dCtrl = TextEditingController();
  final TextEditingController _nouvEquipeCtrl = TextEditingController();
  final TextEditingController _evalCtrl = TextEditingController();
  String _pos = "Meneuse";
  String _equipeActive = "ÉLECTRIKS CADET D1";
  List<Map<String, dynamic>> _joueurs = [];
  List<String> _listeEquipes = ["ÉLECTRIKS CADET D1"];
    static SharedPreferences? _prefsInstance;


  @override void initState() {
    super.initState();
    _chargerDonneesInitiales();
  }
  Future<void> _chargerDonneesInitiales() async {
    final prefs = await SharedPreferences.getInstance();
        _prefsInstance = prefs;

    _evalCtrl.text = prefs.getString('nom_coach') ?? "COACH ISMAIL";
    final String? eqJson = prefs.getString('liste_global_equipes');
    if (eqJson != null) {
      _listeEquipes = List<String>.from(jsonDecode(eqJson));
    }
    _chargerEquipeSpecifique(prefs.getString('derniere_equipe') ?? "ÉLECTRIKS CADET D1");
  }

  Future<void> _chargerEquipeSpecifique(String nomEquipe) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jJson = prefs.getString('archive_$nomEquipe');
    if (!_listeEquipes.contains(nomEquipe)) {
      _listeEquipes.add(nomEquipe);
    }
    setState(() {
      _equipeActive = nomEquipe;
      prefs.setString('derniere_equipe', nomEquipe);
      if (jJson != null) {
        _joueurs = List<Map<String, dynamic>>.from(jsonDecode(jJson));
      } else {
        _joueurs = [{
          "id": "1",
          "prenom": "SARAH",
          "nom": "GAGNON",
          "naissance": "12/04/2008",
          "position": "Meneuse",
          "eval1": {"Endurance": 0, "Vitesse": 0, "Agilité": 0, "Dribble": 0, "Passe": 0, "Tir": 0, "Défensive": 0, "Attitude": 0, "Éthique": 0, "IQ Basketball": 0, "date": ""},
          "eval2": {"Endurance": 0, "Vitesse": 0, "Agilité": 0, "Dribble": 0, "Passe": 0, "Tir": 0, "Défensive": 0, "Attitude": 0, "Éthique": 0, "IQ Basketball": 0, "date": ""},
          "eval3": {"Endurance": 0, "Vitesse": 0, "Agilité": 0, "Dribble": 0, "Passe": 0, "Tir": 0, "Défensive": 0, "Attitude": 0, "Éthique": 0, "IQ Basketball": 0, "date": ""},
          "commentaire": ""
        }];
      }
    });
  }

  Future<void> _sauvegarderTout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nom_coach', _evalCtrl.text.trim());
    await prefs.setString('archive_$_equipeActive', jsonEncode(_joueurs));
    await prefs.setString('liste_global_equipes', jsonEncode(_listeEquipes));
  }
  void _sauvegarderJoueur({int? idx}) {
    if (_pCtrl.text.trim().isEmpty || _nCtrl.text.trim().isEmpty || _dCtrl.text.trim().isEmpty) return;
    setState(() {
      if (idx != null) {
        _joueurs[idx]["prenom"] = _pCtrl.text.trim().toUpperCase();
        _joueurs[idx]["nom"] = _nCtrl.text.trim().toUpperCase();
        _joueurs[idx]["naissance"] = _dCtrl.text.trim();
        _joueurs[idx]["position"] = _pos;
      } else {
        final Map<String, dynamic> gV = {"Endurance": 0, "Vitesse": 0, "Agilité": 0, "Dribble": 0, "Passe": 0, "Tir": 0, "Défensive": 0, "Attitude": 0, "Éthique": 0, "IQ Basketball": 0, "date": ""};
        _joueurs.add({"id": DateTime.now().millisecondsSinceEpoch.toString(), "prenom": _pCtrl.text.trim().toUpperCase(), "nom": _nCtrl.text.trim().toUpperCase(), "naissance": _dCtrl.text.trim(), "position": _pos, "eval1": Map<String, dynamic>.from(gV), "eval2": Map<String, dynamic>.from(gV), "eval3": Map<String, dynamic>.from(gV), "commentaire": ""});
      }
      _pCtrl.clear(); _nCtrl.clear(); _dCtrl.clear(); _sauvegarderTout();
    });
    Navigator.pop(context);
  }
  void _ouvrirDialogue({int? idx}) {
    if (idx != null) {
      _pCtrl.text = _joueurs[idx]["prenom"]!;
      _nCtrl.text = _joueurs[idx]["nom"]!;
      _dCtrl.text = _joueurs[idx]["naissance"]!;
      _pos = _joueurs[idx]["position"]!;
    } else {
      _pCtrl.clear(); _nCtrl.clear(); _dCtrl.clear(); _pos = "Meneuse";
    }
    showDialog(
      context: context, 
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF172A45), 
          title: Text(idx != null ? "MODIFIER" : "NOUVELLE JOUEUSE", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
          content: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              TextField(
                controller: _pCtrl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), 
                decoration: const InputDecoration(labelText: "Prénom", labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ), 
              TextField(
                controller: _nCtrl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), 
                decoration: const InputDecoration(labelText: "Nom", labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ), 
              TextField(
                controller: _dCtrl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), readOnly: true, 
                decoration: const InputDecoration(labelText: "Date de naissance", labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
                onTap: () async { 
                  DateTime? p = await showDatePicker(context: context, initialDate: DateTime(2008), firstDate: DateTime(1990), lastDate: DateTime(2030)); 
                  if (p != null) setDialogState(() => _dCtrl.text = "${p.day}/${p.month}/${p.year}"); 
                },
              ), 
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _pos, dropdownColor: const Color(0xFF172A45), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), 
                decoration: const InputDecoration(labelText: "Position", labelStyle: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                items: ["Meneuse", "Arrière", "Ailière", "Ailière forte", "Pivot"].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(), 
                onChanged: (v) => setDialogState(() => _pos = v!)
              )
            ],
          ), 
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
              onPressed: () => _sauvegarderJoueur(idx: idx), child: const Text("SAUVEGARDER", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
    void _exporterEquipe() {
    final Map<String, dynamic> donnees = {
      "nomEquipe": _equipeActive,
      "joueurs": _joueurs
    };
    final String texteCode = jsonEncode(donnees);
    Clipboard.setData(ClipboardData(text: texteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Équipe copiée ! Colle-la sur Messenger."))
    );
  }

    void _importerEquipe(String texteJson) async {
    if (texteJson.trim().isEmpty) return;
    try {
      final Map<String, dynamic> donnees = jsonDecode(texteJson.trim());
      final String nomImport = "${donnees['nomEquipe'] ?? 'IMPORT'} - CO-COACH";
      final List<dynamic> joueursImport = donnees['joueurs'] ?? [];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('archive_$nomImport', jsonEncode(joueursImport));
      
      setState(() {
        if (!_listeEquipes.contains(nomImport)) {
          _listeEquipes.add(nomImport);
        }
        _equipeActive = nomImport;
        _joueurs = List<Map<String, dynamic>>.from(joueursImport);
      });
      
      _sauvegarderTout();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Équipe $nomImport importée !"))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Format de code invalide !"))
      );
    }
  }


  void _supprimerEquipeActive() {
    if (_equipeActive == "ÉLECTRIKS CADET D1") return;
    setState(() {
      _listeEquipes.remove(_equipeActive);
      _joueurs.clear();
      _sauvegarderTout();
      _chargerEquipeSpecifique("ÉLECTRIKS CADET D1");
    });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: Colors.black, 
        centerTitle: true, 
        title: const Text('VOLTS EVAL - ÉLECTRIKS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
      ),
      body: Stack(children: [
        Positioned.fill(child: Column(children: [
          Expanded(child: Opacity(opacity: 0.85, child: Padding(padding: const EdgeInsets.only(top: 40), child: Image.asset('assets/logo_volts.png', fit: BoxFit.contain, errorBuilder: (c, e, s) => const SizedBox())))),
          Expanded(child: Opacity(opacity: 0.85, child: Padding(padding: const EdgeInsets.only(bottom: 40), child: Image.asset('assets/logo_electrik.png', fit: BoxFit.contain, errorBuilder: (c, e, s) => const SizedBox())))),
        ])),
                Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), 
            color: Colors.black.withOpacity(0.9), 
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _listeEquipes.contains(_equipeActive) ? _equipeActive : _listeEquipes.first, 
                    dropdownColor: const Color(0xFF0F172A), 
                    iconSize: 34,
                    iconEnabledColor: const Color(0xFFFFD700),
                    style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16), 
                    decoration: const InputDecoration(labelText: "CHOIX ÉQUIPE ARCHIVÉE", labelStyle: TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold), border: InputBorder.none), 
                    items: _listeEquipes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
                    onChanged: (v) { _sauvegarderTout(); _chargerEquipeSpecifique(v!); }
                  )
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy_all, color: Colors.blueAccent, size: 32),
                  tooltip: "Exporter l'équipe",
                  onPressed: () => _exporterEquipe(),
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.greenAccent, size: 32),
                  tooltip: "Importer une équipe",
                  onPressed: () {
                    final TextEditingController importCtrl = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF172A45),
                        title: const Text("COLLER LE CODE ÉQUIPE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        content: TextField(
                          controller: importCtrl,
                          maxLines: 4,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          decoration: const InputDecoration(hintText: "Colle le code reçu ici...", hintStyle: TextStyle(color: Colors.white30), border: OutlineInputBorder()),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler", style: TextStyle(color: Colors.grey))),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _importerEquipe(importCtrl.text);
                            },
                            child: const Text("IMPORTER", style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 32),
                  tooltip: "Supprimer l'équipe active",
                  onPressed: () => _supprimerEquipeActive(),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: Row(children: [
                  Expanded(child: TextField(controller: _evalCtrl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), decoration: const InputDecoration(labelText: "ÉVALUATEUR/TRICE", labelStyle: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold), border: InputBorder.none))), 
                  IconButton(icon: const Icon(Icons.check_box, color: Colors.greenAccent, size: 22), onPressed: () { _sauvegarderTout(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coach mémorisé !"))); })
                ])),
                const SizedBox(width: 8),
                Expanded(child: Row(children: [
                  Expanded(child: TextField(controller: _nouvEquipeCtrl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), decoration: const InputDecoration(hintText: "Nom nouvelle équipe...", hintStyle: TextStyle(color: Colors.white60, fontSize: 12), border: InputBorder.none))), 
                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF334155), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)), child: const Text("SAVE ÉQUIPE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), onPressed: () { String n = _nouvEquipeCtrl.text.trim().toUpperCase(); if (n.isNotEmpty) { _sauvegarderTout(); _chargerEquipeSpecifique(n); _nouvEquipeCtrl.clear(); } })
                ])),
              ])
            ])),

          Expanded(child: ListView.builder(itemCount: _joueurs.length, itemBuilder: (context, i) {
            final j = _joueurs[i]; return Card(color: const Color(0xFF0F172A).withOpacity(0.85), child: ListTile(title: Text("${j['prenom']} ${j['nom']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)), subtitle: Text("Née: ${j['naissance']} • ${j['position']}", style: const TextStyle(color: Colors.grey, fontSize: 12)), leading: IconButton(icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 22), onPressed: () => setState(() { _joueurs.removeAt(i); _sauvegarderTout(); })), trailing: SizedBox(width: 40, child: Row(children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20), onPressed: () => _ouvrirDialogue(idx: i)), const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white)])), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FicheEvaluationPage(joueur: j, auChangement: _sauvegarderTout)))));
          })),
        ]),
      ]), floatingActionButton: FloatingActionButton(backgroundColor: const Color(0xFFFFD700), child: const Icon(Icons.add, color: Colors.black), onPressed: () => _ouvrirDialogue()),
    );
  }
}
class FicheEvaluationPage extends StatefulWidget {
  final Map<String, dynamic> joueur;
  final VoidCallback auChangement;
  const FicheEvaluationPage({
    super.key,
    required this.joueur,
    required this.auChangement,
  });
  @override
  State<FicheEvaluationPage> createState() =>
      _FicheEvaluationPageState();
}

class _FicheEvaluationPageState
    extends State<FicheEvaluationPage> {
  final TextEditingController _cController =
      TextEditingController();
  String _ev = "eval1";
  final GlobalKey _cleCapture = GlobalKey();

  @override
  void initState() {
    super.initState();
    _cController.text =
        widget.joueur['commentaire'] ?? "";
  }

  Future<void> _capturerEtPartager(
      Map<String, dynamic> nA, String dt) async {
    try {
      RenderRepaintBoundary b = _cleCapture
          .currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image img = await b.toImage(pixelRatio: 3.0);
      ByteData? bd = await img.toByteData(
          format: ui.ImageByteFormat.png);
      Uint8List bytes = bd!.buffer.asUint8List();
      final rep = await getTemporaryDirectory();
      final f = File(
          "${rep.path}/eval_${widget.joueur['prenom']}.png");
      await f.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(f.path)],
          text: "Évaluation");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur image")));
    }
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> evalDeBase = {
      "Endurance": 0, "Vitesse": 0, "Agilité": 0, "Dribble": 0, "Passe": 0, "Tir": 0, "Défensive": 0, "Attitude": 0, "Éthique": 0, "IQ Basketball": 0, "date": ""
    };
    if (widget.joueur[_ev] == null) {
      widget.joueur[_ev] = Map<String, dynamic>.from(evalDeBase);
    }
    if (widget.joueur["eval1"] == null) {
      widget.joueur["eval1"] = Map<String, dynamic>.from(evalDeBase);
    }
    if (widget.joueur["eval2"] == null) {
      widget.joueur["eval2"] = Map<String, dynamic>.from(evalDeBase);
    }
    if (widget.joueur["eval3"] == null) {
      widget.joueur["eval3"] = Map<String, dynamic>.from(evalDeBase);
    }
    final nA = widget.joueur[_ev] as Map<String, dynamic>;
    final e1 = widget.joueur["eval1"] as Map<String, dynamic>;
    final e2 = widget.joueur["eval2"] as Map<String, dynamic>;
    final e3 = widget.joueur["eval3"] as Map<String, dynamic>;
    final String dateAffichee = nA['date'] != null && nA['date'].toString().isNotEmpty ? nA['date'] : "Aucune note";

    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("${widget.joueur['prenom']} ${widget.joueur['nom']}", style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.share, color: Color(0xFFFFD700), size: 24), onPressed: () => _ouvrirPopupPartage(nA))
        ],
      ),
      body: Stack(children: [
        Positioned.fill(child: Opacity(opacity: 0.12, child: Image.asset('assets/logo_electrik.png', fit: BoxFit.contain, errorBuilder: (c, e, s) => const SizedBox()))),
        SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _ev == "eval1" ? const Color(0xFFFFD700) : const Color(0xFF2A2A2A), foregroundColor: _ev == "eval1" ? Colors.black : Colors.white), onPressed: () => setState(() => _ev = "eval1"), child: const Text("1ère"))),
                const SizedBox(width: 4),
                Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _ev == "eval2" ? const Color(0xFFFFD700) : const Color(0xFF2A2A2A), foregroundColor: _ev == "eval2" ? Colors.black : Colors.white), onPressed: () => setState(() => _ev = "eval2"), child: const Text("2e"))),
                const SizedBox(width: 4),
                Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _ev == "eval3" ? const Color(0xFFFFD700) : const Color(0xFF2A2A2A), foregroundColor: _ev == "eval3" ? Colors.black : Colors.white), onPressed: () => setState(() => _ev = "eval3"), child: const Text("3e")))
              ]),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("SAISIE DE LA SESSION SÉLECTIONNÉE (1 À 10)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 11)),
                Text("📅 ÉVALUÉ LE : $dateAffichee", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 11)),
              ]),
              const SizedBox(height: 6),
              ...nA.keys.where((k) => k != 'date').map((critere) {
                int note = nA[critere] ?? 0;
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(critere, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                    Text(note == 0 ? "Non noté" : "$note / 10", style: const TextStyle(color: Color(0xFFFFD700)))
                  ]),
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: List.generate(10, (i) {
                                         int v = i + 1;
                                bool estToi = note == v;
                                bool estLui = false;

                            final String cleCc = "${_ListeJoueursPageState._prefsInstance?.getString('derniere_equipe') ?? 'ÉLECTRIKS CADET D1'} - CO-COACH";
                                final SharedPreferences? localPrefs = _ListeJoueursPageState._prefsInstance;
                                if (localPrefs != null) {
                                  final String? jJson = localPrefs.getString('archive_$cleCc');
                                  if (jJson != null) {
                                    final List<dynamic> lCc = jsonDecode(jJson);
                                    final jCc = lCc.firstWhere((j) => j['prenom'] == widget.joueur['prenom'] && j['nom'] == widget.joueur['nom'], orElse: () => null);
                                    if (jCc != null && jCc[_ev] != null) {
                                      estLui = (jCc[_ev][critere] ?? 0) == v;
                                    }
                                  }
                                }

                                Color caseColor = const Color(0xFF333333);
                                if (estToi && estLui) caseColor = const Color(0xFFFFD700); // OR SI IDENTIQUE
                                else if (estToi) caseColor = Colors.green;                // VERT POUR TOI
                                else if (estLui) caseColor = Colors.blue;                 // BLEU POUR LUI

                                return GestureDetector(
                                    onTap: () => setState(() {
                                          nA[critere] = v;
                                          nA['date'] = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
                                          widget.auChangement();
                                        }),
                                    child: Container(
                                        width: 34, height: 34, margin: const EdgeInsets.only(right: 5),
                                        decoration: BoxDecoration(color: caseColor, borderRadius: BorderRadius.circular(6)),
                                        child: Center(child: Text("$v", style: TextStyle(color: (estToi || estLui) ? Colors.black : Colors.white, fontWeight: FontWeight.bold)))));
                      }))),
                  const Divider(color: Colors.white12, height: 10)
                ]);
              }),

              const SizedBox(height: 8),
              const Text("SUPERPOSITION ET SUIVI DE LA PROGRESSION", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 11)),
              const SizedBox(height: 4),
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.9), borderRadius: BorderRadius.circular(10)),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Expanded(child: Text("PROGRESSION", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 25, child: Text("E1", style: TextStyle(color: Colors.white, fontSize: 11))),
                      const SizedBox(width: 25, child: Text("E2", style: TextStyle(color: Colors.white, fontSize: 11))),
                      const SizedBox(width: 25, child: Text("E3", style: TextStyle(color: Colors.white, fontSize: 11))),
                      const SizedBox(width: 45, child: Text("TREND", style: TextStyle(color: Colors.grey, fontSize: 11)))
                    ]),
                    const SizedBox(height: 4),
                    ...e1.keys.where((k) => k != 'date').map((cr) {
                      int n1 = e1[cr] ?? 0; int n2 = e2[cr] ?? 0; int n3 = e3[cr] ?? 0;
                      bool pr = (n3 >= n2 && n2 >= n1) && (n1 != 0 || n2 != 0 || n3 != 0);
                      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(child: Text(cr, style: const TextStyle(color: Colors.white, fontSize: 12))),
                        SizedBox(width: 25, child: Text(n1 == 0 ? "-" : "$n1", style: const TextStyle(color: Colors.grey, fontSize: 11))),
                        SizedBox(width: 25, child: Text(n2 == 0 ? "-" : "$n2", style: const TextStyle(color: Colors.grey, fontSize: 11))),
                        SizedBox(width: 25, child: Text(n3 == 0 ? "-" : "$n3", style: const TextStyle(color: Colors.grey, fontSize: 11))),
                        Container(width: 45, padding: const EdgeInsets.symmetric(vertical: 1), decoration: BoxDecoration(color: pr ? Colors.green.withOpacity(0.15) : Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(pr ? "UP ↑" : "STABLE", style: TextStyle(color: pr ? Colors.green : Colors.amber, fontWeight: FontWeight.bold, fontSize: 9), textAlign: TextAlign.center))
                      ]);
                    })
                  ])),
              const SizedBox(height: 10),
              TextField(
                controller: _cController, maxLines: 2, style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "Forces, faiblesses...", filled: true, fillColor: Color(0xFF0F172A), border: InputBorder.none),
                onChanged: (t) { widget.joueur['commentaire'] = t; widget.auChangement(); },
              ),
            ])),
      ]),
    );
  }
  void _ouvrirPopupPartage(Map<String, dynamic> nA) {
    final String p = widget.joueur['prenom'] ?? '';
    final String n = widget.joueur['nom'] ?? '';
    final String dt = nA['date'] ?? "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(12),
        content: RepaintBoundary(
          key: _cleCapture,
          child: Container(
            color: Colors.white, padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("🏀 ÉVAL - $p $n ($_ev)", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  const Icon(Icons.analytics, color: Color(0xFFFFD700), size: 24),
                ]),
                const SizedBox(height: 4),
                Text("📅 Évalué le : $dt", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 12)),
                const Divider(color: Colors.black12, height: 16),
                ...nA.keys.where((k) => k != 'date').map((cr) {
                  int note = nA[cr] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cr, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13)),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text(note == 0 ? "-" : "$note / 10", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)))
                      ],
                    ),
                  );
                }),
                if (_cController.text.trim().isNotEmpty) ...[
                  const Divider(color: Colors.black12, height: 16),
                  const Text("COMMENTAIRE :", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(_cController.text.trim(), style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Fermer", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold))),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
            icon: const Icon(Icons.share, size: 16), label: const Text("IMAGE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            onPressed: () { Navigator.pop(ctx); _capturerEtPartager(nA, dt); },
          ),
        ],
      ),
    );
  }
}


