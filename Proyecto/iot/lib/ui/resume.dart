import 'package:flutter/material.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:iot/data/classes.dart';
import 'package:iot/data/mongodb.dart';
import 'package:iot/functions.dart';
import 'package:iot/ui/components/example_popup.dart';
import 'package:iot/ui/resume_arguments.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResumePage extends StatefulWidget {
  static const routeName = 'resume';

  ResumePage({super.key});

  final MongoDB mongoDB = GetIt.instance.get<MongoDB>();
  final SharedPreferences prefs = GetIt.instance.get<SharedPreferences>();

  @override
  State<ResumePage> createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> {
  List<Marker> _markers = [];
  List<Location> _locations = [];
  bool gettingData = true;
  ResumeArguments? args;
  int n = 0;
  final dateFormat = DateFormat('dd-MM-yyyy');

  final PopupController _popupLayerController = PopupController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      args = ModalRoute.of(context)!.settings.arguments as ResumeArguments?;
      n = args!.samples;
      fetchData();
    });
  }

  Future<void> fetchData() async {
    setState(() {
      gettingData = true;
    });
    String id = widget.prefs.getString('imeID') ?? '';
    _locations = await widget.mongoDB.getLastNLocations(id, n);
    bool first = true;
    for (var location in _locations) {
      if (first) {
        Marker marker = Marker(
          point: LatLng(location.latitude, location.longitude),
          width: 40,
          height: 40,
          builder: (first) {
            return const Icon(
              Icons.location_on,
              size: 40,
              color: Colors.green,
            );
          },
          anchorPos: AnchorPos.align(AnchorAlign.top),
          rotateAlignment: AnchorAlign.top.rotationAlignment,
        );
        _markers.add(marker);
        first = false;
      } else {
        Marker marker = Marker(
          point: LatLng(location.latitude, location.longitude),
          width: 40,
          height: 40,
          builder: (first) {
            return const Icon(
              Icons.location_on,
              size: 40,
              color: Colors.red,
            );
          },
          anchorPos: AnchorPos.align(AnchorAlign.top),
          rotateAlignment: AnchorAlign.top.rotationAlignment,
        );
        _markers.add(marker);
      }
    }
    setState(() {
      gettingData = false;
    });
  }

  void updateLocations() {
    setState(() {
      _markers = [];
      _locations = [];
      n = int.parse(_selectedValue);
    });
    fetchData();
  }

  @override
  void dispose() {
    _popupLayerController.dispose();
    super.dispose();
  }

  String resumeData(int gasN) {
    //"Gas X: Mínimo - Máximo ppm (Media ppm de promedio)"
    String resume = "Gas ";
    double min, max, mean;
    switch (gasN) {
      case 1:
        min = _locations.map((e) => e.gasCOmean).reduce((a, b) => a < b ? a : b);
        max = _locations.map((e) => e.gasCOmean).reduce((a, b) => a > b ? a : b);
        mean = _locations.map((e) => e.gasCOmean).reduce((a, b) => a + b) / _locations.length;
        resume += "CO: ${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)} ppm (${mean.toStringAsFixed(2)} ppm de promedio)";
        break;
      case 2:
        min = _locations.map((e) => e.gasCO2mean).reduce((a, b) => a < b ? a : b);
        max = _locations.map((e) => e.gasCO2mean).reduce((a, b) => a > b ? a : b);
        mean = _locations.map((e) => e.gasCO2mean).reduce((a, b) => a + b) / _locations.length;
        resume += "CO2: ${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)} ppm (${mean.toStringAsFixed(2)} ppm de promedio)";
        break;
      case 3:
        min = _locations.map((e) => e.gasAlcoholmean).reduce((a, b) => a < b ? a : b);
        max = _locations.map((e) => e.gasAlcoholmean).reduce((a, b) => a > b ? a : b);
        mean = _locations.map((e) => e.gasAlcoholmean).reduce((a, b) => a + b) / _locations.length;
        resume += "Alcohol: ${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)} ppm (${mean.toStringAsFixed(2)} ppm de promedio)";
        break;
      case 4:
        min = _locations.map((e) => e.gasLPGmean).reduce((a, b) => a < b ? a : b);
        max = _locations.map((e) => e.gasLPGmean).reduce((a, b) => a > b ? a : b);
        mean = _locations.map((e) => e.gasLPGmean).reduce((a, b) => a + b) / _locations.length;
        resume += "GLP: ${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)} ppm (${mean.toStringAsFixed(2)} ppm de promedio)";
      case 5:
        min = _locations.map((e) => e.gasPropanemean).reduce((a, b) => a < b ? a : b);
        max = _locations.map((e) => e.gasPropanemean).reduce((a, b) => a > b ? a : b);
        mean = _locations.map((e) => e.gasPropanemean).reduce((a, b) => a + b) / _locations.length;
        resume += "Propano: ${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)} ppm (${mean.toStringAsFixed(2)} ppm de promedio)";
        break;
    }
    return resume;
  }

  bool isGraphicVisible = false;
  bool isResumeVisible = false;
  String _selectedValue = '5';

  @override
  Widget build(BuildContext context) {
    return gettingData
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Mostrar datos'),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Obteniendo datos...'),
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Mostrar datos'),
            ),
            body: Stack(
              children: <Widget>[
                FlutterMap(
                  options: MapOptions(
                    zoom: 16.0,
                    center: LatLng(
                      _locations.isNotEmpty ? _locations[0].latitude : -12.135212,
                      _locations.isNotEmpty ? _locations[0].longitude : -77.021901,
                    ),
                    onTap: (_, __) {
                      _popupLayerController.hideAllPopups();
                      setState(() {
                        isGraphicVisible = false;
                        isResumeVisible = false;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    PopupMarkerLayer(
                      options: PopupMarkerLayerOptions(
                        popupController: _popupLayerController,
                        markers: _markers,
                        popupDisplayOptions: PopupDisplayOptions(
                          builder: (BuildContext context, Marker marker) {
                            int markerIdx = _markers.indexOf(marker);
                            Location location = _locations[markerIdx];
                            return ExamplePopup(marker, location);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                if (_locations.isEmpty)
                  const Center(
                    child: Text(
                      ' No hay datos para mostrar ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (_locations.isNotEmpty)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isGraphicVisible = !isGraphicVisible;
                          isResumeVisible = false;
                        });
                      },
                      child: const Text('Mostrar gráfico'),
                    ),
                  ),
                if (_locations.isNotEmpty)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isResumeVisible = !isResumeVisible;
                          isGraphicVisible = false;
                        });
                      },
                      child: const Text('Mostrar resumen'),
                    ),
                  ),
                if (_locations.isNotEmpty)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[400]!,
                        ),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedValue,
                          elevation: 3,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedValue = newValue!;
                              isGraphicVisible = false;
                              isResumeVisible = false;
                            });
                            updateLocations();
                          },
                          items: List.generate(10, (index) {
                            int value = index + 1;
                            return DropdownMenuItem<String>(
                              value: value.toString(),
                              child: Text(value.toString()),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                if (_locations.isNotEmpty)
                  Visibility(
                    visible: isGraphicVisible,
                    child: Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 350,
                          height: 500,
                          color: Colors.white,
                          child: chartToRun(_locations),
                        ),
                      ),
                    ),
                  ),
                if (_locations.isNotEmpty)
                  Visibility(
                    visible: isResumeVisible,
                    child: Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 350,
                          height: 500,
                          padding: const EdgeInsets.all(20),
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Container(
                                alignment: Alignment.center,
                                child: const Text(
                                  'Resumen',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text('Desde ${dateFormat.format(_locations.first.timestamp)} hasta ${dateFormat.format(_locations.last.timestamp)}'),
                              const SizedBox(height: 20),
                              Text('Cantidad de posiciones: ${_locations.length}'),
                              const SizedBox(height: 40),
                              calculeResumeData(_locations, 0),
                              const SizedBox(height: 20),
                              calculeResumeData(_locations, 1),
                              const SizedBox(height: 20),
                              calculeResumeData(_locations, 2),
                              const SizedBox(height: 20),
                              calculeResumeData(_locations, 3),
                              const SizedBox(height: 20),
                              calculeResumeData(_locations, 4),
                              const SizedBox(height: 40),
                              legend(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
  }
}

RichText calculeResumeData(List<Location> locations, int gasN) {
  String gas = "";
  String range = "";
  double min = 0.0, max = 0.0, mean = 0.0;
  switch (gasN) {
    case 0:
      gas = "CO";
      min = locations.map((e) => e.gasCOmean).reduce((a, b) => a < b ? a : b);
      max = locations.map((e) => e.gasCOmean).reduce((a, b) => a > b ? a : b);
      mean = locations.map((e) => e.gasCOmean).reduce((a, b) => a + b) / locations.length;
      range = "${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)}";
      break;
    case 1:
      min = locations.map((e) => e.gasCO2mean).reduce((a, b) => a < b ? a : b);
      max = locations.map((e) => e.gasCO2mean).reduce((a, b) => a > b ? a : b);
      mean = locations.map((e) => e.gasCO2mean).reduce((a, b) => a + b) / locations.length;
      gas = "CO2";
      range = "${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)}";
      break;
    case 2:
      min = locations.map((e) => e.gasAlcoholmean).reduce((a, b) => a < b ? a : b);
      max = locations.map((e) => e.gasAlcoholmean).reduce((a, b) => a > b ? a : b);
      mean = locations.map((e) => e.gasAlcoholmean).reduce((a, b) => a + b) / locations.length;
      gas = "Alcohol";
      range = "${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)}";
      break;
    case 3:
      min = locations.map((e) => e.gasLPGmean).reduce((a, b) => a < b ? a : b);
      max = locations.map((e) => e.gasLPGmean).reduce((a, b) => a > b ? a : b);
      mean = locations.map((e) => e.gasLPGmean).reduce((a, b) => a + b) / locations.length;
      gas = "GLP";
      range = "${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)}";
    case 4:
      min = locations.map((e) => e.gasPropanemean).reduce((a, b) => a < b ? a : b);
      max = locations.map((e) => e.gasPropanemean).reduce((a, b) => a > b ? a : b);
      mean = locations.map((e) => e.gasPropanemean).reduce((a, b) => a + b) / locations.length;
      gas = "Propano";
      range = "${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)}";
      break;
  }
  return formatGasData(gas, range, mean.toStringAsFixed(2), mean, gasN);
}

Widget chartToRun(List<Location> locations) {
  LabelLayoutStrategy? xContainerLabelLayoutStrategy;
  ChartData chartData;
  ChartOptions chartOptions = const ChartOptions();
  xContainerLabelLayoutStrategy = DefaultIterativeLabelLayoutStrategy(
    options: chartOptions,
  );
  List<List<double>> dataRows = [];
  List<double> dataRow1 = [];
  List<double> dataRow2 = [];
  List<double> dataRow3 = [];
  List<double> dataRow4 = [];
  List<double> dataRow5 = [];
  //gas1
  for (var location in locations) {
    dataRow1.add(location.gasCOmean);
  }
  dataRows.add(dataRow1);
  //gas2
  for (var location in locations) {
    dataRow2.add(location.gasCO2mean);
  }
  dataRows.add(dataRow2);
  //gas3
  for (var location in locations) {
    dataRow3.add(location.gasAlcoholmean);
  }
  dataRows.add(dataRow3);
  //gas4
  for (var location in locations) {
    dataRow4.add(location.gasLPGmean);
  }
  dataRows.add(dataRow4);
  //gas5
  for (var location in locations) {
    dataRow5.add(location.gasPropanemean);
  }
  dataRows.add(dataRow5);
  // axisX
  List<String> labels = [];
  for (var location in locations) {
    labels.add("Punto ${location.idx.toString()}");
  }
  // series
  List<String> series = ["ppm CO", "ppm CO2", "ppm Alcohol", "ppm LPG", "ppm Propane"];
  chartData = ChartData(
    dataRows: dataRows,
    xUserLabels: labels,
    dataRowsLegends: series,
    chartOptions: chartOptions,
  );
  var lineChartContainer = LineChartTopContainer(
    chartData: chartData,
    xContainerLabelLayoutStrategy: xContainerLabelLayoutStrategy,
  );

  var lineChart = LineChart(
    painter: LineChartPainter(
      lineChartContainer: lineChartContainer,
    ),
    size: const Size(500, 500),
  );
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: lineChart,
  );
}
