import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {
  //declarando a classe
  //criando o objeto da classe
  //possibilita ter apenas um objeto
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal(); //construtor

  //declarando o banco de dados, somente a clase ContactHelper pode acessar ou alterar
  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  // Future<Database> initDb() async {
  //   final databasesPath = await getDatabasesPath(); //pegando local do banco
  //   final path = join(databasesPath,
  //       "contactsnew.db"); //pegando o arquivo onde está salvo o db e juntando com o nome e retornando tudo isso.

  //   return await openDatabase(path, version: 1,
  //       onCreate: (Database db, int newerVersion) async {
  //     await db.execute(
  //         "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
  //         "$phoneColumn TEXT, $imgColumn TEXT)");
  //   });
  // }

      Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contactsnew.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
            "$phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }
  
  // Future<Contact> saveContact(Contact contact) async {
  //   Database dbContact = await db; //obtendo o banco de
  //   //independente do ID ele vai salvar o contato
  //   contact.id = await dbContact.insert(contactTable, contact.toMap());
  //   return contact;
  // }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db; //obtendo o banco de dados
    List<Map> maps = await dbContact.query(contactTable,
        columns: [
          idColumn,
          nameColumn,
          emailColumn,
          emailColumn,
          phoneColumn,
          imgColumn
        ],
        //obtendo a informação onde a idColum é igual o id
        where: "$idColumn = ?",
        whereArgs: [id]);
    //verificando s ele retornou alguma coisa
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db; //obtendo o banco de dados
    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db; //obtendo o banco de dados
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db; //obtendo o banco de dados
    //pegando os contatos em um mapa
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    // transformando os mapas em uma lista, lembrando que é necessário espeficicar o tipo de lista
    List<Contact> listContact = List();
    //para cada mapa na lista de mapas transformamos em um contato e adicionamos na lista de contatos
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact(); //construtor vazio

//construtor para salvar os arquivos em um formato e depois converter para reutilizar
// transformando um contato em um mapa
  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }
//transformando um mapa em um contato
  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
