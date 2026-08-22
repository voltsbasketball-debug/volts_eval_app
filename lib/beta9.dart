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
    return const MaterialApp(title: 'VISION BASKET', debugShowCheckedModeBanner: false, home: ListeJoueursPage());
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

  @override void initState() { super.initState(); _chargerDonneesInitiales(); }

  Future<void> _chargerDonneesInitiales() async {
    final prefs = await SharedPreferences.getInstance();
    _evalCtrl.text = prefs.getString('nom_coach') ?? "CI";
    final String? eqJson = prefs.getString('liste_global_equipes');
    if (eqJson != null) _listeEquipes = List<String>.from(jsonDecode(eqJson));
    _chargerEquipeSpecifique(prefs.getString('derniere_equipe') ?? "ÉLECTRIKS CADET D1");
  }

  Future<void> _chargerEquipeSpecifique(String nomEquipe) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jJson = prefs.getString('archive_$nomEquipe');
    if (!_listeEquipes.contains(nomEquipe)) _listeEquipes.add(nomEquipe);
    setState(() {
      _equipeActive = nomEquipe;
      prefs.setString('derniere_equipe', nomEquipe);
      if (jJson != null) {
        final List<dynamic> decoded = jsonDecode(jJson);
        _joueurs = decoded.map((j) => Map<String, dynamic>.from(j as Map)).toList();
      } else {
        _joueurs = [{
          "id": "1", "prenom": "SARAH", "nom": "GAGNON", "naissance": "12/04/2008", "position": "Meneuse",
          "eval1": {"Endurance": 0, "Vitesse": 0, "Agilité": 0, "Dribble": 0, "Passe": 0, "Tir": 0, "Défensive": 0, "Attitude": 0, "Éthique": 0, "IQ Basketball": 0, "date": "", "coach": "CI"},
          "eval2": {"Endurance": 0, "Vitesse": 0, "Agilité": 0, "Dribble": 0, "Passe": 0, "Tir": 0, "Défensive": 0, "Attitude": 0, "Éthique": 0, "IQ Basketball": 0, "date": "", "coach": "CI"},
          "eval3": {"Endurance": 0, "Vitesse": 0, "Agilité": 0, "Dribble": 0, "Passe": 0, "Tir": 0, "Défensive": 0, "Attitude": 0, "Éthique": 0, "IQ Basketball": 0, "date": "", "coach": "CI"},
          "commentaire": ""
        }];
      }
    });
  }

  Future<void> _sauvegarderTout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nom_coach', _evalCtrl.text.trim().toUpperCase());
    await prefs.setString('archive_$_equipeActive', jsonEncode(_joueurs));
    await prefs.setString('liste_global_equipes', jsonEncode(_listeEquipes));
  }

  void _sauvegarderJoueur({int? idx}) {
    if (_pCtrl.text.trim().isEmpty || _nCtrl.text.trim().isEmpty || _dCtrl.text.trim().isEmpty) return;
    setState(() {
      String monCoach = _evalCtrl.text.trim().toUpperCase();
      if (monCoach.isEmpty) monCoach = "CI";
      if (idx != null) {
        _joueurs[idx]["prenom"] = _pCtrl.text.trim().toUpperCase();
        _joueurs[idx]["nom"] = _nCtrl.text.trim().toUpperCase();
        _joueurs[idx]["naissance"] = _dCtrl.text.trim();
        _joueurs[idx]["position"] = _pos;
      } else {
        final Map<String, dynamic> gV = {"Endurance": 0, "Vitesse": 0, "Agilité": 0, "Dribble": 0, "Passe": 0, "Tir": 0, "Défensive": 0, "Attitude": 0, "Éthique": 0, "IQ Basketball": 0, "date": "", "coach": monCoach};
        _joueurs.add({"id": DateTime.now().millisecondsSinceEpoch.toString(), "prenom": _pCtrl.text.trim().toUpperCase(), "nom": _nCtrl.text.trim().toUpperCase(), "naissance": _dCtrl.text.trim(), "position": _pos, "eval1": Map<String, dynamic>.from(gV), "eval2": Map<String, dynamic>.from(gV), "eval3": Map<String, dynamic>.from(gV), "commentaire": ""});
      }
      _pCtrl.clear(); _nCtrl.clear(); _dCtrl.clear(); _sauvegarderTout();
    });
    Navigator.pop(context);
  }
  void _ouvrirDialogue({int? idx}) {
    if (idx != null) {
      _pCtrl.text = _joueurs[idx]["prenom"]!; _nCtrl.text = _joueurs[idx]["nom"]!; _dCtrl.text = _joueurs[idx]["naissance"]!; _pos = _joueurs[idx]["position"]!;
    } else {
      _pCtrl.clear(); _nCtrl.clear(); _dCtrl.clear(); _pos = "Meneuse";
    }
    showDialog(
      context: context, 
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF172A45), 
          title: Text(idx != null ? "MODIFIER" : "NOUVELLE JOUEUSE", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _pCtrl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), decoration: const InputDecoration(labelText: "Prénom", labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), 
            TextField(controller: _nCtrl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), decoration: const InputDecoration(labelText: "Nom", labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            TextField(controller: _dCtrl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), readOnly: true, decoration: const InputDecoration(labelText: "Date de naissance", labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), onTap: () async { 
              DateTime? p = await showDatePicker(context: context, initialDate: DateTime(2008), firstDate: DateTime(1990), lastDate: DateTime(2030)); 
              if (p != null) setDialogState(() => _dCtrl.text = "${p.day}/${p.month}/${p.year}"); 
            }), 
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(value: _pos, dropdownColor: const Color(0xFF172A45), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), decoration: const InputDecoration(labelText: "Position", labelStyle: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)), items: ["Meneuse", "Arrière", "Ailière", "Ailière forte", "Pivot"].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(), onChanged: (v) => setDialogState(() => _pos = v!))
          ]), 
          actions: [ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black), onPressed: () => _sauvegarderJoueur(idx: idx), child: const Text("SAUVEGARDER", style: TextStyle(fontWeight: FontWeight.bold)))],
        ),
      ),
    );
  }

  void _exporterEquipe() {
    String monCoach = _evalCtrl.text.trim().toUpperCase(); if (monCoach.isEmpty) monCoach = "CI";
    final Map<String, dynamic> donnees = {"nomEquipe": _equipeActive, "coachSource": monCoach, "joueurs": _joueurs};
    Clipboard.setData(ClipboardData(text: jsonEncode(donnees)));
    showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF172A45), title: const Text("ÉQUIPE COPIÉE !", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), content: Text("Le listing de l'équipe '$_equipeActive' avec vos notes ($monCoach) a été placé dans votre presse-papiers !", style: const TextStyle(color: Colors.white70, fontSize: 13)), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK", style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)))]));
  }

  void _importerEquipe(String texteJson) async {
    if (texteJson.trim().isEmpty) return;
    try {
      final Map<String, dynamic> donnees = Map<String, dynamic>.from(jsonDecode(texteJson.trim()));
      String nomBasePure = donnees['nomEquipe'] ?? donnees['equipe'] ?? 'IMPORT';
      nomBasePure = nomBasePure.replaceAll(RegExp(r' - COACH.*'), '').trim();
      String coachDistant = (donnees['coachSource'] ?? 'COACH').toString().toUpperCase();
      final prefs = await SharedPreferences.getInstance();
      String? archiveLocaleRaw = prefs.getString('archive_$nomBasePure');
      List<Map<String, dynamic>> listeLocale = [];
      if (archiveLocaleRaw != null) {
        final List<dynamic> localDecoded = jsonDecode(archiveLocaleRaw);
        listeLocale = localDecoded.map((j) => Map<String, dynamic>.from(j as Map)).toList();
      } else {
        final List<dynamic> joueursImport = donnees['joueurs'] ?? [];
        listeLocale = joueursImport.map((j) => Map<String, dynamic>.from(j as Map)).toList();
      }
      final List<dynamic> joueursDistants = donnees['joueurs'] ?? [];
      for (var maJoueuse in listeLocale) {
        final correspondant = joueursDistants.firstWhere((j) => j['prenom'] == maJoueuse['prenom'] && j['nom'] == maJoueuse['nom'], orElse: () => null);
        if (correspondant != null && correspondant is Map) {
          _fusionnerSession(maJoueuse, Map<String, dynamic>.from(correspondant), 'eval1', coachDistant);
          _fusionnerSession(maJoueuse, Map<String, dynamic>.from(correspondant), 'eval2', coachDistant);
          _fusionnerSession(maJoueuse, Map<String, dynamic>.from(correspondant), 'eval3', coachDistant);
        }
      }
      await prefs.setString('archive_$nomBasePure', jsonEncode(listeLocale));
      setState(() { if (!_listeEquipes.contains(nomBasePure)) _listeEquipes.add(nomBasePure); _equipeActive = nomBasePure; _joueurs = listeLocale; });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Notes de $coachDistant fusionnées dans l'équipe $nomBasePure !")));
    } catch (e) { if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Format de code invalide !"))); }
  }

  void _fusionnerSession(Map<String, dynamic> local, Map<String, dynamic> distant, String key, String coachName) {
    if (!distant.containsKey(key) || distant[key] == null) return;
    if (local[key] == null) {
      local[key] = {"Endurance": 0, "Vitesse": 0, "Agilité": 0, "Dribble": 0, "Passe": 0, "Tir": 0, "Défensive": 0, "Attitude": 0, "Éthique": 0, "IQ Basketball": 0, "date": "", "coach": _evalCtrl.text.trim().toUpperCase()};
    }
    Map<String, dynamic> dEval = Map<String, dynamic>.from(distant[key] as Map);
    local["${key}_$coachName"] = dEval;
  }

  void _supprimerEquipeActive() {
    if (_equipeActive == "ÉLECTRIKS CADET D1") return;
    setState(() { _listeEquipes.remove(_equipeActive); _joueurs.clear(); _sauvegarderTout(); _chargerEquipeSpecifique("ÉLECTRIKS CADET D1"); });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(backgroundColor: Colors.black, centerTitle: true, title: const Text('VISION BASKET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), color: Colors.black, 
          child: Column(children: [
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(value: _listeEquipes.contains(_equipeActive) ? _equipeActive : _listeEquipes.first, dropdownColor: const Color(0xFF0F172A), iconSize: 24, iconEnabledColor: const Color(0xFFFFD700), isExpanded: true, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 15), decoration: const InputDecoration(labelText: "CHOIX ÉQUIPE ARCHIVÉE", labelStyle: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold), border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none), items: _listeEquipes.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1))).toList(), onChanged: (v) { _sauvegarderTout(); _chargerEquipeSpecifique(v!); })),
              const SizedBox(width: 4),
              IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.copy_all, color: Colors.blueAccent, size: 26), tooltip: "Exporter l'équipe", onPressed: () => _exporterEquipe()),
              const SizedBox(width: 4),
              IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.download, color: Colors.greenAccent, size: 26), tooltip: "Importer des notes de coachs", onPressed: () {
                final TextEditingController importCtrl = TextEditingController();
                showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF172A45), title: const Text("COLLER LE CODE REÇU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), content: TextField(controller: importCtrl, maxLines: 4, style: const TextStyle(color: Colors.white, fontSize: 12), decoration: const InputDecoration(hintText: "Colle le code d'évaluation ici...", hintStyle: TextStyle(color: Colors.white30), border: OutlineInputBorder())), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler", style: TextStyle(color: Colors.grey))), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black), onPressed: () { Navigator.pop(ctx); _importerEquipe(importCtrl.text); }, child: const Text("IMPORTER", style: TextStyle(fontWeight: FontWeight.bold)))],
                ));
              }),
              const SizedBox(width: 4),
              IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 26), tooltip: "Supprimer l'équipe active", onPressed: () => _supprimerEquipeActive()),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: Row(children: [
