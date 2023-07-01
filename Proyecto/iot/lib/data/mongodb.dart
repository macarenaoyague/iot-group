import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:fixnum/fixnum.dart';
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

      var collection = db!.collection("gases");
      inspect(collection);
      var data = await collection.find().toList();
      var convertedData = data.map((doc) {
        var updatedTimestamp = doc['timestamp'].toInt();
        return {...doc, 'timestamp': updatedTimestamp};
      }).toList();
      print(jsonEncode(convertedData));

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

  Future<void> insertDocument(BuildContext context, String collectionName, Map<String, dynamic> document) async {
    if (db != null) {
      await db!.collection(collectionName).insert(document);
    } else {
      showAlert(context, "Error", "No se pudo insertar el documento $document en la colección $collectionName\n\nError: db is null");
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
      Int64 from = Int64(locationTime.subtract(const Duration(seconds: 3)).millisecondsSinceEpoch);
      Int64 to = Int64(locationTime.add(const Duration(seconds: 3)).millisecondsSinceEpoch);
      var gasesItems = await gasesCollection.find(where.eq("id", id).and(where.gte("timestamp", from).and(where.lte("timestamp", to)))).toList();
      for (var gasItem in gasesItems) {
        location.addGas(Gas.fromMap(gasItem));
      }
      // DUMMY
      List<double> valuesDummy = [1, 2, 3, 4, 5];
      Gas gasDummy = Gas(
        co: valuesDummy[Random().nextInt(3)],
        co2: valuesDummy[Random().nextInt(3)],
        alcohol: valuesDummy[Random().nextInt(3)],
        lpg: valuesDummy[Random().nextInt(3)],
        propane: valuesDummy[Random().nextInt(3)],
        timestamp: location.timestamp,
      );
      location.addGas(gasDummy);
      if (Random().nextBool()) {
        Gas gasDummy = Gas(
          co: valuesDummy[Random().nextInt(3)],
          co2: valuesDummy[Random().nextInt(3)],
          alcohol: valuesDummy[Random().nextInt(3)],
          lpg: valuesDummy[Random().nextInt(3)],
          propane: valuesDummy[Random().nextInt(3)],
          timestamp: location.timestamp,
        );
        location.addGas(gasDummy);
      }
      location.calculate();
      locationList.add(location);
    }

    return locationList;
  }

  Future<List<Gas>> getGases(String id, DateTime from, DateTime to) async {
    var gasesCollection = db!.collection("gases");
    Int64 fromInt64 = Int64(from.millisecondsSinceEpoch);
    Int64 toInt64 = Int64(to.millisecondsSinceEpoch);
    var gasesItems =
        await gasesCollection.find(where.eq("id", id).and(where.gte("timestamp", fromInt64).and(where.lte("timestamp", toInt64)))).toList();
    List<Gas> gasesList = [];
    for (var gasItem in gasesItems) {
      gasesList.add(Gas.fromMap(gasItem));
    }
    return gasesList;
  }
}
