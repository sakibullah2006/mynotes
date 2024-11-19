import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/note_service.dart';
import 'package:mynotes/utilities/dialog/delete_dialog.dart';

typedef NoteCallBack = void Function(DatabaseNote note);

class NoteListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final NoteCallBack onDelete;
  final NoteCallBack onTap;

  const NoteListView({
    super.key,
    required this.notes,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            "Hello, $index",
            // notes[index].title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
          subtitle: Text(
            notes[index].description,
            maxLines: 2,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDelete(notes[index]);
              }
            },
          ),
          onTap: () {
            onTap(notes[index]);
          },
        );
      },
    );
  }
}
