import 'package:flutter/foundation.dart' show immutable;
import 'package:mynotes/services/crud/db_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class NotesService {
  Database? _db;

  Future<DatabaseUser> createUser({
    required String name,
    required String email,
  }) async {
    final db = _getDatabaseOrThrow();

    // Check if user exist
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExist();
    }

    // add user
    final userId = await db.insert(userTable, {
      nameColumn: name.trim(),
      emailColumn: email.toLowerCase().trim(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
      name: name,
    );
  }

  Future<DatabaseNote> createNote({
    required DatabaseUser owner,
    required String title,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();

    // Verify User id hash
    final dbUser = await getUser(id: owner.id);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    // add note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      titleColumn: title.trim(),
      textColumn: text.trim(),
      isSyncedColumn: 1
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      title: title,
      text: text,
      isSyncedWithCloud: true,
    );

    return note;
  }

  Future<DatabaseUser> updateUser({
    required DatabaseUser user,
    required String name,
  }) async {
    final db = _getDatabaseOrThrow();

    await getUser(id: user.id);

    final updateCount = await db.update(
      userTable,
      {nameColumn: name},
      where: 'id = ?',
      whereArgs: [user.id],
    );

    if (updateCount == 0) {
      throw CouldNotUpdateUser();
    } else {
      return await getUser(id: user.id);
    }
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updateCount = await db.update(
      noteTable,
      {
        textColumn: text,
        isSyncedColumn: 0,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletecount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletecount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<void> deleteUser({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletecount = await db.delete(
      userTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletecount == 0) {
      throw CouldNotDeleteUser();
    }
  }

  Future<void> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();

    final deleteCount = await db.delete(noteTable);
    if (deleteCount == 0) {
      throw CouldNotDeleteNotes();
    }
  }

  Future<void> deleteAllUsers() async {
    final db = _getDatabaseOrThrow();

    final deleteCount = await db.delete(userTable);
    if (deleteCount == 0) {
      throw CouldNotDeleteUsers();
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();

    final notes = await db.query(noteTable);

    if (notes.isEmpty) {
      throw CouldNotRetriveNotes();
    } else {
      return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
    }
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final note = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (note.isEmpty) {
      throw CouldNotFindNote();
    } else {
      return DatabaseNote.fromRow(note.first);
    }
  }

  Future<DatabaseUser> getUser({required int id}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DataBaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DataBaseAlreadyOpened();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final path = join(docsPath.path, dbName);
      // open database
      final db = await openDatabase(path);

      _db = db;
      // create user table
      db.execute(createUsertable);
      // create note table
      db.execute(createNotetable);
    } on MissingPlatformDirectoryException {
      throw CouldNotOpenDocumentDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;

    if (db == null) {
      throw DataBaseIsNotOpen();
    } else {
      db.close();
      _db = null;
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  final String? name;

  const DatabaseUser({
    required this.id,
    required this.email,
    this.name,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String,
        name = map[nameColumn] as String?;

  @override
  String toString() => "ID: $id, name: $name, email: $email";

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String title;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.title,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        title = map[titleColumn] as String,
        text = map[textColumn] as String,
        isSyncedWithCloud = (map[isSyncedColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      "id: $id, userId: $userId \n title: $title \n text: $text";

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const userTable = 'user';
const noteTable = 'note';
const idColumn = 'id';
const emailColumn = 'email';
const nameColumn = 'name';
const userIdColumn = 'user_id';
const textColumn = 'text';
const titleColumn = 'title';
const isSyncedColumn = 'is_synced_with_cloud';
const createUsertable = '''CREATE TABLE "user" (
    "id"	INTEGER NOT NULL UNIQUE,
    "email"	TEXT NOT NULL UNIQUE,
    "name"	TEXT,
    PRIMARY KEY("id" AUTOINCREMENT)
  )''';
const createNotetable = '''CREATE TABLE "note" (
    "id"	INTEGER NOT NULL,
    "user_id"	INTEGER NOT NULL,
    "title"	TEXT NOT NULL,
    "text"	INTEGER NOT NULL,
    "is_synced_with_cloud"	INTEGER DEFAULT 0,
    PRIMARY KEY("id" AUTOINCREMENT)
  )''';
