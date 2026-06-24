import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "mi_sintrom_v1.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Crea la tabla automáticamente si no existe
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE controles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        inr REAL,
        dosis REAL,
        fecha TEXT
      )
    ''');
  }

  // Función para insertar un informe/control
  Future<int> insertarControl(Map<String, dynamic> registro) async {
    final db = await database;
    return await db.insert('controles', registro);
  }

  // Función para obtener todos los controles guardados
  Future<List<Map<String, dynamic>>> getHistorialControles() async {
    final db = await database;
    return await db.query('controles');
  }
} // <-- LA CLASE AHORA SÍ SE CIERRA CORRECTAMENTE AL FINAL DE TODO