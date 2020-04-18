import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uproplus/core/data/preferences.dart';
import 'package:uproplus/core/models/ad.dart';

class DbProvider {
  DbProvider._();

  static final _tableName = "Ads";
  static final _dbColumnId = "id";
  static final _dbColumnOwner = "owner";
  static final _dbColumnType = "type";
  static final _dbColumnMediaPath = "media_path";
  static final _dbColumnThumbnailPath = "thumbnail_path";
  static final _dbColumnDuration = "duration";
  static final _dbColumnAdText = "ad_text";
  static final _dbColumnOrder = "ad_order";

  static final _tableNameMulti = "AdsMulti";
  static final _dbColumnParentId = "parent_id";

  static final DbProvider _dbProvider = DbProvider._();

  Map<String, Database> _dbMap = {};

  static DbProvider get() {
    return _dbProvider;
  }

  Future<List<Ad>> getAds() async {
    final db = await _getDb();
    var result = await db.rawQuery(
        """
        SELECT * 
        FROM $_tableName
        WHERE $_dbColumnId NOT IN (SELECT $_dbColumnId FROM $_tableNameMulti)
        ORDER BY $_dbColumnOrder, $_dbColumnId
        """
//        LEFT JOIN $_tableNameMulti b ON a.$_dbColumnId = b.$_dbColumnId
//        WHERE b.$_dbColumnId IS NULL
    );
    return result.isNotEmpty ? _mapList(result) : [];
  }

  Future<List<Ad>> _mapList(List<Map<String, dynamic>> result) async {
    List<Future<Ad>> futureAds = result.map((ad) async => await _mapToAd(ad)).toList();
    Future<List<Ad>> futureList = Future.wait(futureAds);
    return await futureList;
  }

  Future<List<Ad>> getChildAds(String parentId) async {
    final db = await _getDb();
    var result = await db.query(
        _tableNameMulti,
        columns: [_dbColumnId],
        where: "$_dbColumnParentId = ? AND $_dbColumnId IS NOT NULL",
        whereArgs: [parentId]);
    return result.isNotEmpty ? _getAdsById(result.map((id) => id[_dbColumnId] as String).toList()) : [];
  }

  Future<int> getAdCount() async {
    final db = await _getDb();
    var result = await db.query(_tableName, columns: ['COUNT(*)']);
    return result.isNotEmpty ? Sqflite.firstIntValue(result) : 0;
  }

  Future<String> newAd(Ad ad) async {
    final db = await _getDb();
    await db.insert(_tableName, ad.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return ad.id;
  }

  Future<String> newChildAd(String parentId, Ad childAd) async {
    final db = await _getDb();
    await db.insert(_tableName, childAd.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await linkParentChildAd(parentId, childAd.id);
    return childAd.id;
  }

  Future linkParentChildAd(String parentId, String childId) async {
    final db = await _getDb();
    Map<String, dynamic> values = {
      _dbColumnId: childId,
      _dbColumnParentId: parentId
    };
    await db.insert(_tableNameMulti, values, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateAd(Ad ad) async {
    final db = await _getDb();
    int rowCount = await db.update(
        _tableName, ad.toMap(),
        where: "$_dbColumnId = ?",
        whereArgs: [ad.id],
        conflictAlgorithm: ConflictAlgorithm.replace
    );
    return rowCount;
  }

  Future<int> deleteAd(String id) async {
    final db = await _getDb();
    int rowCount = await db.delete(_tableName, where: "$_dbColumnId = ?", whereArgs: [id]);
    await db.delete(_tableNameMulti, where: "$_dbColumnId = ?", whereArgs: [id]);
    return rowCount;
  }

  Future deleteOthers(List<String> ids) async {
    final db = await _getDb();
    int rowCount = await db.delete(
        _tableName,
        where: "$_dbColumnId NOT IN (${ids.map((_) => '?').toList().join(',')})",
        whereArgs: ids
    );
    await db.delete(
        _tableNameMulti,
        where: "$_dbColumnId NOT IN (${ids.map((_) => '?').toList().join(',')})",
        whereArgs: ids
    );
    return rowCount;
  }

  Future<Ad> _mapToAd(Map<String, dynamic> raw) async {
    final Ad ad = Ad.fromMap(raw);
    if (ad.adType == AdType.multiAd) {
      ad.childAds = await getChildAds(ad.id);
    }
    return ad;
  }

  Future<List<Ad>> _getAdsById(List<String> ids) async {
    final db = await _getDb();
    var result = await db.query(
        _tableName,
        columns: ['*'], where: "$_dbColumnId IN (${ids.map((_) => '?').toList().join(',')})",
        whereArgs: ids,
        orderBy: " $_dbColumnOrder, $_dbColumnId"
    );
    return result.isNotEmpty ? result.map((ad) => Ad.fromMap(ad)).toList() : [];
  }

  Future<Database> _getDb() async {
    final account = await PreferencesProvider.get().getAccount();
    String userFolder;
    if (account == null || account.name.isEmpty) {
      userFolder = 'temp';
    } else {
      userFolder = account.name;
    }
    if (_dbMap[userFolder] == null) _dbMap[userFolder] = await _initDb(userFolder);
    return _dbMap[userFolder];
  }

  Future<Database> _initDb(String userFolder) async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, userFolder, "uproplus.db");
    print("db path: $path");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              """
              CREATE TABLE $_tableName(
              $_dbColumnId TEXT PRIMARY KEY,
                  $_dbColumnOwner TEXT,
                  $_dbColumnType TEXT,
                  $_dbColumnMediaPath TEXT,
                  $_dbColumnThumbnailPath TEXT,
                  $_dbColumnDuration INTEGER,
                  $_dbColumnAdText TEXT,
                  $_dbColumnOrder INTEGER
                  )
              """
          );
          await db.execute(
              """
                CREATE TABLE $_tableNameMulti(
                  $_dbColumnId TEXT PRIMARY KEY,
                  $_dbColumnParentId TEXT
                  )
              """
          );
        });
  }
}
