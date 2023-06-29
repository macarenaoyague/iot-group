import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:iot/data/mongodb.dart';
import 'package:iot/theme.dart';
import 'package:iot/ui/components/show_alert.dart';
import 'package:iot/ui/resume_arguments.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  final TextEditingController idController = TextEditingController();
  final MongoDB mongoDB = GetIt.instance.get<MongoDB>();
  final SharedPreferences prefs = GetIt.instance.get<SharedPreferences>();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.prefs.containsKey('imeID')) {
      widget.idController.text = widget.prefs.getString('imeID')!;
    }
    connectToDatabase();
  }

  Future<void> connectToDatabase() async {
    await widget.mongoDB.connect(context);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.idController.text = "ime1";
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: BlueTheme.primary,
        body: isLoading
            ? const SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 100),
                      Text(
                        "IME",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 200),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Conectando a la base de datos...',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 100),
                      const Text(
                        "IME",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 100),
                      const Text(
                        'Ingrese un ID del dispositivo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: widget.idController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'ID',
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (widget.idController.text.isEmpty) {
                            showAlert(context, "Error", "Ingrese el ID del dispositivo");
                            return;
                          }
                          final id = widget.idController.text;
                          widget.mongoDB.checkID(id).then((exists) {
                            if (!exists) {
                              showAlert(context, "Error", "El ID no existe en la base de datos");
                              return;
                            }
                            widget.prefs.setString('imeID', id);
                            Navigator.pushNamed(context, 'sharing');
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(BlueTheme.primaryButton),
                        ),
                        child: const SizedBox(
                          height: 75,
                          child: Center(
                            child: Text(
                              'Enviar información',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (widget.idController.text.isEmpty) {
                            showAlert(context, "Error", "Ingrese el ID del dispositivo");
                            return;
                          }
                          final id = widget.idController.text;
                          widget.mongoDB.checkID(id).then((exists) {
                            if (!exists) {
                              showAlert(context, "Error", "El ID no existe en la base de datos");
                              return;
                            }
                            widget.prefs.setString('imeID', id).then(
                                  (value) => Navigator.pushNamed(
                                    context,
                                    'resume',
                                    arguments: ResumeArguments(samples: 5, changeSamples: true),
                                  ),
                                );
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(BlueTheme.primaryButton),
                        ),
                        child: const SizedBox(
                          height: 75,
                          child: Center(
                            child: Text(
                              'Mostrar información en mapa',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
