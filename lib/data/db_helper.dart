import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static const String TABLE_Todo = "todo";

  static const String COLUMN_Todo_SNO = "s_no";
  static const String COLUMN_Todo_DESC = "description";
  static const String COLUMN_Todo_STATUS = "isCompleted";

  DbHelper._();

  static final DbHelper getInstance = DbHelper._();

  Database? myDB;

  // Get database
  Future<Database> getDB() async {
    if (myDB != null) {
      return myDB!;
    }

    myDB = await openDB();

    return myDB!;
  }

  // Open database
  Future<Database> openDB() async {
    String dbPath = await getDatabasesPath();

    String path = join(dbPath, "todo.db");

    return await openDatabase(
      path,
      version: 1,

      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $TABLE_Todo (
            $COLUMN_Todo_SNO INTEGER PRIMARY KEY AUTOINCREMENT,
            $COLUMN_Todo_DESC TEXT NOT NULL,
            $COLUMN_Todo_STATUS INTEGER NOT NULL DEFAULT 0
          )
        ''');

        print("Database Created Successfully");
      },
    );
  }

  Future<bool> addTodo({required String mDesc}) async {
    try {
      final db = await getDB();

      int result = await db.insert(TABLE_Todo, {
        COLUMN_Todo_DESC: mDesc.trim(),
        COLUMN_Todo_STATUS: 0,
      });

      print("Todo Insert Result: $result");

      return result > 0;
    } catch (e) {
      print("ADD TODO ERROR: $e");

      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    try {
      final db = await getDB();

      List<Map<String, dynamic>> data = await db.query(
        TABLE_Todo,
        orderBy: "$COLUMN_Todo_SNO DESC",
      );

      print("Todo List: $data");

      return data;
    } catch (e) {
      print("GET TODO ERROR: $e");

      return [];
    }
  }

  Future<bool> updateTodo({required String mDesc, required int sno}) async {
    try {
      final db = await getDB();

      int result = await db.update(
        TABLE_Todo,
        {COLUMN_Todo_DESC: mDesc.trim()},
        where: "$COLUMN_Todo_SNO = ?",
        whereArgs: [sno],
      );

      return result > 0;
    } catch (e) {
      print("UPDATE TODO ERROR: $e");

      return false;
    }
  }

  Future<bool> updateStatus({required int sno, required int status}) async {
    try {
      final db = await getDB();

      int result = await db.update(
        TABLE_Todo,
        {COLUMN_Todo_STATUS: status},
        where: "$COLUMN_Todo_SNO = ?",
        whereArgs: [sno],
      );

      return result > 0;
    } catch (e) {
      print("STATUS UPDATE ERROR: $e");

      return false;
    }
  }

  Future<bool> delete({required int sno}) async {
    try {
      final db = await getDB();

      int result = await db.delete(
        TABLE_Todo,
        where: "$COLUMN_Todo_SNO = ?",
        whereArgs: [sno],
      );

      return result > 0;
    } catch (e) {
      print("DELETE TODO ERROR: $e");

      return false;
    }
  }
}
