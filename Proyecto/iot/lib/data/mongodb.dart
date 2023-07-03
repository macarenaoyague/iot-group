import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:iot/constant.dart';
import 'package:iot/data/classes.dart';
import 'package:iot/ui/components/show_alert.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDB {
  String mongoURL = "mongodb+srv://$username:$password@cluster0.ey2xhcg.mongodb.net/$database?retryWrites=true&w=majority";
  Db? db;

  Future<void> connect(BuildContext context) async {
    try {
      db = await Db.create(mongoURL);
      await db!.open();
      var collectionNames = await db!.getCollectionNames();
      print(jsonEncode(collectionNames));

      var collection = db!.collection("location");
      inspect(collection);
      var data = await collection.find().toList();
      inspect(data);

      //await deleteCollection(context, "location");
      //await createCollection(context, "location");
      /*
    db!.collection("gases").insert({
        "id": "ime1",
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "gases": {
          "co": 1.0,
          "co2": 2.0,
          "alcohol": 3.0,
          "lpg": 4.0,
          "propane": 5.0,
        },
      });
      */
    } catch (e) {
      showAlertAndExit(
        context,
        "Error de conexión",
        "No se pudo establecer la conexión a la base de datos\n\nError: $e",
      );
    }
  }

  void disconnect() {
    db?.close();
    db = null;
  }

  Future<void> createCollection(BuildContext context, String collectionName) async {
    if (db != null) {
      await db!.createCollection(collectionName);
    } else {
      showAlert(context, "Error", "No se pudo crear la colección $collectionName\n\nError: db is null");
    }
  }

  Future<void> deleteCollection(BuildContext context, String collectionName) async {
    if (db != null) {
      await db!.dropCollection(collectionName);
    } else {
      showAlert(context, "Error", "No se pudo eliminar la colección $collectionName\n\nError: db is null");
    }
  }

  Future<void> insertDocuments(BuildContext context, String collectionName, List<Map<String, dynamic>> documents) async {
    print("Insert documents");
    if (db != null) {
      print("Sending ${documents.length} documents to $collectionName}");
      await db!.collection(collectionName).insertMany(documents);
    } else {
      showAlert(context, "Error", "No se pudo insertar los documentos $documents en la colección $collectionName\n\nError: db is null");
    }
  }

  Future<bool> checkID(String id) {
    return db!.collection("ids").find({"id": id}).toList().then((value) => value.isNotEmpty);
  }

  Future<List<Location>> getLastNLocations(String id, int n) async {
    var locationCollection = db!.collection("location");
    var gasesCollection = db!.collection("gases");
    var locationItems = await locationCollection
        .find(where.eq("id", id).sortBy("createdAt", descending: true).limit(n))
        .toList()
        .then((list) => list.reversed.toList());
    inspect(locationItems);
    List<Location> locationList = [];
    int idx = 1;
    for (var locationItem in locationItems) {
      Location location = Location.fromMap(locationItem, idx++);
      //location.createdAt -> DateTime
      var locationTime = location.createdAt;
      var from = locationTime.subtract(const Duration(seconds: 3));
      var to = locationTime.add(const Duration(seconds: 3));
      var gasesItems = await gasesCollection.find(where.eq("id", id).and(where.gte("createdAt", from).and(where.lte("createdAt", to)))).toList();
      for (var gasItem in gasesItems) {
        location.addGas(Gas.fromMap(gasItem));
      }
      locationList.add(location);
    }

    return locationList;
  }

  Future<List<Gas>> getGases(String id, DateTime from, DateTime to) async {
    var gasesCollection = db!.collection("gases");
    var gasesItems = await gasesCollection.find(where.eq("id", id).and(where.gte("createdAt", from).and(where.lte("createdAt", to)))).toList();
    inspect(gasesItems);
    List<Gas> gasesList = [];
    for (var gasItem in gasesItems) {
      gasesList.add(Gas.fromMap(gasItem));
    }
    return gasesList;
  }
}
