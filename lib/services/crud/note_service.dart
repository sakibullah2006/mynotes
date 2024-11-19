import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart' show immutable;
import 'package:mynotes/services/crud/db_exceptions.dart';
import 'package:mynotes/utilities/extensions/filter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class NotesService {
  Database? _db;
  DatabaseUser? _user;
  List<DatabaseNote> _note = [];

  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_note);
      },
    );
  }

  static final NotesService _instance = NotesService._sharedInstance();

  factory NotesService() => _instance;

  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          log("user, ${currentUser.name} , note, ${note.title}  is in cache");
          return note.userId == currentUser.id;
        } else {
          log("User is not set, cannot read notes. Set a user first.");
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });

  Future<void> _cacheNotes() async {
    final notes = await getAllNotes();
    _instance._note = notes.toList();
    _instance._notesStreamController.add(_note);
  }

  Future<DatabaseUser> getOrCreateUser({
    required String name,
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(name: name, email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<DatabaseUser> createUser({
    required String name,
    required String email,
  }) async {
    await _ensureDBIsOpen();
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
    final userId = await db.insert(
      userTable,
      {
        nameColumn: name.trim(),
        emailColumn: email.toLowerCase().trim(),
      },
    );

    return DatabaseUser(
      id: userId,
      email: email,
      name: name,
    );
  }

  Future<DatabaseNote> createNote({
    required DatabaseUser owner,
    required String title,
    required String description,
  }) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();

    // Verify User id hash
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    // add note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      titleColumn: title.trim(),
      descriptionColumn: description.trim(),
      timeColumn: DateTime.now().toString(),
      isSyncedColumn: 1
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      title: title,
      description: description,
      isSyncedWithCloud: true,
      timestamp: DateTime.now().toString(),
    );

    _instance._note.add(note);
    _instance._notesStreamController.add(_instance._note);

    log("note created");
    return note;
  }

  Future<DatabaseUser> updateUser({
    required DatabaseUser user,
    required String name,
  }) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();

    await getUser(email: user.email);

    final updateCount = await db.update(
      userTable,
      {nameColumn: name},
      where: 'id = ?',
      whereArgs: [user.id],
    );

    if (updateCount == 0) {
      throw CouldNotUpdateUser();
    } else {
      return await getUser(email: user.email);
    }
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String description,
    required String title,
  }) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updateCount = await db.update(
      noteTable,
      {
        titleColumn: title,
        descriptionColumn: description,
        isSyncedColumn: 0,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _instance._note.removeWhere((note) => note.id == updatedNote.id);
      _instance._note.add(updatedNote);
      _instance._notesStreamController.add(_instance._note);

      log("note updated");
      return updatedNote;
    }
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final deletecount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletecount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _instance._note.removeWhere((note) => note.id == id);
      _instance._notesStreamController.add(_instance._note);
    }
  }

  Future<void> deleteUser({required int id}) async {
    await _ensureDBIsOpen();
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
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();

    final deleteCount = await db.delete(noteTable);
    if (deleteCount == 0) {
      throw CouldNotDeleteNotes();
    } else {
      _instance._note = [];
      _instance._notesStreamController.add(_instance._note);
    }
  }

  Future<void> deleteAllUsers() async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();

    final deleteCount = await db.delete(userTable);
    if (deleteCount == 0) {
      throw CouldNotDeleteUsers();
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();

    final notes = await db.query(noteTable);

    if (notes.isEmpty) {
      throw CouldNotRetriveNotes();
    } else {
      return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
    }
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      _instance._note.removeWhere((note) => note.id == id);
      _instance._note.add(note);
      return note;
    }
  }

  Future<DatabaseUser> getUser({required email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _instance._db;
    if (db == null) {
      throw DataBaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> _ensureDBIsOpen() async {
    try {
      open();
    } on DataBaseAlreadyOpened {
      log("log: Database Already Open");
    }
  }

  Future<void> open() async {
    if (_instance._db != null) {
      throw DataBaseAlreadyOpened();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final path = join(docsPath.path, dbName);
      log("log: Database Path: $path");
      // open database
      final db =
          await openDatabase(path, version: 1, onCreate: (db, version) async {
        // create user table
        await db.execute(createUserTable);
        // create note table
        await db.execute(createNoteTable);
      });
      _instance._db = db;
      log(db.isOpen ? 'log: Database Opened' : 'log: Database Failed to Open');

      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw CouldNotOpenDocumentDirectory();
    }
  }

  Future<void> close() async {
    final db = _instance._db;

    if (db == null) {
      throw DataBaseIsNotOpen();
    } else {
      await db.close();
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
    required this.name,
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
  final String description;
  final String timestamp;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        title = map[titleColumn] as String,
        description = map[descriptionColumn] as String,
        timestamp = map[timeColumn] as String,
        isSyncedWithCloud = (map[isSyncedColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      "id: $id, userId: $userId \n title: $title \n text: $description";

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
const descriptionColumn = 'description';
const timeColumn = 'time_stamp';
const titleColumn = 'title';
const isSyncedColumn = 'is_synced_with_cloud';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "email" TEXT NOT NULL UNIQUE,
    "name" TEXT
);''';

const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "user_id" INTEGER NOT NULL,
    "title" TEXT,
    "description" TEXT,
    "time_stamp" TEXT,
    "is_synced_with_cloud" INTEGER DEFAULT 0,
    FOREIGN KEY("user_id") REFERENCES "user"("id")
);''';

// const createUsertable = '''CREATE TABLE IF NOT EXISTS "user" (
//     "id"	INTEGER NOT NULL UNIQUE,
//     "email"	TEXT NOT NULL UNIQUE,
//     "name"	TEXT,
//     PRIMARY KEY("id" AUTOINCREMENT)
//   );''';

// const createNotetable = '''CREATE TABLE IF NOT EXISTS "note" (
// 	"id"	INTEGER NOT NULL,
// 	"user_id"	INTEGER NOT NULL,
// 	"title"	TEXT,
// 	"description"	TEXT,
//   "time_stamp"	TEXT,
// 	"is_synced_with_cloud"	INTEGER DEFAULT 0,
// 	FOREIGN KEY("user_id") REFERENCES "user"("id"),
// 	PRIMARY KEY("id" AUTOINCREMENT)
// );''';
