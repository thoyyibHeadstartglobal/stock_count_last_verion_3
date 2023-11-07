import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  // 1.IMPORTHEADER
  // ---------------
  // AXDOCNO, STORECODE, TRANSTYPE, STATUS, USERNAME, DESCRIPTION, CREATEDDATE, DATAAREAID, DEVICEID

  initDb() async {
    final db = await SQLHelper.db();
  }

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
  CREATE TABLE IF NOT EXISTS  LoginTable (
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  userId TEXT,
  password TEXT,
  username  TEXT,
  userType  TEXT

  )
""");

    await database.execute("""CREATE TABLE IF NOT EXISTS 
    APPGENERALDATA(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        DEVICEID  TEXT,
        STORECODE TEXT,
        PONEXTDOCNO INTEGER,
        GRNNEXTDOCNO INTEGER,
        RONEXTDOCNO INTEGER,
        RPNEXTDOCNO INTEGER,
        STNEXTDOCNO INTEGER,
        TONEXTDOCNO INTEGER,
        TOOUTNEXTDOCNO INTEGER,
        TOINNEXTDOCNO INTEGER,
        MJNEXTDOCNO INTEGER,
        isDeactivate BOOLEAN
      )
      """);

    await database.execute("""CREATE TABLE IF NOT EXISTS IMPORTHEADER(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        AXDOCNO  TEXT,
        STORECODE TEXT,
        TRANSTYPE TEXT,
        STATUS TEXT,
        USERNAME TEXT,
        DESCRIPTION TEXT,
        CREATEDDATE  TEXT,
        DATAAREAID TEXT,
        DEVICEID TEXT,
        unique(DATAAREAID,AXDOCNO,TRANSTYPE,DEVICEID)
      )
      """);

    await database.execute("""CREATE TABLE IF NOT EXISTS GeneralSaveHomeData(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        type  TEXT,
        value TEXT
       
      )
      """);

    await database.execute("""CREATE TABLE IF NOT EXISTS ITEMMASTER(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
       ITEMBARCODE TEXT,
        ItemId  TEXT,
        ItemName TEXT,
        DATAAREAID TEXT,
        WAREHOUSE TEXT,
        CONFIGID TEXT,
        COLORID  TEXT,
        SIZEID TEXT,
        STYLEID TEXT,
         INVENTSTATUS TEXT,
          QTY TEXT,
           UNIT TEXT,
           ItemAmount TEXT,
           BatchEnabled BOOLEAN,
           BatchedItem BOOLEAN
      )
      """);

    //
    // 2.IMPORTDETAILS
    // ---------------
    //     AXDOCNO, STORECODE, BARCODE, TRANSTYPE, ITEMID,
    // ITEMNAME, UOM, QTY, DEVICEID, CONFIGID , SIZEID , COLORID
    // ,STYLESID,INVENTSTATUS

    await database.execute("""CREATE TABLE IF NOT EXISTS IMPORTDETAILS(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
         AXDOCNO TEXT,
        STORECODE TEXT,
          BARCODE TEXT,
        TRANSTYPE TEXT,
         ITEMID  TEXT,
        ITEMNAME TEXT,
         UOM  TEXT,
           QTY TEXT,
         DEVICEID TEXT,
        CONFIGID TEXT,
        SIZEID TEXT,
        COLORID TEXT,
        STYLESID TEXT,       
        INVENTSTATUS  TEXT, 
         BatchEnabled BOOLEAN,
           BatchedItem BOOLEAN,
        unique (AXDOCNO,STORECODE,BARCODE,TRANSTYPE,DEVICEID)
      )
      """);

    await database.execute("""
     CREATE  TABLE IF NOT EXISTS UNITMASTER( 
    RECID  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    UNITNAME TEXT,
    unique(UNITNAME)
    )
     """);

    await database.execute(""" CREATE  TABLE IF NOT EXISTS VARSTYLES( 
    RECID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    STYLEID TEXT
    )
    
     """);

    await database.execute(""" CREATE  TABLE IF NOT EXISTS VARCONFIG( 
    RECID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    CONFIGID TEXT
    )
     """);

    await database.execute(""" CREATE  TABLE IF NOT EXISTS VARCOLOR( 
    RECID  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    COLORID TEXT
    )
     """);

    await database.execute(""" CREATE  TABLE IF NOT EXISTS VARSIZE( 
    RECID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    SIZEID TEXT
    )
     """);

    //     FOREIGN KEY(sId) REFERENCES InboundTransPurchaseApiData(pid)

    // id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,

    await database.execute("""
        CREATE TABLE IF NOT EXISTS TRANSHEADER(
         RecId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        DOCNO TEXT ,
        AXDOCNO TEXT,    
     STORECODE TEXT,
    TOSTORECODE TEXT,
    TRANSTYPE  TEXT,
    STATUS INTEGER,
    USERNAME TEXT,
    DESCRIPTION TEXT,
    CREATEDDATE TEXT,
    DATAAREAID TEXT,
    DEVICEID TEXT,
    TYPEDESCR TEXT,
    VRLOCATION TEXT,
    JournalName TEXT,
     unique (DOCNO,AXDOCNO,STORECODE,TRANSTYPE,DATAAREAID,DEVICEID)

      )
      """);

    await database.execute("""
    CREATE TABLE IF NOT EXISTS
    TRANSDETAILS(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        LISTID INTEGER,
        HRecId  INTEGER,
        DOCNO  TEXT,
        AXDOCNO TEXT,
        STATUS INTEGER,
        ITEMID  TEXT,
        ITEMNAME  TEXT,
        TRANSTYPE  TEXT,
        DEVICEID  TEXT,
        QTY  TEXT,
        UOM   TEXT,
        BARCODE  TEXT,
        CREATEDDATE  TEXT,
        INVENTSTATUS  TEXT,
        SIZEID  TEXT,
        COLORID  TEXT,
        CONFIGID  TEXT,
        STYLESID  TEXT,
        STORECODE  TEXT,
        LOCATION  TEXT,
        BATCHNO TEXT,
        EXPDATE TEXT,
        PRODDATE TEXT,
         BatchEnabled BOOLEAN,
           BatchedItem BOOLEAN,
        unique(DOCNO,ITEMID,ITEMNAME,BARCODE,TRANSTYPE,UOM,BATCHNO,EXPDATE,PRODDATE)
        )
      """);
  }

  static Future<sql.Database> db() async {

    String ? databasespath = await getDatabasesPath();
      // print();


    print("The original path is : ${databasespath}/dynamicconnectdb.db");
    print(await sql.getDatabasesPath());
    // String path = join("dynamicconnectdb.db");

    return sql.openDatabase(
      '${databasespath}/dynamicconnectdb.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }
  //add transaction header

  addTrasactionHeader({
    DOCNO,
    AXDOCNO,
    STORECODE,
    TOSTORECODE,
    TRANSTYPE,
    STATUS,
    USERNAME,
    DESCRIPTION,
    CREATEDDATE,
    DATAAREAID,
    DEVICEID,
    TYPEDESCR,
    VRLOCATION,
  }) {}

  calculateTotal({DOCNO, ITEMID, ITEMNAME, BARCODE, TRANSTYPE, UOM}) async {
    final db = await SQLHelper.db();
    // final List<Map<String, dynamic>> maps = await db.rawQuery('''SELECT SUM(price) as Total TRANSDETAILS WHERE "
    //     "DOCNO="$DOCNO" AND ITEMID = "$ITEMID" AND ITEMNAME="$ITEMNAME" AND TRANSTYPE="$TRANSTYPE" AND BARCODE="$BARCODE" AND UOM="$UOM";''');

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'SELECT SUM(QTY) as Total  from  TRANSDETAILS WHERE DOCNO="$DOCNO" AND ITEMID = "$ITEMID" AND ITEMNAME="$ITEMNAME" AND TRANSTYPE="$TRANSTYPE" AND BARCODE="$BARCODE" AND UOM="$UOM";'
        '');

    print(maps.toList());
    print("Result 250 db");
    return maps;
  }

  getFindItemExistOrnotTRANSDETAILS(
      {DOCNO, ITEMID, ITEMNAME, BARCODE, TRANSTYPE, UOM}) async {
    // DOCNO,AXDOCNO,STORECODE,TRANSTYPE,DATAAREAID,DEVICEID

    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * from  TRANSDETAILS WHERE DOCNO="$DOCNO" AND ITEMID = "$ITEMID" AND ITEMNAME="$ITEMNAME" AND TRANSTYPE="$TRANSTYPE" AND BARCODE="$BARCODE" AND UOM="$UOM";'
        '');
    print("db data 234");
    print(maps);
    return maps;
  }

  getFindItemExistOrnotTRANSDETAILS_GRN_STOCKCOUNT(
      {DOCNO, ITEMID, ITEMNAME, BARCODE, TRANSTYPE, UOM, BATCHNO}) async {
    // DOCNO,AXDOCNO,STORECODE,TRANSTYPE,DATAAREAID,DEVICEID

    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * from  TRANSDETAILS WHERE DOCNO="$DOCNO" AND ITEMID = "$ITEMID" AND ITEMNAME="$ITEMNAME" AND TRANSTYPE="$TRANSTYPE" AND BARCODE="$BARCODE" AND UOM="$UOM" AND BATCHNO ="$BATCHNO";'
        '');
    print("db data 234");
    print(maps);
    return maps;
  }

  // get db data by count
  Future<dynamic> getItemMatersByCount() async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * from  ITEMMASTER  LIMIT 15;'
        '');

    print(maps);
    return maps;
  }

  // get db data
  Future<dynamic> getItemMaters(int? lastId) async {
    final db = await SQLHelper.db();
    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * FROM ITEMMASTER Where id > $lastId LIMIT 15;'
        '');
    print(maps);
    return maps;
  }

  // get db data
  Future<dynamic> getUOMMessures() async {
    final db = await SQLHelper.db();

    final List<dynamic> maps = await db.rawQuery(''
        'SELECT  * FROM UNITMASTER;'
        '');
    print("unites master ");
    print(maps);
    return maps;
  }

// get db data
  Future<dynamic> getHeaderOrders(String? transType) async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'SELECT  AXDOCNO FROM importheader WHERE STATUS < 3 AND TRANSTYPE="$transType" ORDER BY  id DESC;'
        '');
    print(maps);
    return maps;
  }

  // get db data by scanning with barcode
  Future<dynamic> getImportedDetailsBySearchScanBarcode(
      String? barcode, String? AXDOCNO) async {
    print("axdoc no");
    print(AXDOCNO);
    final db = await SQLHelper.db();

    // String dt =
    //     "'%$key%'" ;
    // print(dt);
    // final List<Map<String, dynamic>> maps = await db.rawQuery(''
    //     'select * from  IMPORTDETAILS WHERE  BARCODE  LIKE $dt;'
    //     '');

    // String dt =
    //     "'%$key%'" ;
    // print(dt);
    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'SELECT * FROM IMPORTDETAILS WHERE  BARCODE ="$barcode" AND AXDOCNO="$AXDOCNO";'
        '');
    // print(maps);
    return maps;
  }

  // get db data by scanning with barcode
  Future<dynamic> getITEMMASTERBySearchScanBarcode(String? barcode) async {
    final db = await SQLHelper.db();

    // String dt =
    //     "'%$key%'" ;
    // print(dt);
    // final List<Map<String, dynamic>> maps = await db.rawQuery(''
    //     'select * from  IMPORTDETAILS WHERE  BARCODE  LIKE $dt;'
    //     '');

    // String dt =
    //     "'%$key%'" ;
    // print(dt);
    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * from  ITEMMASTER WHERE  ITEMBARCODE="$barcode";'
        '');

    // print(maps);
    return maps;
  }

  // get db data by count
  Future<dynamic> getIMPORTDETAILSByCountInit(String? AXDOCNO) async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * from  IMPORTDETAILS  where AXDOCNO ="$AXDOCNO" LIMIT 15;'
        '');

    print(maps);
    return maps;
  }

  // get db data by count
  Future<dynamic> getIMPORTDETAILSByCount(int? lastId, String? AXDOCNO) async {
    final db = await SQLHelper.db();
    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * FROM IMPORTDETAILS Where id > $lastId AND  AXDOCNO ="$AXDOCNO" LIMIT 15;'
        '');
    print(maps);
    return maps;
  }

  // get db data by imported details
  Future<dynamic> getTRANSDETAILSDetailsBySearch(
      String? key, String? transType) async {
    final db = await SQLHelper.db();

    String dt = "'%$key%'";
    print(
        'SELECT  * FROM TRANSDETAILS WHERE (ITEMID  LIKE $dt OR ITEMNAME  LIKE $dt)'
        ' AND (TRANSTYPE="$transType" AND STATUS < 3 ORDER BY LISTID  DESC);');

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'SELECT  * FROM TRANSDETAILS WHERE ( ITEMID  LIKE $dt OR ITEMNAME  LIKE $dt)'
        ' AND (TRANSTYPE="$transType" AND STATUS < 3 ORDER BY LISTID DESC  LIMIT 15;');

    print(maps);
    return maps;
  }

  // get db data
  Future<dynamic> getIMPORTDETAILS(int? lastId, String? AXDOCNO) async {
    final db = await SQLHelper.db();
    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * FROM IMPORTDETAILS Where id > $lastId AND  AXDOCNO ="$AXDOCNO" LIMIT 15;'
        '');
    print(maps);
    return maps;
  }

  // get db data 372
  Future<dynamic> getIMPORTDETAILSLastId(String? AXDOCNO) async {
    final db = await SQLHelper.db();

    final data = await db.rawQuery('SELECT * FROM IMPORTDETAILS');
    print("data...401");
    print(data);
    var lastId;
    if (data != [] || data != null) {
      lastId = data.last['id'];
    } else {
      lastId = 1;
    }
    // final List<Map<String, dynamic>> maps = await db.rawQuery(''
    //     'select * FROM IMPORTDETAILS Where id > $lastId AND  AXDOCNO ="$AXDOCNO" LIMIT 15;'
    //     '');
    // print(maps);
    return lastId;
  }

  // get db data by imported details
  Future<dynamic> getImportedDetailsBySearch(
      String? key, String? AXDOCNO) async {
    print("axdoc no..368");
    print(AXDOCNO);
    final db = await SQLHelper.db();
    String dt = "'%$key%'";
    print(dt);
    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * from  IMPORTDETAILS WHERE  AXDOCNO ="$AXDOCNO" AND (ITEMID  LIKE $dt  OR  ITEMNAME  LIKE $dt);'
        '');
    print(maps);
    return maps;
  }

  // get db data by imported details Load more items
  Future<dynamic> getTRANSDETAILSDetailsBySearchLoad(
      String? firstId, String? transType, String? AXDOCNO) async {
    final db = await SQLHelper.db();

    print(
        'SELECT * FROM TRANSDETAILS where LISTID < $firstId  AND AXDOCNO="$AXDOCNO" AND'
        'STATUS <3 AND TRANSTYPE="$transType"   LIMIT 15;');

    final List<Map<String, dynamic>> maps = await
        //  db.rawQuery('''SELECT * FROM TRANSDETAILS where '
        // ' id > $lastId  AND AXDOCNO="$AXDOCNO" AND STATUS <3 AND'
        //   ' TRANSTYPE="$transType"   LIMIT 1;'');

        db.rawQuery(''
            'SELECT * FROM TRANSDETAILS where LISTID < $firstId AND AXDOCNO="$AXDOCNO" AND STATUS <3 AND TRANSTYPE="$transType" ORDER BY LISTID DESC LIMIT 15 ;'
            // 'SELECT * FROM TRANSDETAILS where   AXDOCNO="$AXDOCNO" AND '
            // ' id > $lastId AND STATUS <3 AND TRANSTYPE="$transType"'
            //  'ORDER BY LISTID DESC LIMIT 15;'

            );

    print(maps);
    return maps;
  }

  // get db data
  Future<dynamic> getItemMatersBySearch(String? key) async {
    final db = await SQLHelper.db();

    String dt = "'%$key%'";
    // print(dt);
    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'SELECT  DISTINCT *  FROM  ITEMMASTER WHERE   ItemId  LIKE $dt  OR  ItemName  LIKE $dt OR  ITEMBARCODE LIKE $dt;'
        '');

    // print(maps);
    print("Item Masters by search");

    return maps;
  }

  // get admin user
  Future<dynamic> getUserLoginHSAdmin() async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * from  LoginTable  where   username = "hsadmin" OR username="Hsadmin" and password="hsadmin";'
        '');
    maps.length <= 0 ? await addHSAdminUser() : "Empty";
  }

  // get db data
  Future<dynamic> getUserLogin() async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * from  LoginTable  where   username = "Administrator" OR username = "administrator" and password="@dmin";'
        '');

    maps.isEmpty ? await addAdminUser() : "Empty";
  }

  Future<dynamic> checkAdminUserLoginByLoad({userId, password}) async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * from  LoginTable  where   userId = "$userId" and password="$password";'
        '');
    return maps;
  }

// Check admin logged or not
  Future<dynamic> checkAdminUserLogin({userId, password}) async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * from  LoginTable  where   userId = "$userId" and password="$password";'
        '');
    return maps.isEmpty ? "Login failed" : "Login Success";
  }

  Future<dynamic> getUserWithOutAdmin() async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * from  LoginTable  where   userType != "admin";'
        '');

    return maps;
  }

  // delete users
  deleteUsers(id) async {
    print(id);
    // return;
    // final db = await SQLHelper.db();
    // return await db.rawDelete("Delete * from InboundTransPurchaseApiData");
    final db = await SQLHelper.db();
    try {
      await db.delete(
        "LoginTable",
        where: "id = ?",
        whereArgs: [id],
      );
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  // get db data
  Future<dynamic> getUsers() async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * from  LoginTable;'
        '');
    print(maps);
    return maps;
  }

  deleteAllPurchaseDataAPIFromHistory(id) async {
    // final db = await SQLHelper.db();
    // return await db.rawDelete("Delete * from InboundTransPurchaseApiData");
    final db = await SQLHelper.db();
    try {
      await db.delete(
        "InboundTransPurchaseApiData",
        where: "apiDataId = ?",
        whereArgs: [id],
      );
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  deleteAllPurchaseDataAPI(String type) async {
    // final db = await SQLHelper.db();
    // return await db.rawDelete("Delete * from InboundTransPurchaseApiData");
    final db = await SQLHelper.db();
    try {
      await db.delete(
        "InboundTransPurchaseApiData",
        where: "isReceiveTrans = ? and transactionType =? ",
        whereArgs: [0, type],
      );
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  deleteAllPurchaseSgtin(String type) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("InboundTransSgtin",
          where: "isReceiveTrans = ? and transactionType =? ",
          whereArgs: [0, type]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
    // return await db.rawDelete("Delete * from InboundTransSgtin");
  }

  deleteAllPurchaseSscc(String type) async {
    final db = await SQLHelper.db();
    // return await db.rawDelete("Delete * from InboundTransSscc");
    try {
      await db.delete("InboundTransSscc",
          where: "isReceiveTrans = ? and transactionType =? ",
          whereArgs: [0, type]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  deleteAllFromHistoryPurchaseSgtin(String type, id) async {
    final db = await SQLHelper.db();
    try {
      // InboundTransPurchaseApiData e inner join
      final List<Map<String, dynamic>> maps = await db.rawQuery(''
          'select apiDataId,e.id,c.documentNo as DOCNO ,c.gtin as GTIN ,c.batch as BATCHNO ,c.expiry EXPDATE,c.sscc as SSCC,c.slno as SERIAL,e.TRANSTYPE,e.ItemId as ItemId,e.TOSTORECODE,e.GTINUnit as  GTINUNIT, e.GTINReceiveQTY as RECIEVEDQTY,e.AXDOCNO as TRANSID,e.STORECODE,e.DEVICEID,e.CREATEDDATE from InboundTransPurchaseApiData e inner join InboundTransSgtin c where c.gtin=e.GTIN and c.documentNo=e.AXDOCNO and  c.transactionType = "${type.toString()}" and c.isReceiveTrans=1;'
          '');
      print("deleted is:...");
      print(maps[0]['apiDataId'].runtimeType);
      deleteAllPurchaseDataAPIFromHistory(id);
      print(maps);

      await db.rawQuery(''
          'delete  from  InboundTransSgtin  where  transactionType = "${type.toString()}" and isReceiveTrans=1 and id=$id;'
          '');
      print("deleted is:...");
      print(maps);
      // db.delete("InboundTransPurchaseApiData",
      //     where: "isReceiveTrans = ? and transactionType =? ",
      //     whereArgs: [1, type]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
    // return await db.rawDelete("Delete * from InboundTransSgtin");
  }

  deleteAllFromHistoryPurchaseSscc(String type, id) async {
    final db = await SQLHelper.db();
    try {
      await db.rawQuery(''
          'delete  from  InboundTransSscc where   transactionType = "${type.toString()}" and isReceiveTrans=1 and id=$id;'
          '');

      // db.delete("InboundTransSgtin",
      //     where: "isReceiveTrans = ? and transactionType =? ",
      //     whereArgs: [1, type]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
    // return await db.rawDelete("Delete * from InboundTransSgtin");
  }

  // get db data
  Future<dynamic> getDbData(String type) async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select  AXDOCNO as DOCNO ,gtin as GTIN ,batch as BATCHNO ,expiry EXPDATE,sscc as SSCC,slno as SERIAL,TRANSTYPE,ItemId as ItemId,TOSTORECODE,GTINUnit as  GTINUNIT,GTINReceiveQTY as RECIEVEDQTY,AXDOCNO as TRANSID,STORECODE,DEVICEID,CREATEDDATE from  InboundTransSgtin  where   transactionType = "${type.toString()}" and isReceiveTrans=false;'
        '');
    print("type : $type");
    print(maps);

    return maps;

    // await db.rawQuery(''
    //     'select e.*  from InboundTransPurchaseApiData e inner join InboundTransSgtin c where  c.documentNo=e.AXDOCNO;'
    //     '');
  }

  // get db data
  Future<dynamic> getDbDataProductStatus() async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select c.documentNo as DOCNO ,c.gtin as GTIN ,c.batch as BATCHNO ,c.expiry EXPDATE,c.sscc as SSCC,c.slno as SERIAL,e.TRANSTYPE,e.ItemId as ItemId,e.TOSTORECODE,e.GTINUnit as  GTINUNIT, e.GTINReceiveQTY as RECIEVEDQTY,e.AXDOCNO as TRANSID,e.STORECODE,e.DEVICEID,e.CREATEDDATE from InboundTransPurchaseApiData e inner join InboundTransSgtin c where  c.documentNo=e.AXDOCNO  and c.isReceiveTrans=false and c.productStatus=1;'
        '');

    print(maps);

    return maps;

    // await db.rawQuery(''
    //     'select e.*  from InboundTransPurchaseApiData e inner join InboundTransSgtin c where  c.documentNo=e.AXDOCNO;'
    //     '');
  }

  Future<int> createUser(String username, String password) async {
    final db = await SQLHelper.db();

    final data = {'username': username, 'password': password};
    final id = await db.insert('userdetails', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  // AXDOCNO  TEXT,
  // OrderAccount TEXT,
  // OrderAccountName TEXT,
  //     FROMSTORECODE TEXT,
  // TOSTORECODE  TEXT,
  //     ItemId TEXT,
  // ItemName TEXT,
  //     ITEMBARCODE  TEXT,
  // DATAAREAID TEXT,
  //     WAREHOUSE TEXT,
  // CONFIGID  TEXT,
  //     COLORID TEXT,
  // SIZEID TEXT,
  //     STYLEID  TEXT,
  // INVENTSTATUS TEXT,
  //     QTY DOUBLE,
  // UNIT  TEXT,
  //     TRANSTYPE INTEGER,
  // ItemAmount DOUBLE,
  //     GTIN  TEXT,
  // GTINUnit TEXT,
  //     GTINOrderQTY DOUBLE,
  // GTINReceiveQTY  DOUBLE,
  //     HeaderOnly INTEGER,
  // Description TEXT,
  //     STORECODE TEXT,
  // CREATEDDATE TEXT,

  // add general save home data
  Future<int> addGeneralSaveHomeData(
    type,
    value,
  ) async {
    final db = await SQLHelper.db();
    final data = {"type": type, "value": value};

    final id = await db.insert('GeneralSaveHomeData', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // update general save home
  Future<int> updateGeneralSaveHomeData(
    // Id,
    type,
    value,
  ) async {
    final db = await SQLHelper.db();
    final data = {
      // "id":Id,
      "type": type,
      "value": value,
    };
    final id = await db.update('GeneralSaveHomeData', data,
        where: "type = ?",
        whereArgs: [type],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    // final id = await db.insert('GeneralSaveHomeData', data,
    //     conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // delete save general
  deleteGeneralSaveHomeData() async {
    // print(id);
    // return;
    // final db = await SQLHelper.db();
    // return await db.rawDelete("Delete * from InboundTransPurchaseApiData");
    final db = await SQLHelper.db();
    try {
      await db.delete(
        "GeneralSaveHomeData",
        // where: "id = ?",
        // whereArgs: [id],
      );
      await db.delete("IMPORTDETAILS");
      await db.delete("IMPORTHEADER");
      await db.delete("TRANSDETAILS");
      await db.delete("TRANSHEADER");
      // addIMPORTHEADERToPullData()
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  Future<dynamic> getGeneralSaveHomeData() async {
    final db = await SQLHelper.db();
    return db.query(
      'GeneralSaveHomeData',
    );
  }

  // AXDOCNO TEXT,
  //     STORECODE TEXT,
  // BARCODE TEXT,
  //     TRANSTYPE TEXT,
  // ITEMID  TEXT,
  //     ITEMNAME TEXT,
  // UOM  TEXT,
  //     QTY TEXT,
  // DEVICEID TEXT,
  //     CONFIGID TEXT,
  // SIZEID TEXT,
  //     COLORID TEXT,
  // STYLESID TEXT,
  //     INVENTSTATUS  TEXT,
  Future<int> addIMPORTDETAILSToPullData(
      {AXDOCNO,
      STORECODE,
      BARCODE,
      TRANSTYPE,
      STATUS,
      ITEMID,
      ITEMNAME,
      UOM,
      QTY,
      DEVICEID,
      CONFIGID,
      SIZEID,
      COLORID,
      STYLESID,
      INVENTSTATUS,
      BATCHENABLED,
      BATCHEDITEM}) async {
    final db = await SQLHelper.db();

    final data = {
      "AXDOCNO": AXDOCNO,
      "STORECODE": STORECODE,
      "BARCODE": BARCODE,
      "TRANSTYPE": TRANSTYPE,
      "ITEMID": ITEMID,
      "ITEMNAME": ITEMNAME,
      "UOM": UOM,
      "QTY": QTY,
      "DEVICEID": DEVICEID,
      "CONFIGID": CONFIGID,
      "SIZEID": SIZEID,
      "COLORID": COLORID,
      "STYLESID": STYLESID,
      "INVENTSTATUS": INVENTSTATUS,
      "BatchEnabled": BATCHENABLED,
      "BatchedItem": BATCHEDITEM
    };

    final id = await db.insert('IMPORTDETAILS', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  Future<int> addIMPORTHEADERToPullData(
      {AXDOCNO,
      STORECODE,
      TRANSTYPE,
      STATUS,
      USERNAME,
      DESCRIPTION,
      CREATEDDATE,
      DATAAREAID,
      DEVICEID}) async {
    final db = await SQLHelper.db();

    final data = {
      "AXDOCNO": AXDOCNO,
      "STORECODE": STORECODE,
      "TRANSTYPE": TRANSTYPE,
      "STATUS": STATUS,
      "USERNAME": USERNAME,
      "DESCRIPTION": DESCRIPTION,
      "CREATEDDATE": CREATEDDATE,
      "DATAAREAID": DATAAREAID,
      "DEVICEID": DEVICEID
    };

    final id = await db.insert('IMPORTHEADER', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  Future<int> addItemMasterToPullData(
      {ITEMBARCODE,
      ItemId,
      ItemName,
      DATAAREAID,
      WAREHOUSE,
      CONFIGID,
      COLORID,
      SIZEID,
      STYLEID,
      INVENTSTATUS,
      QTY,
      UNIT,
      ItemAmount,
      BatchEnabled,
      BatchedItem}) async {
    final db = await SQLHelper.db();

    final data = {
      "ITEMBARCODE": ITEMBARCODE,
      "ItemId": ItemId,
      "ItemName": ItemName,
      "DATAAREAID": DATAAREAID,
      "WAREHOUSE": WAREHOUSE,
      "CONFIGID": CONFIGID,
      "COLORID": COLORID,
      "SIZEID": SIZEID,
      "STYLEID": STYLEID,
      "INVENTSTATUS": INVENTSTATUS,
      "QTY": QTY,
      "UNIT": UNIT,
      "ItemAmount": ItemAmount,
      "BatchEnabled": BatchEnabled,
      "BatchedItem": BatchedItem
    };

    final id = await db.insert('ITEMMASTER', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }


  addMASTERTOFEATURES() async {
    final db = await SQLHelper.db();

    await db.rawQuery(''
        'INSERT OR REPLACE INTO UNITMASTER (UNITNAME) select distinct UNIT from  ItemMaster where  UNIT!="";'
        '');

    await db.rawQuery(''
        'INSERT OR REPLACE INTO VARCOLOR (COLORID) select  distinct COLORID from  ItemMaster where  COLORID!="";'
        '');

    await db.rawQuery(''
        'INSERT OR REPLACE INTO VARCONFIG (CONFIGID) select  distinct CONFIGID from  ItemMaster where  CONFIGID!="";'
        '');

    await db.rawQuery(''
        'INSERT OR REPLACE INTO  VARSIZE(SIZEID) select  distinct SIZEID from  ItemMaster where  SIZEID!="";'
        '');

    await db.rawQuery(''
        'INSERT OR REPLACE INTO  VARSTYLES(STYLEID) select  distinct STYLEID from  ItemMaster where  STYLEID!="";'
        '');
  }

  addIMPORTEDDETAILSTOFEATURES() async {
    final db = await SQLHelper.db();


    print("DB file : Imported ");
   print(  await db.rawQuery(''
       'select  distinct UOM from  IMPORTDETAILS where  UOM!="";'
       ''));

   // return;

    // await db.rawQuery(''
    //     'delete from UNITMASTER (UNITNAME) select  distinct UOM from  IMPORTDETAILS where  UOM !="";'
    // '');
    //
    //
    // await db.rawQuery(''
    //     'Delete UOM from  UNITMASTER where  UOM !="" AND UOM="";'
    //     '');


    await db.rawQuery(''
        'INSERT OR REPLACE INTO UNITMASTER (UNITNAME) select  distinct UOM from  IMPORTDETAILS where  UOM !="";'
        '');

    await db.rawQuery(''
        'INSERT OR REPLACE INTO OR REPLACE VARCOLOR (COLORID) select  distinct COLORID from  IMPORTDETAILS where  COLORID!="";'
        '');

    await db.rawQuery(''
        'INSERT OR REPLACE INTO  VARCONFIG (CONFIGID) select  distinct CONFIGID from  IMPORTDETAILS where  CONFIGID!="";'
        '');

    await db.rawQuery(''
        'INSERT OR REPLACE INTO  VARSIZE(SIZEID) select  distinct SIZEID from  IMPORTDETAILS where  SIZEID!="";'
        '');

    await db.rawQuery(''
        'INSERT OR REPLACE INTO  VARSTYLES(STYLEID) select  distinct STYLEID from  IMPORTDETAILS where  STYLEID!="";'
        '');
  }

  Future<int> addVARCOLOR({
    COLORID,
  }) async {
    final db = await SQLHelper.db();

    final data = {
      "COLORID": COLORID,
    };

    final id = await db.insert('VARCOLOR', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  Future<int> addVARCONFIG({
    CONFIGID,
  }) async {
    final db = await SQLHelper.db();

    final data = {
      "CONFIGID": CONFIGID,
    };

    final id = await db.insert('VARCONFIG', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  Future<int> addVARSIZE({
    SIZEID,
  }) async {
    final db = await SQLHelper.db();

    final data = {
      "SIZEID": SIZEID,
    };

    final id = await db.insert('VARSIZE', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  Future<int> addVARSTYLES({
    STYLEID,
  }) async {
    final db = await SQLHelper.db();

    final data = {
      "STYLEID": STYLEID,
    };

    final id = await db.insert('VARSTYLES', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  Future<void> deleteStockCount(String? transactionId) async {
    print("885 ...");
    // print("delete  from  IMPORTDETAILS where  AXDOCNO=$transactionId");
    // return;
    final db = await SQLHelper.db();
    try {
      await db.rawQuery(''
          'delete  from  IMPORTDETAILS where  AXDOCNO="$transactionId";'
          '');

      await db.rawQuery(''
          'delete  from  IMPORTHEADER where  AXDOCNO="$transactionId";'
          '');

      // db.delete("InboundTransSgtin",
      //     where: "isReceiveTrans = ? and transactionType =? ",
      //     whereArgs: [1, type]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  Future<void> deleteItemMaster() async {
    final db = await SQLHelper.db();
    try {
      await db.delete("ITEMMASTER");
      await db.delete("UNITMASTER");
      await db.delete("VARCOLOR");
      await db.delete("VARCONFIG");
      await db.delete("VARSIZE");
      await db.delete("VARSTYLES");
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  Future<int> addHSAdminUser() async {
    final db = await SQLHelper.db();

    final data = {
      "userId": "hsadmin",
      "password": "hsadmin",
      "username": "hsadmin",
      "userType": "admin"
    };
    final id = await db.insert('LoginTable', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  Future<int> addAdminUser() async {
    final db = await SQLHelper.db();

    final data = {
      "userId": "admin",
      "password": "@dmin",
      "username": "Administrator",
      "userType": "admin"
    };

    final id = await db.insert('LoginTable', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  Future<int> addUsers({userId, password, username, userType}) async {
    final db = await SQLHelper.db();

    final data = {
      "userId": userId.toString().toLowerCase(),
      "password": password,
      "username": username.toString().toLowerCase(),
      "userType": userType.toString().toLowerCase(),
    };

    final id = await db.insert('LoginTable', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  Future<int> updateUserDetails(
      {Id, userId, password, username, userType}) async {
    final db = await SQLHelper.db();
    final data = {
      "id": Id,
      "userId": userId.toString().toLowerCase(),
      "password": password,
      "username": username.toString().toLowerCase(),
      "userType": userType.toString().toLowerCase(),
    };

    final id = await db.update('LoginTable', data,
        where: "id = ?",
        whereArgs: [Id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  Future<int> addInboundTransSgtin(
      {String? documentNo,
      String? sscc,
      String? ventorId,
      String? gtin,
      String? batch,
      String? expiry,
      String? slno,
      String? transactionType,
      String? DEVICEID,
      BoxId,
      productStatus,
      isProductStatus,
      invDocumentNo,
      OrderAccount,
      OrderAccountName,
      FROMSTORECODE,
      TOSTORECODE,
      ItemId,
      ItemName,
      ITEMBARCODE,
      DATAAREAID,
      WAREHOUSE,
      CONFIGID,
      COLORID,
      SIZEID,
      STYLEID,
      INVENTSTATUS,
      QTY,
      UNIT,
      TRANSTYPE,
      ItemAmount,
      GTINUnit,
      GTINOrderQTY,
      GTINReceiveQTY,
      HeaderOnly,
      Description,
      STORECODE,
      CREATEDDATE}) async {
    final db = await SQLHelper.db();

    final data = {
      "AXDOCNO": documentNo,
      "sscc": sscc,
      "ventorId": ventorId,
      "gtin": gtin,
      "batch": batch,
      "expiry": expiry,
      "slno": slno,
      "transactionType": transactionType,
      "isReceiveTrans": false,
      "DEVICEID": DEVICEID,
      "boxId": BoxId,
      "productStatus": productStatus,
      "isProductStatus": isProductStatus,
      "invDocumentNo": invDocumentNo,
      "OrderAccount": OrderAccount,
      "OrderAccountName": OrderAccountName,
      "FROMSTORECODE": FROMSTORECODE,
      "TOSTORECODE": TOSTORECODE,
      "ItemId": ItemId,
      "ItemName": ItemName,
      "ITEMBARCODE": ITEMBARCODE,
      "DATAAREAID": DATAAREAID,
      "WAREHOUSE": WAREHOUSE,
      "CONFIGID": CONFIGID,
      "COLORID": COLORID,
      "SIZEID": SIZEID,
      "STYLEID": STYLEID,
      "INVENTSTATUS": INVENTSTATUS,
      "QTY": QTY,
      "UNIT": UNIT,
      "TRANSTYPE": TRANSTYPE,
      "ItemAmount": ItemAmount,
      "GTINUnit": GTINUnit,
      "GTINOrderQTY": GTINOrderQTY,
      "GTINReceiveQTY": GTINReceiveQTY,
      "HeaderOnly": HeaderOnly,
      "Description": Description,
      "STORECODE": STORECODE,
      "CREATEDDATE": CREATEDDATE
    };
    final id = await db.insert('InboundTransSgtin', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  // Future<int> addInboundTransSgtin(
  //     {String? documentNo,
  //       String? sscc,
  //       String? ventorId,
  //       String? gtin,
  //       String? batch,
  //       String? expiry,
  //       String? slno,
  //       String? transactionType,
  //       String? DEVICEID,
  //       BoxId,
  //       productStatus,
  //       isProductStatus,
  //       invDocumentNo}) async {
  //   final db = await SQLHelper.db();
  //
  //   final data = {
  //     "documentNo": documentNo,
  //     "sscc": sscc,
  //     "ventorId": ventorId,
  //     "gtin": gtin,
  //     "batch": batch,
  //     "expiry": expiry,
  //     "slno": slno,
  //     "transactionType": transactionType,
  //     "isReceiveTrans": false,
  //     "DEVICEID": DEVICEID,
  //     "boxId": BoxId,
  //     "productStatus": productStatus,
  //     "isProductStatus": isProductStatus,
  //     "invDocumentNo": invDocumentNo
  //   };
  //   final id = await db.insert('InboundTransSgtin', data,
  //       conflictAlgorithm: sql.ConflictAlgorithm.replace);
  //
  //   return id;
  // }

  // Future<int> addTransHeader({
  //
  //   dynamic bodyData,
  //   String ?transactionType,
  //   String ?DEVICEID,
  //   productStatus,
  //   isProductStatus,
  //   isSscc}) async {
  //   final db = await SQLHelper.db();
  //
  //   final data = {
  //     // "pushData": bodyData,
  //     "transactionType": transactionType,
  //     "isReceiveTrans": false,
  //     "DEVICEID": DEVICEID,
  //     "productStatus":productStatus??"",
  //     "isProductStatus":isProductStatus??false,
  //     "isSscc":isSscc??""
  //   };
  //   final id = await db.insert('InvoiceTransactions', data,
  //       conflictAlgorithm: sql.ConflictAlgorithm.replace);
  //
  //   return id;
  // }

  Future<int> addAPPGENERALDATA(
      DEVICEID,
      STORECODE,
      PONEXTDOCNO,
      GRNNEXTDOCNO,
      RONEXTDOCNO,
      RPNEXTDOCNO,
      STNEXTDOCNO,
      TONEXTDOCNO,
      TOOUTNEXTDOCNO,
      TOINNEXTDOCNO,
      MJNEXTDOCNO,
      isDeactivate) async {
    final db = await SQLHelper.db();

    print("DB Line mj : ${MJNEXTDOCNO}");

    final data = {
      "DEVICEID": DEVICEID,
      "STORECODE": STORECODE,
      "PONEXTDOCNO": PONEXTDOCNO,
      "GRNNEXTDOCNO": GRNNEXTDOCNO,
      "RONEXTDOCNO": RONEXTDOCNO,
      "RPNEXTDOCNO": RPNEXTDOCNO,
      "STNEXTDOCNO": STNEXTDOCNO,
      "TONEXTDOCNO": TONEXTDOCNO,
      "TOOUTNEXTDOCNO": TOOUTNEXTDOCNO,
      "TOINNEXTDOCNO": TOINNEXTDOCNO,
      "MJNEXTDOCNO":MJNEXTDOCNO,
      "isDeactivate": isDeactivate
    };
    // return 1;
    final id = await db.insert('APPGENERALDATA', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  Future<int> updateAPPGENERALDATA(
      Id,
      DEVICEID,
      STORECODE,
      PONEXTDOCNO,
      GRNNEXTDOCNO,
      RONEXTDOCNO,
      RPNEXTDOCNO,
      STNEXTDOCNO,
      TONEXTDOCNO,
      TOOUTNEXTDOCNO,
      TOINNEXTDOCNO,
      MJNEXTDOCNO,
      isDeactivate) async {
    final db = await SQLHelper.db();
    final data = {
      "id": Id,
      "DEVICEID": DEVICEID,
      "STORECODE": STORECODE,
      "PONEXTDOCNO": PONEXTDOCNO,
      "GRNNEXTDOCNO": GRNNEXTDOCNO,
      "RONEXTDOCNO": RONEXTDOCNO,
      "RPNEXTDOCNO": RPNEXTDOCNO,
      "STNEXTDOCNO": STNEXTDOCNO,
      "TONEXTDOCNO": TONEXTDOCNO,
      "TOOUTNEXTDOCNO": TOOUTNEXTDOCNO,
      "TOINNEXTDOCNO": TOINNEXTDOCNO,
      "MJNEXTDOCNO": MJNEXTDOCNO,
      "isDeactivate": isDeactivate
    };

    final id = await db.update('APPGENERALDATA', data,
        where: "id = ?",
        whereArgs: [Id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  //update Sgtin transactions receive product status
  Future<dynamic> updateStatusStockCount(
      int? status, String? DOCNO, String? transtype, String? AXDOCNO) async {
    final db = await SQLHelper.db();
    final data = {'STATUS': status};
    print("db 1223");
    print(data);
    // importheader
    // return 1;
    // await db.query("table");

    await db
        .update('transdetails', data, where: "DOCNO = ?", whereArgs: [DOCNO]);
    await db.update('importheader', data,
        where: "TRANSTYPE = ? AND AXDOCNO =? ",
        whereArgs: [transtype, AXDOCNO]);

    var id = await db.update('TRANSHEADER', data,
        where: "DOCNO = ?",
        whereArgs: [DOCNO],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
    // await db.update('TRANSHEADER', data,
    //     where: "DOCNO = ?",
    //     whereArgs: [DOCNO]
    //     // where:
    //     // "STATUS = ? and isProductStatus =? and transactionType =?  ",
    //     // whereArgs: [0, 1, type],
    //     );

    // print(id);
  }

  Future<int> updateTRANSDETAILSWithQty(int Id, qty) async {
    final db = await SQLHelper.db();
    // "DEVICEID": DEVICEID,
    // "STORECODE": STORECODE,
    // "PONEXTDOCNO": PONEXTDOCNO,
    // "GRNNEXTDOCNO": GRNNEXTDOCNO,
    // "RONEXTDOCNO": RONEXTDOCNO,
    // "RPNEXTDOCNO": RPNEXTDOCNO,

    var lastId;
    var nextId;

    List<Map<String, dynamic>>? dt;
    try {
      // dt = await db.rawQuery('SELECT MAX(LISTID) FROM TRANSDETAILS');

      dt = await db.rawQuery("SELECT MAX(LISTID) FROM TRANSDETAILS");

      print("1420");
      print(dt[0]['MAX(LISTID)']);
      print("1422");
      // int maxid = (cursor.moveToFirst() ? cursor.getInt(0) : 0);

    } catch (e) {
      lastId = 1;
    }

    print("data...1351");
    // print(dt[0]['LISTID']);

    // return "";
    if (dt![0]['MAX(LISTID)'] == null) {
      lastId = 1;
    } else {
      lastId = dt[0]['MAX(LISTID)'] + 1;
    }

    nextId = lastId;

    final data = {"QTY": qty, "LISTID": nextId};
    final id = await db.update('TRANSDETAILS', data,
        where: "id = ?",
        whereArgs: [Id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }


  //add transaction headers
  addTRANSDETAILS(
      {HRecId,
      AXDOCNO,
      STATUS,
      DOCNO,
      ITEMID,
      ITEMNAME,
      TRANSTYPE,
      DEVICEID,
      QTY,
      UOM,
      BARCODE,
      CREATEDDATE,
      INVENTSTATUS,
      SIZEID,
      COLORID,
      CONFIGID,
      STYLESID,
      STORECODE,
      LOCATION,
      BATCHNO,
      EXPDATE,
      PRODDATE,
      BatchEnabled,
      BatchedItem}) async {

    print("adding db");
    final db = await SQLHelper.db();

    var lastId;
    var nextId;

    List<Map<String, dynamic>>? dt;
    try {
      // dt = await db.rawQuery('SELECT MAX(LISTID) FROM TRANSDETAILS');

      dt = await db.rawQuery("SELECT MAX(LISTID) FROM TRANSDETAILS");

      print("1420");
      print(dt[0]['MAX(LISTID)']);
      print("1422 db");
      // int maxid = (cursor.moveToFirst() ? cursor.getInt(0) : 0);

    } catch (e) {
      lastId = 1;
    }

    print("data...1351");
    // print(dt[0]['LISTID']);

    // return "";
    if (dt![0]['MAX(LISTID)'] == null) {
      lastId = 1;
    } else {
      lastId = dt[0]['MAX(LISTID)'] + 1;
    }

    nextId = lastId;

    // ? 1
    //     : widget.type == "GRN"
    // ? 4


    if (TRANSTYPE == 4 || TRANSTYPE == 1) {

      List<dynamic> exist =[];

      exist = await getFindItemExistOrnotTRANSDETAILS_GRN_STOCKCOUNT(
          DOCNO: DOCNO,
          ITEMID: ITEMID,
          ITEMNAME: ITEMNAME,
          BARCODE: BARCODE,
          TRANSTYPE: TRANSTYPE,
          UOM: UOM,
          BATCHNO: BATCHNO);

      print("In db  exist  Line 1518 : ${TRANSTYPE}");

      if( exist.isNotEmpty){
        await updateTRANSDETAILSWithQty(
            exist[0]['id'], int.parse(exist[0]['QTY']) + int.parse(QTY.toString()));
        return;
      }

    }




    print("Exist");

    final data = {
      "HRecId": HRecId,
      "LISTID": nextId,
      "AXDOCNO": AXDOCNO,
      "DOCNO": DOCNO,
      "STATUS": STATUS,
      "ITEMID": ITEMID,
      "ITEMNAME": ITEMNAME,
      "TRANSTYPE": TRANSTYPE,
      "DEVICEID": DEVICEID,
      "QTY": QTY,
      "UOM": UOM,
      "BARCODE": BARCODE,
      "CREATEDDATE": CREATEDDATE,
      "INVENTSTATUS": INVENTSTATUS,
      "SIZEID": SIZEID,
      "COLORID": COLORID,
      "CONFIGID": CONFIGID,
      "STYLESID": STYLESID,
      "STORECODE": STORECODE,
      "LOCATION": LOCATION,
      "BATCHNO": BATCHNO,
      "EXPDATE": EXPDATE =="null" || EXPDATE ==null ? "" :EXPDATE,
      "PRODDATE": PRODDATE =="null" || PRODDATE == null ? "" :PRODDATE,
      "BatchEnabled": BatchEnabled,
      "BatchedItem": BatchedItem,
    };

    print("Line db 1639");

    print(data);


    // return;
    // try {
    //   final data = await db.rawQuery('SELECT * FROM TRANSHEADER');
    //   print("data...401");
    //   print(data);
    //   // if (data != [] || data != null) {
    //   //
    //   //   // };
    //   //   return data;
    //   // } else {
    //   //   return "";
    //   // }
    // } catch (e) {
    //   print(e.toString());
    // }

    final id = await db.insert('TRANSDETAILS', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  //add transaction headers
  Future<int> addTRANSHEADER(
      {
        DOCNO,
      AXDOCNO,
      STORECODE,
      TOSTORECODE,
      TRANSTYPE,
      STATUS,
      USERNAME,
      DESCRIPTION,
      CREATEDDATE,
      DATAAREAID,
      DEVICEID,
      TYPEDESCR,
        JournalName,
      VRLOCATION}) async
  {

    final db = await SQLHelper.db();

    final data = {
      "DOCNO": DOCNO,
      "AXDOCNO": AXDOCNO,
      "STORECODE": STORECODE,
      "TOSTORECODE": TOSTORECODE,
      "TRANSTYPE": TRANSTYPE,
      "STATUS": STATUS,
      "USERNAME": USERNAME,
      "DESCRIPTION": DESCRIPTION,
      "CREATEDDATE": CREATEDDATE,
      "DATAAREAID": DATAAREAID,
      "DEVICEID": DEVICEID,
      "TYPEDESCR": TYPEDESCR,
      "VRLOCATION": VRLOCATION,
      "JournalName":JournalName

    };

    final id = await db.insert('TRANSHEADER', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }



  Future<int> updateAPPGENERALDATAMJNEXTDOCNO(MJNEXTDOCNO) async {
    final db = await SQLHelper.db();
    // "DEVICEID": DEVICEID,
    // "STORECODE": STORECODE,
    // "PONEXTDOCNO": PONEXTDOCNO,
    // "GRNNEXTDOCNO": GRNNEXTDOCNO,
    // "RONEXTDOCNO": RONEXTDOCNO,
    // "RPNEXTDOCNO": RPNEXTDOCNO,
    final data = {
      "MJNEXTDOCNO": MJNEXTDOCNO,
    };

    final id = await db.update('APPGENERALDATA', data,
        // where: "id = ?",
        // whereArgs: [Id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  Future<int> updateAPPGENERALDATAGRNNEXTDOCNO(GRNNEXTDOCNO) async {
    final db = await SQLHelper.db();
    // "DEVICEID": DEVICEID,
    // "STORECODE": STORECODE,
    // "PONEXTDOCNO": PONEXTDOCNO,
    // "GRNNEXTDOCNO": GRNNEXTDOCNO,
    // "RONEXTDOCNO": RONEXTDOCNO,
    // "RPNEXTDOCNO": RPNEXTDOCNO,
    final data = {
      "GRNNEXTDOCNO": GRNNEXTDOCNO,
    };

    final id = await db.update('APPGENERALDATA', data,
        // where: "id = ?",
        // whereArgs: [Id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  Future<int> updateAPPGENERALDATARONEXTDOCNO(RONEXTDOCNO) async {
    final db = await SQLHelper.db();

    final data = {
      "RONEXTDOCNO": RONEXTDOCNO,
    };

    final id = await db.update('APPGENERALDATA', data,
        // where: "id = ?",
        // whereArgs: [Id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  Future<int> updateAPPGENERALDATATOINNEXTDOCNO(TOINNEXTDOCNO) async {
    final db = await SQLHelper.db();

    final data = {
      "TOINNEXTDOCNO": TOINNEXTDOCNO,
    };

    final id = await db.update('APPGENERALDATA', data,
        // where: "id = ?",
        // whereArgs: [Id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  Future<int> updateAPPGENERALDATATOOUTNEXTDOCNO(TOOUTNEXTDOCNO) async {
    final db = await SQLHelper.db();

    final data = {
      "TOOUTNEXTDOCNO": TOOUTNEXTDOCNO,
    };

    final id = await db.update('APPGENERALDATA', data,
        // where: "id = ?",
        // whereArgs: [Id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  Future<int> updateAPPGENERALDATATONEXTDOCNO(TONEXTDOCNO) async {
    final db = await SQLHelper.db();

    final data = {
      "TONEXTDOCNO": TONEXTDOCNO,
    };

    final id = await db.update('APPGENERALDATA', data,
        // where: "id = ?",
        // whereArgs: [Id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  Future<int> updateAPPGENERALDATARPNEXTDOCNO(RPNEXTDOCNO) async {
    final db = await SQLHelper.db();

    final data = {
      "RPNEXTDOCNO": RPNEXTDOCNO,
    };

    final id = await db.update('APPGENERALDATA', data,
        // where: "id = ?",
        // whereArgs: [Id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  Future<int> updateAPPGENERALDATAPONEXTDOCNO(PONEXTDOCNO) async {
    final db = await SQLHelper.db();

    final data = {
      "PONEXTDOCNO": PONEXTDOCNO,
    };

    final id = await db.update('APPGENERALDATA', data,
        // where: "id = ?",
        // whereArgs: [Id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  Future<int> updateAPPGENERALDATASTNEXTDOCNO(STNEXTDOCNO) async {
    final db = await SQLHelper.db();
    // "DEVICEID": DEVICEID,
    // "STORECODE": STORECODE,
    // "PONEXTDOCNO": PONEXTDOCNO,
    // "GRNNEXTDOCNO": GRNNEXTDOCNO,
    // "RONEXTDOCNO": RONEXTDOCNO,
    // "RPNEXTDOCNO": RPNEXTDOCNO,
    final data = {
      "STNEXTDOCNO": STNEXTDOCNO,
    };

    final id = await db.update('APPGENERALDATA', data,
        // where: "id = ?",
        // whereArgs: [Id],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  // Future<int> addInboundTransPurchaseTatMeenDetails(
  //     String iddt,
  //     String AXDOCNO,
  //     String OrderAccount,
  //     String OrderAccountName,
  //     String FROMSTORECODE,
  //     String TOSTORECODE,
  //     String ItemId,
  //     String ItemName,
  //     String ITEMBARCODE,
  //     String DATAAREAID,
  //     String WAREHOUSE,
  //     String CONFIGID,
  //     String COLORID,
  //     String SIZEID,
  //     String STYLEID,
  //     String INVENTSTATUS,
  //     double QTY,
  //     String UNIT,
  //     int TRANSTYPE,
  //     double ItemAmount,
  //     String GTIN,
  //     String GTINUnit,
  //     double GTINOrderQTY,
  //     double GTINReceiveQTY,
  //     int HeaderOnly,
  //     String Description,
  //     STORECODE,
  //     DEVICEID,
  //     CREATEDDATE,
  //     transactionType,
  //     invDocumentNo) async {
  //   final db = await SQLHelper.db();
  //
  //   final data = {
  //     "id": iddt,
  //     "AXDOCNO": AXDOCNO,
  //     "OrderAccount": OrderAccount,
  //     "OrderAccountName": OrderAccountName,
  //     "invDocumentNo": invDocumentNo,
  //     "FROMSTORECODE": FROMSTORECODE,
  //     "TOSTORECODE": TOSTORECODE,
  //     "ItemId": ItemId,
  //     "ItemName": ItemName,
  //     "ITEMBARCODE": ITEMBARCODE,
  //     "DATAAREAID": DATAAREAID,
  //     "WAREHOUSE": WAREHOUSE,
  //     "CONFIGID": CONFIGID,
  //     "COLORID": COLORID,
  //     "SIZEID": SIZEID,
  //     "STYLEID": STYLEID,
  //     "INVENTSTATUS": INVENTSTATUS,
  //     "QTY": QTY,
  //     "UNIT": UNIT,
  //     "TRANSTYPE": TRANSTYPE,
  //     "ItemAmount": ItemAmount,
  //     "GTIN": GTIN,
  //     "GTINUnit": GTINUnit,
  //     "GTINOrderQTY": GTINOrderQTY,
  //     "GTINReceiveQTY": GTINReceiveQTY,
  //     "HeaderOnly": HeaderOnly,
  //     "Description": Description,
  //     "GTINReceiveQTY": GTINReceiveQTY,
  //     "HeaderOnly": HeaderOnly,
  //     "Description": Description,
  //     "STORECODE": STORECODE,
  //     "DEVICEID": DEVICEID,
  //     "CREATEDDATE": CREATEDDATE,
  //     "transactionType": transactionType,
  //     "isReceiveTrans": false
  //   };

  //   print(data);
  //   print("...db 239");
  //   // return int.parse(ItemId);
  //   // d(tableName, null, contentValues,SQLiteDatabase.CONFLICT_REPLACE)
  //   final id = await db.insert(
  //     'InboundTransPurchaseApiData',
  //     data,
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  //   return id;
  // }

  getLastColumnAPPGENERALDATA() async {
    final db = await SQLHelper.db();

    try {

      final data = await db.rawQuery('SELECT * FROM APPGENERALDATA');
      print("data...401");
      print(data);
      if (data != [] || data != null) {
        final lastId = data.last['id'];
        final typeDocument = data.last['transactionType'];
        final device = data.last['DEVICEID'];
        print("last...");
        print(lastId);

        var dt = {
          "id": data.last['id'],
          "DEVICEID": data.last['DEVICEID'],
          "STORECODE": data.last['STORECODE'],
          "PONEXTDOCNO": data.last['PONEXTDOCNO'],
          "GRNNEXTDOCNO": data.last['GRNNEXTDOCNO'],
          "RONEXTDOCNO": data.last['RONEXTDOCNO'],
          "RPNEXTDOCNO": data.last['RPNEXTDOCNO'],
          "STNEXTDOCNO": data.last['STNEXTDOCNO'],
          "TONEXTDOCNO": data.last['TONEXTDOCNO'],
          "TOOUTNEXTDOCNO": data.last['TOOUTNEXTDOCNO'],
          "TOINNEXTDOCNO": data.last['TOINNEXTDOCNO'],
          "MJNEXTDOCNO": data.last['MJNEXTDOCNO'],
          "isDeactivate": data.last['isDeactivate']
        };
        return dt;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  deleteTRANSDETAILS(int id) async {
    final db = await SQLHelper.db();

    try {
      await db.rawQuery('delete  FROM TRANSDETAILS WHERE id=$id');
    } catch (e) {
      print(e.toString());
    }
  }

  deleteTRANSHEADERHistory(String? DOCNO) async {
    final db = await SQLHelper.db();
    try {
      // widget.type == 'ST' ? "1" : widget.type == 'PO' ? "3" : ""
      await db.delete("TRANSDETAILS",
          where: "DOCNO = ? AND  STATUS= ? ", whereArgs: [DOCNO, 3]);

      await db.delete("TRANSHEADER",
          where: "DOCNO = ? AND  STATUS= ? ", whereArgs: [DOCNO, 3]);
    } catch (e) {
      print(e.toString());
    }
  }

  deleteTRANSHEADER(String? DOCNO, String? transType) async {
    final db = await SQLHelper.db();
    try {
      // widget.type == 'ST' ? "1" : widget.type == 'PO' ? "3" : ""
      await db.delete("TRANSDETAILS",
          where: "DOCNO = ? AND  TRANSTYPE= ? ", whereArgs: [DOCNO, transType]);
      await db.delete("TRANSHEADER",
          where: "DOCNO = ? AND  TRANSTYPE= ? ", whereArgs: [DOCNO, transType]);
    } catch (e) {
      print(e.toString());
    }
  }

  getTRANSDETAILS(String? transType) async {
    final db = await SQLHelper.db();

    try {
      final data = await db.rawQuery(
          'SELECT * FROM TRANSDETAILS where STATUS <3 AND   TRANSTYPE="$transType" ORDER BY LISTID DESC LIMIT 15');
      print("data...401");

      print(data);
      if (data != [] || data != null) {
        // final lastId = data.last['id'];
        // final typeDocument = data.last['transactionType'];
        // final device = data.last['DEVICEID'];
        // print("last...");
        // print(lastId);
        // var dt = {
        //   "id": data.last['id'],
        //   "DEVICEID": data.last['DEVICEID'],
        //   "STORECODE": data.last['STORECODE'],
        //   "PONEXTDOCNO": data.last['PONEXTDOCNO'],
        //   "GRNNEXTDOCNO": data.last['GRNNEXTDOCNO'],
        //   "RONEXTDOCNO": data.last['RONEXTDOCNO'],
        //   "RPNEXTDOCNO": data.last['RPNEXTDOCNO'],
        //   "STNEXTDOCNO": data.last['STNEXTDOCNO'],
        //   "TONEXTDOCNO": data.last['TONEXTDOCNO'],
        //   "TOOUTNEXTDOCNO": data.last['TOOUTNEXTDOCNO'],
        //   "TOINNEXTDOCNO": data.last['TOINNEXTDOCNO'],
        //   "isDeactivate": data.last['isDeactivate']
        // };
        return data;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  getTRANSDETAILSINHeader(String? transType) async {
    final db = await SQLHelper.db();

    try {
      final data = await db.rawQuery(
          'SELECT * FROM TRANSDETAILS where STATUS <3 AND   TRANSTYPE="$transType"');
      print("data...401");

      print(data);
      if (data != [] || data != null) {
        // final lastId = data.last['id'];
        // final typeDocument = data.last['transactionType'];
        // final device = data.last['DEVICEID'];
        // print("last...");
        // print(lastId);
        // var dt = {
        //   "id": data.last['id'],
        //   "DEVICEID": data.last['DEVICEID'],
        //   "STORECODE": data.last['STORECODE'],
        //   "PONEXTDOCNO": data.last['PONEXTDOCNO'],
        //   "GRNNEXTDOCNO": data.last['GRNNEXTDOCNO'],
        //   "RONEXTDOCNO": data.last['RONEXTDOCNO'],
        //   "RPNEXTDOCNO": data.last['RPNEXTDOCNO'],
        //   "STNEXTDOCNO": data.last['STNEXTDOCNO'],
        //   "TONEXTDOCNO": data.last['TONEXTDOCNO'],
        //   "TOOUTNEXTDOCNO": data.last['TOOUTNEXTDOCNO'],
        //   "TOINNEXTDOCNO": data.last['TOINNEXTDOCNO'],
        //   "isDeactivate": data.last['isDeactivate']
        // };
        return data;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  getTRANSDETAILSHistory(String? transType, String? DOCNO) async {
    final db = await SQLHelper.db();

    try {
      final data = await db.rawQuery(
          'SELECT * FROM TRANSDETAILS where STATUS >2 AND TRANSTYPE="$transType" AND DOCNO ="$DOCNO" ORDER BY LISTID DESC');
      print("data...401");
      print(data);
      if (data != [] || data != null) {
        return data;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  getTRANSHEADERHistory() async {
    final db = await SQLHelper.db();
    try {
      print("data...trans header");
      final data =
          await db.rawQuery('SELECT * FROM TRANSHEADER where STATUS >2;');

      print(data);
      if (data != [] || data != null) {
        return data;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  getTRANSHEADER(String? transType) async {
    final db = await SQLHelper.db();
    try {
      print("data...trans header");
      final data = await db.rawQuery(
          'SELECT * FROM TRANSHEADER where STATUS <3 AND TRANSTYPE="$transType";');

      print(data);
      if (data != [] || data != null) {
        return data;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  getTRANSHEADERSendRepost(String? transType) async {
    final db = await SQLHelper.db();
    try {
      print("data...trans header");
      final data = await db.rawQuery(
          'SELECT * FROM TRANSHEADER where STATUS <4 AND TRANSTYPE="$transType";');

      print(data);
      if (data != [] || data != null) {
        return data;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  getLastColumnIdSscc() async {
    final db = await SQLHelper.db();

    try {
      final data = await db
          .rawQuery('SELECT * FROM InboundTransSscc where isReceiveTrans=1');
      print("data...401");
      print(data);
      if (data != [] || data != null) {
        final lastId = data.last['id'];
        final typeDocument = data.last['transactionType'];
        final device = data.last['DEVICEID'];
        print("last...");
        print(lastId);
        var dt = {
          "id": lastId.toString(),
          "transactionType": typeDocument.toString(),
          "device": device.toString()
        };
        return dt;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  // get inbound transaction purchase
  // Future<dynamic> getInboundTransAPI(String type) async {
  //   final db = await SQLHelper.db();
  //   print("db 66");
  //   print(await db.query('InboundTransPurchaseApiData'));
  //   return db.query(
  //     'InboundTransPurchaseApiData',
  //     where: "isReceiveTrans = ? and transactionType =? ",
  //     whereArgs: [0, type],
  //   );
  // }

  // //update api pull data transactions receive
  // Future<int?> updateInboundTransAPIPullReceive(String type) async {
  //   final db = await SQLHelper.db();
  //   final data = {'isReceiveTrans': true};
  //   final id = await db.update('InboundTransPurchaseApiData', data,
  //       where: "isReceiveTrans = ? and transactionType =? ",
  //       whereArgs: [0, type],
  //       conflictAlgorithm: sql.ConflictAlgorithm.replace);
  //   print(id);
  // }

  //update Sgtin transactions receive product status
  Future<int?> updateInboundTransSgtinReceiveProductStatus(String? type) async {
    final db = await SQLHelper.db();
    final data = {'isReceiveTrans': true, "isProductStatus": false};
    final id = await db.update('InboundTransSgtin', data,
        where:
            "isReceiveTrans = ? and isProductStatus =? and transactionType =?  ",
        whereArgs: [0, 1, type],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    print(id);
  }

  //update Sgtin transactions receive
  Future<int?> updateInboundTransSgtinReceive(String type) async {
    final db = await SQLHelper.db();
    final data = {'isReceiveTrans': true};
    final id = await db.update('InboundTransSgtin', data,
        where: "isReceiveTrans = ? and transactionType =? ",
        whereArgs: [0, type],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    print(id);
  }

  //update Sscc transactions receive
  Future<int?> updateAPPGENERALDATAActivate({bool? isDeactivate}) async {
    final db = await SQLHelper.db();
    // final data = {'isDeactivate': isDeactivate};
    // final id = await db.update('APPGENERALDATA', data,
    //     where: "isDeactivate = ?",
    //     whereArgs: [true],
    //     conflictAlgorithm: sql.ConflictAlgorithm.replace);

    try {
      await db.rawQuery(''
          'delete  from  APPGENERALDATA where  isDeactivate=1;'
          '');

      // db.delete("InboundTransSgtin",
      //     where: "isReceiveTrans = ? and transactionType =? ",
      //     whereArgs: [1, type]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
    // print(id);
  }

// get inbound transaction sgtin
  Future<dynamic> getInboundTransSgtin(String type) async {
    final db = await SQLHelper.db();

    String whereString = 'isReceiveTrans = false?';
    // where: "col1 LIKE ? and col2 = ? and col3 = ?",
    // whereArgs: ['$likeVal%', strVal, intVal],
    // orderBy: 'id',

    print("db 355");
    print(await db.query('InboundTransSgtin',
        where: "isReceiveTrans = ? and transactionType =? ",
        whereArgs: [0, "${type.toString()}"]));
    return db.query('InboundTransSgtin',
        where: "isReceiveTrans = ? and transactionType =? ",
        whereArgs: [0, "${type.toString()}"]);
  }

  // get inbound transaction sscc
  Future<dynamic> getInboundTransSscc(String type) async {
    final db = await SQLHelper.db();
    print("db 66");

    print(await db.query('InboundTransSscc'));
    return db.query('InboundTransSscc',
        where: "isReceiveTrans = ? and transactionType =? ",
        whereArgs: [0, type]);
  }

  // get inbound transaction sgtin
  Future<dynamic> getInboundTransSgtinProductStatus() async {
    final db = await SQLHelper.db();

    String whereString = 'isReceiveTrans = false?';
    // where: "col1 LIKE ? and col2 = ? and col3 = ?",
    // whereArgs: ['$likeVal%', strVal, intVal],
    // orderBy: 'id',

    print("db 355");

    print(await db.query('InboundTransSgtin',
        where: "isReceiveTrans = ? and isProductStatus=?", whereArgs: [0, 1]));
    return db.query('InboundTransSgtin',
        where: "isReceiveTrans = ? and isProductStatus=?", whereArgs: [0, 1]);
  }

  // get inbound transaction purchase
  Future<dynamic> getInboundTransAPIProductStatus(String type) async {
    final db = await SQLHelper.db();
    print("db 66");
    print(await db.query('InboundTransPurchaseApiData'));
    return db.query(
      'InboundTransPurchaseApiData',
      where: "isReceiveTrans = ? and transactionType =? ",
      whereArgs: [0, type],
    );
  }

  // get inbound transaction sgtin data
  Future<dynamic> getInboundTransSgtinHistorybyData(
      String invDocumentNo) async {
    final db = await SQLHelper.db();

    print(await db.query('InboundTransSgtin'));
    List<dynamic> maps = await db.rawQuery(''
        'select id as id,AXDOCNO as DOCNO ,gtin as GTIN ,batch as BATCHNO ,expiry EXPDATE,sscc as SSCC,slno as SERIAL,TRANSTYPE,ItemId as ItemId,TOSTORECODE,GTINUnit as  GTINUNIT,GTINReceiveQTY as RECIEVEDQTY,AXDOCNO as TRANSID,STORECODE,DEVICEID,CREATEDDATE,transactionType as TransType,invDocumentNo from  InboundTransSgtin  where  isReceiveTrans=1 and invDocumentNo="$invDocumentNo" and gtin!="";'
        '');
    print(maps);
    print("..sgtin");
    return maps;

    return db.query('InboundTransSgtin',
        where: "isReceiveTrans = ?", whereArgs: [1]);
  }

  // get inbound transaction sgtin
  Future<dynamic> getInboundTransSgtinHistory() async {
    final db = await SQLHelper.db();

    print(await db.query('InboundTransSgtin'));
    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select id as id,AXDOCNO as DOCNO ,gtin as GTIN ,batch as BATCHNO ,expiry EXPDATE,sscc as SSCC,slno as SERIAL,TRANSTYPE,ItemId as ItemId,TOSTORECODE,GTINUnit as  GTINUNIT,GTINReceiveQTY as RECIEVEDQTY,AXDOCNO as TRANSID,STORECODE,DEVICEID,CREATEDDATE,transactionType as TransType,invDocumentNo from  InboundTransSgtin  where  isReceiveTrans=1;'
        '');
    print(maps);
    print("..sgtin");
    return maps;

    return db.query('InboundTransSgtin',
        where: "isReceiveTrans = ?", whereArgs: [1]);
  }

  // get inbound transaction sscc
  Future<dynamic> getInboundTransSsccHistory() async {
    final db = await SQLHelper.db();
    // print(await db.query('InboundTransSscc'));

    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select c.documentNo as DOCNO ,c.sscc as SSCC,c.invDocumentNo from  InboundTransSscc c where  isReceiveTrans=1;'
        '');
    print(maps);
    print("...sscc");
    return maps;
    return db
        .query('InboundTransSscc', where: "isReceiveTrans = ?", whereArgs: [1]);
  }

  Future<bool> userExists(String username) async {
    final db = await SQLHelper.db();
    var result = await db.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM userdetails WHERE username="$username")',
    );
    int? exists = await Sqflite.firstIntValue(result);
    return exists == 1;
  }

  static Future<List<Map<String, dynamic>>> getUserDB() async {
    final db = await SQLHelper.db();
    return db.query('userdetails', orderBy: "id");
  }

  Future<dynamic> getUser(String username) async {
    final db = await SQLHelper.db();
    return db.query('userdetails',
        where: "username = ?", whereArgs: [username], limit: 1);
  }

  Future<int?> updateUser(String? user, String? pass) async {
    final db = await SQLHelper.db();
    final data = {'username': user, 'password': pass};

    final id = await db.update('userdetails', data,
        where: "username = ? ",
        whereArgs: [user],
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    print(id);
  }

  Future<void> deleteUser(String username) async {
    final db = await SQLHelper.db();
    try {
      await db
          .delete("userdetails", where: "username = ? ", whereArgs: [username]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  addMoreToCheckDatasLines({String? AXDOCNO, int? limit}) async {
    final db = await SQLHelper.db();
    final List<Map<String, dynamic>> maps = await db.rawQuery(''
        'select * FROM IMPORTDETAILS Where   AXDOCNO ="$AXDOCNO" LIMIT $limit;'
        '');
    print(maps);
    return maps;
  }
}
