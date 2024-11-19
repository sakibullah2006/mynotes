import 'package:flutter/material.dart';
import 'package:mynotes/components/name_frame.dart';
import 'package:mynotes/constant/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/note_service.dart';
import 'package:mynotes/utilities/dialog/delete_dialog.dart';
import 'package:mynotes/utilities/dialog/logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _noteService;

  String get userEmail => AuthService.firebase().currentUser!.email;
  String get name => AuthService.firebase().currentUser!.displayName;

  Future logout() async {
    await AuthService.firebase().logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
  }

  @override
  void initState() {
    print('$userEmail $name');
    _noteService = NotesService();
    // _noteService.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        title: const Text("N O T E S"),
        // centerTitle: true,
        actions: [
          // * Add note button
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                createOrUpdateNoteRoute,
                // arguments: null,
              );
            },
            icon: const Icon(Icons.add),
          ),
          // * Logout button
          IconButton(
            onPressed: () async {
              var confirmation = await showLogOutDialog(context);
              if (confirmation) {
                logout();
              }
            },
            icon: const Icon(Icons.logout),
          ),
          // * Circular progress indicator
          NameFrame(text: name),
        ],
      ),
      body: FutureBuilder(
        future: _noteService.getOrCreateUser(name: name, email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _noteService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final notes = snapshot.data as List<DatabaseNote>;
                        return NoteListView(
                          notes: notes,
                          onDelete: (note) async {
                            final showDelete = await showDeleteDialog(context);
                            if (showDelete) {
                              _noteService.deleteNote(id: note.id);
                            }
                          },
                          onTap: (note) {
                            Navigator.of(context).pushNamed(
                              createOrUpdateNoteRoute,
                              arguments: note,
                            );
                          },
                        );
                      } else {
                        return const Text(
                            "Your notes are empty. Add some notes!");
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator.adaptive();
          }
        },
      ),
    );
  }
}
