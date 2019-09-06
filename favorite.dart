import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class favorite{

  static Database _db;

  Future<Database> get DB async {
    if(_db==null) {
      _db = await initDataBase();
      return _db;
    }else return initDataBase();
  }
  Future<Database>initDataBase() async{
    Directory docDir=await getApplicationDocumentsDirectory();
    String path=join(docDir.path,"myFav.db");
    var mydb=await openDatabase(path,version: 2,onCreate:(Database db, int version) async {
    await db.execute( 'CREATE TABLE Movie (id INTEGER PRIMARY KEY, title TEXT, poster_path TEXT,overview TEXT)');
    });
    return mydb;
  }
  Future<Database>addRow(Map c) async {
    var dbClient=await this.DB;
    dbClient.insert("Movie", {"id":c["id"],"title":c["title"],"poster_path":c["poster_path"],"overview":c["overview"]});
  }
  Future<List> retrieveData() async{
    var dbClient=await this.DB;
    return await dbClient.rawQuery("select * from Movie");
  }

  Future<int>deletRow(Map obj) async {
    var dbClient=await this.DB;
    dbClient.rawDelete("DELETE FROM Movie WHERE id=${obj["id"]}");
  }
}
