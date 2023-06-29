import 'dart:convert';
import 'dart:developer';
import 'dart:math';

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
      var convertedData = data.map((doc) {
        var updatedTimestamp = doc['timestamp'].toInt();
        return {...doc, 'timestamp': updatedTimestamp};
      }).toList();
      print(jsonEncode(convertedData));
      //await deleteCollection(context, "location");
      //await createCollection(context, "location");
      /*await createCollection(context, "ids");
      await insertDocument(context, "ids", {
        "id": "ime1",
      });
      await insertDocument(context, "ids", {
        "id": "ime2",
      });*/
      //await createCollection(context, "gases");
    } catch (e) {
      print('No se pudo establecer la conexión a la base de datos.');
      print('Error: $e');
      showAlertAndExit(
        context,
        "Error de conexión",
        "No se pudo establecer la conexión a la base de datos",
      );
    }
  }

  void disconnect() {
    db?.close();
    db = null;
  }

  Future<void> getCollectionNames(BuildContext context) async {
    if (db != null) {
      var collectionNames = await db!.getCollectionNames();
      print(jsonEncode(collectionNames));
    } else {
      showAlert(context, "Error", "No se pudo obtener las colecciones");
      print("No se pudo obtener las colecciones");
    }
  }

  Future<void> createCollection(BuildContext context, String collectionName) async {
    if (db != null) {
      await db!.createCollection(collectionName);
    } else {
      showAlert(context, "Error", "No se pudo crear la colección $collectionName");
      print("No se pudo crear la colección $collectionName");
    }
  }

  Future<void> deleteCollection(BuildContext context, String collectionName) async {
    if (db != null) {
      await db!.dropCollection(collectionName);
    } else {
      showAlert(context, "Error", "No se pudo eliminar la colección $collectionName");
      print("No se pudo eliminar la colección $collectionName");
    }
  }

  Future<void> insertDocument(BuildContext context, String collectionName, Map<String, dynamic> document) async {
    if (db != null) {
      await db!.collection(collectionName).insert(document);
      print("inserted");
    } else {
      showAlert(context, "Error", "No se pudo insertar el documento $document en la colección $collectionName");
      print("No se pudo insertar el documento $document en la colección $collectionName");
    }
  }

  Future<bool> checkID(String id) {
    return db!.collection("ids").find({"id": id}).toList().then((value) => value.isNotEmpty);
  }

  Future<List<Location>> getLastNLocations(String id, int n) async {
    var locationCollection = db!.collection("location");
    var gasesCollection = db!.collection("gases");
    var locationItems = await locationCollection
        .find(where.eq("id", id).sortBy("timestamp", descending: true).limit(n))
        .toList()
        .then((list) => list.reversed.toList());
    List<Location> locationList = [];
    int idx = 1;
    for (var locationItem in locationItems) {
      Location location = Location.fromMap(locationItem, idx++);
      var locationTime = location.timestamp;
      var gasesItems = await gasesCollection
          .find(where.eq("id", id).and(where
              .gte("timestamp", locationTime.subtract(const Duration(seconds: 3)))
              .and(where.lte("timestamp", locationTime.add(const Duration(seconds: 3))))))
          .toList();
      for (var gasItem in gasesItems) {
        location.addGas(Gas.fromMap(gasItem));
      }
      // DUMMY
      List<double> valuesDummy = [10, 20, 30];
      Gas gasDummy = Gas(
        gas1: valuesDummy[Random().nextInt(3)],
        gas2: valuesDummy[Random().nextInt(3)],
        gas3: valuesDummy[Random().nextInt(3)],
        timestamp: location.timestamp,
      );
      location.addGas(gasDummy);
      if (Random().nextBool()) {
        Gas gasDummy = Gas(
          gas1: valuesDummy[Random().nextInt(3)],
          gas2: valuesDummy[Random().nextInt(3)],
          gas3: valuesDummy[Random().nextInt(3)],
          timestamp: location.timestamp,
        );
        location.addGas(gasDummy);
      }
      location.calculate();
      locationList.add(location);
    }

    return locationList;
  }
}
