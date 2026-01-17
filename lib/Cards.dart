import 'dart:collection';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart' show ChangeNotifier;

import 'package:memorize/parser.dart';
import 'package:memorize/util.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'card.dart';
import 'package:flutter/services.dart' show rootBundle;

class Cards with ChangeNotifier {
  List<String> _cardScripts = [''];
  List<int> _deck = [];
  int current = -1;
  FilterQuery _filter = FilterQuery('');

  FilterQuery get filter => _filter;

  String _tag = '#ふせん';

  String get tag => _tag;

  List<String> filterHistory = [];

  void setTag(String value) {
    if (!isTag(value)) return;
    _tag = value;
    notifyListeners();
  }

  UnmodifiableListView<int> get deck {
    return UnmodifiableListView(_deck);
  }

  UnmodifiableListView<String> get cardScripts {
    return UnmodifiableListView(_cardScripts);
  }

  void setCurrent(int card, [bool notify = true]) {
    current = card;
    /*if(notify) */ notifyListeners();
  }

  void setCard(int i, Card card, [bool notify = true]) {
    if (i < 0 || i >= _cardScripts.length) return;
    _cardScripts[i] = card.getScript();
    if (notify) updateDeck();
  }

  Card? getCard(int i) {
    if (i < 0 || i >= _cardScripts.length) return null;
    return Card(i, _cardScripts[i]);
  }

  void setFilter(String script) {
    script = script.trim();
    _filter = FilterQuery(script);
    updateDeck();

    if (_deck.isEmpty || script.isEmpty) return;

    filterHistory.remove(script);

    filterHistory.add(script);

    if (filterHistory.length > 10)
      filterHistory.removeRange(0, filterHistory.length - 10);
  }

  void updateDeck() {
    _deck = filter.execute((i) => _cardScripts[i], _cardScripts.length);

    current = findClosestCard(current, _deck);

    notifyListeners();
  }

  void setScripts(String script) {
    _cardScripts = script.split('\n###\n');
    updateDeck();

    notifyListeners();
  }

  String getScripts() {
    return _cardScripts.join('\n###\n');
  }

  void editDeckScript(String Function(String script) edit,
      {bool applyAll = false}) {
    for (var i
        in applyAll ? List.generate(_cardScripts.length, (i) => i) : deck) {
      _cardScripts[i] = edit(_cardScripts[i]);
    }
    notifyListeners();
  }

  Future<void> save() async {
    try {
      // Save to SharedPreferences (Works on both Web and Mobile)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('card_data', getScripts());

      // Save to File (Mobile/Desktop only)
      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/data.txt');
        await file.writeAsString(getScripts());
      }
    } catch (e) {
      print("Error saving data: $e");
    }
  }

  Future<void> load() async {
    await loadSettings();
    bool loaded = false;

    // Load from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('card_data')) {
        final savedData = prefs.getString('card_data');
        if (savedData != null && savedData.isNotEmpty) {
          setScripts(savedData);

          loaded = true;
        }
      }
    } catch (e) {
      print("Error loading from SharedPreferences: $e");
    }

    // Load from File (Mobile/Desktop only) - Only if not already loaded (or as priority override?)
    // Strategy: If on mobile, maybe file is source of truth?
    // Let's assume SharedPreferences is the new primary for consistency, but if missing, try file.
    if (!loaded && !kIsWeb) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/data.txt');
        if (await file.exists()) {
          final read = await file.readAsString();
          setScripts(read);

          loaded = true;
        }
      } catch (e) {
        print("Error loading from file: $e");
      }
    }

    if (!loaded) {
      try {
        final defaultContent = await rootBundle.loadString('assets/data.txt');
        setScripts(defaultContent);
      } catch (e) {
        print("Error reading default file: $e");
      }
    }
  }

  String _url = 'https://rintify.sakura.ne.jp/wg0t394hgoihj3oghwoihioh2/';
  String _password = 'wvLb5bkBkDgK2UfTXYhAtHEJyNqtaZUf';

  String get url => _url;
  String get password => _password;

  Future<void> saveSettings(String newUrl, String newPassword) async {
    _url = newUrl;
    if (!_url.endsWith('/')) {
      _url += '/';
    }
    _password = newPassword;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cloud_url', _url);
      await prefs.setString('cloud_password', _password);
    } catch (e) {
      print("Error saving settings: $e");
    }
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _url = prefs.getString('cloud_url') ?? _url;
      _password = prefs.getString('cloud_password') ?? _password;
    } catch (e) {
      print("Error loading settings: $e");
    }
  }

  Future<bool> download() async {
    try {
      final response = await http.post(
        Uri.parse('${_url}fetch.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'password': _password,
        }),
      );

      print(response.statusCode);
      if (response.statusCode != 200) return false;

      final script = decryptData(response.body);
      setScripts(script);
      await save();

      return true;
    } catch (e) {
      print('fetch: $e');
      return false;
    }
  }

  Future<bool> upload() async {
    try {
      final encryptedData = encryptData(getScripts());
      print('Sending encrypted data...');
      final response = await http.post(
        Uri.parse('${_url}send.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'password': _password, 'data': encryptedData}),
      );

      if (response.statusCode != 200) {
        print('Failed to send data. Status code: ${response.statusCode}');
        print('Error details: ${response.body}');
        return false;
      }

      if (response.body.trim() != 'Data saved successfully') {
        print('Upload failed. Server response: ${response.body}');
        return false;
      }

      print('Data sent successfully.');
      return true;
    } catch (e) {
      print('Exception occurred: $e');
      return false;
    }
  }
}

bool isTag(String value) {
  return RegExp(r'^#[^ #\n*]+$').hasMatch(value);
}

String markTag(String tag) {
  return '#*${tag.substring(1)}';
}
