import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:iot/data/mongodb.dart';
import 'package:iot/ui/components/show_alert.dart';
import 'package:iot/ui/resume_arguments.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharingPage extends StatefulWidget {
  SharingPage({Key? key}) : super(key: key);
  final SharedPreferences prefs = GetIt.instance.get<SharedPreferences>();
  final MongoDB mongoDB = GetIt.instance.get<MongoDB>();

  @override
  _SharingPageState createState() => _SharingPageState();
}

class _SharingPageState extends State<SharingPage> {
  int samples = 0;

  final Geolocator geolocator = Geolocator();
  List<Map<String, dynamic>> locations = [];

  double latitude = 0.0;
  double longitude = 0.0;
  double speed = 0.0;
  bool sending = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    sending = false;
    timer?.cancel();
    super.dispose();
  }

  void startLocationUpdates() {
    if (mounted) {
      updateLocation().then((_) {
        if (sending && mounted) {
          startLocationUpdates();
        }
      });
    }
  }

  Future<void> stopLocationUpdates() async {
    sending = false;
    if (mounted) {
      if (locations.isNotEmpty) {
        await sendData();
        locations.clear();
      }
      setState(() {
        latitude = 0.0;
        longitude = 0.0;
        speed = 0.0;
      });
    }
  }

  Future<void> sendData() async {
    await widget.mongoDB.insertDocuments(
      context,
      'location',
      locations,
    );
  }

  Future<void> updateLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // No se concedieron los permisos de ubicación, manejar el escenario correspondiente.
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    if (mounted && sending) {
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        speed = position.speed;
        samples++;
      });

      locations.add(
        {
          'latitude': latitude,
          'longitude': longitude,
          'speed': speed,
          'id': widget.prefs.getString('imeID'),
          'createdAt': DateTime.now().toUtc(),
        },
      );

      if (locations.length == 4) {
        await sendData();
        locations.clear();
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  Stopwatch stopwatch = Stopwatch();
  String formattedTime = '00:00:00';
  Timer? timer;

  void startTimer() {
    setState(() {
      sending = true;
      samples = 0;
    });
    startLocationUpdates();
    stopwatch.reset();
    stopwatch.start();
    timer = Timer.periodic(const Duration(milliseconds: 1), (_) {
      if (mounted) {
        setState(() {
          formattedTime = getFormattedTime(stopwatch.elapsed);
        });
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    stopLocationUpdates();
    setState(() {
      stopwatch.stop();
    });
    if (samples > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Envío de datos finalizado'),
            content: const Text('¿Desea ver el resumen de los datos obtenidos?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(
                    'resume',
                    arguments: ResumeArguments(
                      samples: samples,
                      changeSamples: false,
                    ),
                  );
                  setState(() {
                    samples = 0;
                  });
                },
                child: const Text('Sí'),
              ),
            ],
          );
        },
      );
    } else {
      showAlert(
        context,
        "Advertencia",
        "No se envió ningún dato de localización.",
      );
    }
  }

  String getFormattedTime(Duration duration) {
    String hours = (duration.inHours % 60).toString().padLeft(2, '0');
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Envío de datos'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Latitud: $latitude'),
              Text('Longitud: $longitude'),
              Text('Velocidad: $speed'),
              Text('Datos enviados: $samples'),
              Text('idIME: ${widget.prefs.getString('imeID')}'),
              const SizedBox(height: 150),
              GestureDetector(
                onTap: () {
                  if (stopwatch.isRunning) {
                    stopTimer();
                  } else {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      startTimer();
                    });
                  }
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sending ? Colors.red : Colors.green,
                  ),
                  child: Center(
                    child: Text(
                      sending ? 'Fin' : 'Inicio',
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tiempo: $formattedTime',
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
