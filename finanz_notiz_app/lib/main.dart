import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<Entry> _entries = [];
  final List<Note> _notes = [];

  double get totalAmount {
    return _entries.fold(
      0.0,
      (sum, entry) => sum + (double.tryParse(entry.amount) ?? 0.0),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _addEntry(String name, String description, String amount) async {
    setState(() {
      _entries.add(Entry(name: name, description: description, amount: amount));
    });
    await _saveEntries();
  }

  Future<void> _editEntry(
      int index, String name, String description, String amount) async {
    setState(() {
      _entries[index] =
          Entry(name: name, description: description, amount: amount);
    });
    await _saveEntries();
  }

  Future<void> _addNote(String text) async {
    setState(() {
      final now = DateTime.now();
      final formattedDate = "${now.day}.${now.month}.${now.year}";
      _notes.add(Note(text: text, date: formattedDate));
    });
    await _saveEntries();
  }

  Future<void> _editNote(int index, String text) async {
    setState(() {
      _notes[index] = Note(
        text: text,
        date: _notes[index].date, // Datum bleibt gleich
      );
    });
    await _saveEntries();
  }

  Future<void> _deleteEntry(int index) async {
    setState(() {
      _entries.removeAt(index);
    });
    await _saveEntries();
  }

  Future<void> _deleteNote(int index) async {
    setState(() {
      _notes.removeAt(index);
    });
    await _saveEntries();
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entryList = _entries.map((entry) => entry.toJson()).toList();
    final notesList = _notes.map((note) => note.toJson()).toList();
    prefs.setString('entries', jsonEncode(entryList));
    prefs.setString('notes', jsonEncode(notesList));
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entryData = prefs.getString('entries');
    final notesData = prefs.getString('notes');
    if (entryData != null) {
      final entryList = List<Map<String, dynamic>>.from(jsonDecode(entryData));
      setState(() {
        _entries.clear();
        _entries.addAll(entryList.map((json) => Entry.fromJson(json)).toList());
      });
    }
    if (notesData != null) {
      final notesList = List<Map<String, dynamic>>.from(jsonDecode(notesData));
      setState(() {
        _notes.clear();
        _notes.addAll(notesList.map((json) => Note.fromJson(json)).toList());
      });
    }
  }

  void _showAddEntryDialog({int? index}) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    if (index != null) {
      // Wenn wir bearbeiten, fülle die Controller mit den aktuellen Werten
      nameController.text = _entries[index].name;
      descriptionController.text = _entries[index].description;
      amountController.text = _entries[index].amount;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
              index == null ? 'Eintrag hinzufügen' : 'Eintrag bearbeiten',
              style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white24,
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Beschreibung',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white24,
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  hintText: 'Betrag',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white24,
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen',
                  style: TextStyle(color: Colors.amber)),
            ),
            TextButton(
              onPressed: () {
                if (index == null) {
                  _addEntry(nameController.text, descriptionController.text,
                      amountController.text);
                } else {
                  _editEntry(index, nameController.text,
                      descriptionController.text, amountController.text);
                }
                Navigator.of(context).pop();
              },
              child: Text(index == null ? 'Hinzufügen' : 'Aktualisieren',
                  style: const TextStyle(color: Colors.amber)),
            ),
          ],
        );
      },
    );
  }

  void _showAddNoteDialog({int? index}) {
    final noteController = TextEditingController();

    if (index != null) {
      // Wenn wir bearbeiten, fülle den Controller mit dem aktuellen Wert
      noteController.text = _notes[index].text;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(index == null ? 'Notiz hinzufügen' : 'Notiz bearbeiten',
              style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              hintText: 'Notiz',
              hintStyle: TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white24,
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen',
                  style: TextStyle(color: Colors.amber)),
            ),
            TextButton(
              onPressed: () {
                if (index == null) {
                  _addNote(noteController.text);
                } else {
                  _editNote(index, noteController.text);
                }
                Navigator.of(context).pop();
              },
              child: Text(index == null ? 'Hinzufügen' : 'Aktualisieren',
                  style: const TextStyle(color: Colors.amber)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Finanz Notiz App',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: _selectedIndex == 0 ? _buildNotesView() : _buildEntriesView(),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _selectedIndex == 0 ? _showAddNoteDialog : _showAddEntryDialog,
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.amber,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Zahlungen',
          ),
        ],
      ),
    );
  }

  Widget _buildNotesView() {
    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_notes[index].text,
              style: const TextStyle(color: Colors.white)),
          subtitle: Text('Erstellt am: ${_notes[index].date}',
              style: const TextStyle(color: Colors.grey)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.amber),
                onPressed: () => _showAddNoteDialog(index: index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteNote(index),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEntriesView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Gesamt: €${totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.amber, fontSize: 24),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _entries.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_entries[index].name,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                    '${_entries[index].description} - €${_entries[index].amount}',
                    style: const TextStyle(color: Colors.grey)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amber),
                      onPressed: () => _showAddEntryDialog(index: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteEntry(index),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class Entry {
  final String name;
  final String description;
  final String amount;

  Entry({required this.name, required this.description, required this.amount});

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'amount': amount,
      };

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      name: json['name'],
      description: json['description'],
      amount: json['amount'],
    );
  }
}

class Note {
  final String text;
  final String date;

  Note({required this.text, required this.date});

  Map<String, dynamic> toJson() => {
        'text': text,
        'date': date,
      };

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      text: json['text'],
      date: json['date'],
    );
  }
}
