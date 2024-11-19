import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/note_service.dart';
import 'package:mynotes/utilities/extensions/route_get_argument.dart';

String formatDate(String dateTime) {
  final date = DateTime.parse(dateTime);

  return DateFormat('dd-MM-yyyy HH:mm').format(date);
}

class CreateOrUpdateNote extends StatefulWidget {
  const CreateOrUpdateNote({super.key});

  @override
  State<CreateOrUpdateNote> createState() => _CreateOrUpdateNoteState();
}

class _CreateOrUpdateNoteState extends State<CreateOrUpdateNote> {
  DatabaseNote? _note;
  // late final DatabaseNote? widgetNote;
  late final NotesService _notesService;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    _notesService = NotesService();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _setupTextControllerListeners();
    super.initState();
  }

  Future<DatabaseNote> createOrGetExistingNote(BuildContext contex) async {
    final widgetNote = context.getArgument<DatabaseNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _titleController.text = widgetNote.title;
      _descriptionController.text = widgetNote.description;

      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email;
    final name = currentUser.displayName;
    final owner = await _notesService.createUser(name: name, email: email);
    final newNote = await _notesService.createNote(
        owner: owner, title: "", description: "");
    return newNote;
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    log("Updating note: $title, $description");
    await _notesService.updateNote(
      note: note,
      description: description,
      title: title,
    );
  }

  void _setupTextControllerListeners() {
    log("Setting up text controller listeners");
    // * Remove listeners from text controllers
    _titleController.removeListener(_textControllerListener);
    _descriptionController.removeListener(_textControllerListener);

    // * Add listeners to text controllers
    _titleController.addListener(_textControllerListener);
    _descriptionController.addListener(_textControllerListener);
  }

  void _deleteNoteIfEmpty() async {
    final note = _note;
    if (note != null &&
        _titleController.text.isEmpty &&
        _descriptionController.text.isEmpty) {
      log("Deleting note: ${note.id}");
      await _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfnotEmpty() async {
    final note = _note;
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (note != null &&
        _titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      log("Saving note: $title, $description");
      await _notesService.updateNote(
        note: note,
        title: title,
        description: description,
      );
    }
  }

  @override
  void dispose() {
    _setupTextControllerListeners();
    _saveNoteIfnotEmpty();
    _deleteNoteIfEmpty();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widgetNote = context.getArgument<DatabaseNote>();

    // final isUpdate = ModalRoute.of(context)?.settings.arguments as bool;
    final title = widgetNote != null ? 'Update Note' : 'New Note';
    // Define a maximum character length for the title
    int? maxTitleLength = _titleController.text.length >= 100 ? 100 : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        title: Text(title),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (contex, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListeners();
              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title TextField with bottom border only
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(
                          color: Colors.black38,
                        ),
                        hintText: 'Title',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                      maxLength: maxTitleLength,
                      maxLines: 3, // Allow up to 3 lines
                      minLines: 1, // Start with 1 line
                    ),
                    const SizedBox(height: 20.0),

                    // Text TextField with no border
                    Expanded(
                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(
                            color: Colors.black38,
                          ),
                          hintText: 'Start typing...',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ],
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
