import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const _dbName = 'staysync.db';
  static const _dbVersion = 21; // Increased version

  static const tableSecretaryUserData = 'SecretaryUserData';
  static const colUserId = 'userid';
  static const colName = 'name';
  static const colGender = 'gender';
  static const colDob = 'dob';
  static const colMobileNumber = 'mobile_number';
  static const colUserType = 'usertype';
  static const colBuildingId = 'building_id';
  static const colResidentName = 'resident_name';
  static const colNoOfFlats = 'no_of_flats';
  static const colAddress = 'address';
  static const colAddressProof = 'address_proof';
  static const colSecretaryId = 'secretary_id';
  static const colSecretaryName = 'secretary_name';
  static const colCreatedAt = 'created_at';
  static const colUpdatedAt = 'updated_at';
  static const colLastSynced = 'last_synced_at';
  static const jwtToken = 'auth_token';

  //Resient Database :

  static const restableResidentData = 'ResidentData';
  static const rescolUserId = 'userid';
  static const rescolUserName = 'user_name';
  static const rescolUserGender = 'user_gender';
  static const rescolUserDob = 'user_dob';
  static const rescolMobileNumber = 'mobile_number';
  static const rescolLoginId = 'login_id';
  static const rescolUserType = 'usertype';
  static const rescolResidentId = 'resident_id';
  static const rescolBuildingId = 'building_id';
  static const rescolWingNo = 'wing_no';
  static const rescolFlatNo = 'flat_no';
  static const rescolFloorNo = 'floor_no';
  static const rescolResidentName = 'resident_name';
  static const rescolCreatedAt = 'created_at';
  static const rescolUpdatedAt = 'updated_at';

  static const StaffData = 'StaffData';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    print("database Version : " + _dbVersion.toString());
    return await openDatabase(path,
        version: _dbVersion, onUpgrade: _onUpgrade, onCreate: _onCreate);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("Upgrading database from $oldVersion to $newVersion");

    if (oldVersion < 21) {
      // Handle schema changes between version 20 and 21
      print("Upgrading to version 21...");

      // Ensure tables are created if they don't already exist
      await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableSecretaryUserData (
        $colUserId TEXT PRIMARY KEY,
        $colName TEXT NOT NULL,
        $colGender TEXT,
        $colDob TEXT,
        $colMobileNumber TEXT NOT NULL,
        $colUserType TEXT NOT NULL,
        $colBuildingId TEXT,
        $colResidentName TEXT,
        $colNoOfFlats INTEGER,
        $colAddress TEXT,
        $colAddressProof TEXT,
        $colSecretaryId TEXT,
        $colSecretaryName TEXT,
        $colCreatedAt TEXT,
        $colUpdatedAt TEXT,
        $colLastSynced TEXT,
        $jwtToken TEXT
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS $restableResidentData (
        $rescolUserId TEXT PRIMARY KEY,
        $rescolUserName TEXT NOT NULL,
        $rescolUserGender TEXT,
        $rescolUserDob TEXT,
        $rescolMobileNumber TEXT NOT NULL,
        $rescolLoginId TEXT,
        $rescolUserType TEXT NOT NULL,
        $rescolResidentId TEXT,
        $rescolBuildingId TEXT,
        $rescolWingNo TEXT,
        $rescolFlatNo TEXT,
        $rescolFloorNo TEXT,
        $rescolResidentName TEXT NOT NULL,
        $rescolCreatedAt TEXT,
        $rescolUpdatedAt TEXT
      )
    ''');

      print("Version 21 schema changes applied.");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    print("Creating database...");

    await db.execute('''
    CREATE TABLE IF NOT EXISTS $tableSecretaryUserData (
      $colUserId TEXT PRIMARY KEY,
      $colName TEXT NOT NULL,
      $colGender TEXT,
      $colDob TEXT,
      $colMobileNumber TEXT NOT NULL,
      $colUserType TEXT NOT NULL,
      $colBuildingId TEXT,
      $colResidentName TEXT,
      $colNoOfFlats INTEGER,
      $colAddress TEXT,
      $colAddressProof TEXT,
      $colSecretaryId TEXT,
      $colSecretaryName TEXT,
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT,
      $colLastSynced TEXT,
      $jwtToken TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS $restableResidentData (
      $rescolUserId TEXT PRIMARY KEY,
      $rescolUserName TEXT NOT NULL,
      $rescolUserGender TEXT,
      $rescolUserDob TEXT,
      $rescolMobileNumber TEXT NOT NULL,
      $rescolLoginId TEXT,
      $rescolUserType TEXT NOT NULL,
      $rescolResidentId TEXT,
      $rescolBuildingId TEXT,
      $rescolWingNo TEXT,
      $rescolFlatNo TEXT,
      $rescolFloorNo TEXT,
      $rescolResidentName TEXT NOT NULL,
      $rescolCreatedAt TEXT,
      $rescolUpdatedAt TEXT
    )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS $StaffData (
    userid TEXT PRIMARY KEY,
    user_name TEXT NOT NULL,
    user_gender TEXT,
    user_dob TEXT,
    mobile_number TEXT NOT NULL,
    login_id TEXT,
    usertype TEXT NOT NULL,
    staff_id TEXT NOT NULL,
    staff_type TEXT NOT NULL,
    join_date TEXT,
    qr_code TEXT
  )
''');

    print("Tables created successfully.");
  }

  // Insert data into the `SecretaryUserData` table
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert(tableSecretaryUserData, user,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertStaffData(List<Map<String, dynamic>> staffData) async {
    final db = await database; // Access the database instance
    Batch batch = db.batch(); // Create a batch for bulk operations

    for (var staff in staffData) {
      batch.insert(
        'StaffData', // Target table
        staff, // Data to insert
        conflictAlgorithm:
            ConflictAlgorithm.replace, // Replace if conflict occurs
      );
    }

    try {
      await batch.commit(
          noResult:
              true); // Execute the batch and ignore results for better performance
      print("Staff data inserted successfully.");
    } catch (e) {
      print("Error inserting staff data: $e"); // Log any errors
    }
  }

  Future<int> insertResident(Map<String, dynamic> resident) async {
    final db = await database;
    return await db.insert(restableResidentData, resident,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getResidents() async {
    final db = await database;
    return await db.query(restableResidentData);
  }

  // Retrieve all users from the `SecretaryUserData` table
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query(tableSecretaryUserData);
  }

  // Assuming 'database' is a getter that initializes the SQLite database.
  Future<List<Map<String, dynamic>>> getStaff() async {
    final db = await database;
    return await db
        .query('StaffData'); // Assuming 'StaffData' is your table name
  }

  // Update a user's data
  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      tableSecretaryUserData,
      user,
      where: '$colUserId = ?',
      whereArgs: [user[colUserId]],
    );
  }

  // Delete a user from the `SecretaryUserData` table
  Future<int> deleteUser(String userId) async {
    final db = await database;
    return await db.delete(
      tableSecretaryUserData,
      where: '$colUserId = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteResident(String userId) async {
    final db = await database;
    return await db.delete(
      restableResidentData,
      where: '$colUserId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> clearResidentData() async {
    final db = await database;
    await db.delete(restableResidentData);
    print('All resident data cleared successfully.');
  }

  Future<void> clearAllData() async {
    print("Fuction Called");
    try {
      final db = await database;

      // List all tables you want to clear
      var tables = [
        tableSecretaryUserData,
        restableResidentData,
        StaffData
      ]; // Add all your table names here

      // Delete all records from each table
      for (var table in tables) {
        await db.delete(table);
        print('Cleared table: $table');
      }

      // Optionally, return a success message or perform any other action
      print('All data cleared successfully.');
    } catch (e) {
      // Handle any exceptions that occur
      print('Error clearing data: $e');
    }
  }
}
