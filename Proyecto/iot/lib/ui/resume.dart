import 'package:flutter/material.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get_it/get_it.dart';
import 'package:iot/data/classes.dart';
import 'package:iot/data/mongodb.dart';
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
    print("length _locations: ${_locations.length}");
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
    setState(() {});
  }

  @override
  void dispose() {
    _popupLayerController.dispose();
    super.dispose();
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
              children: [
                FlutterMap(
                  options: MapOptions(
                    zoom: 16.0,
                    center: LatLng(
                      _locations.isNotEmpty ? _locations[0].latitude : -12.135212,
                      _locations.isNotEmpty ? _locations[0].longitude : -77.021901,
                    ),
                    onTap: (_, __) => _popupLayerController.hideAllPopups(),
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
                Visibility(
                  visible: isGraphicVisible,
                  child: Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 300,
                        height: 500,
                        color: Colors.white,
                        child: chartToRun(_locations),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: isResumeVisible,
                  child: Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 300,
                        height: 500,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              'Resumen de datos',
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text('Cantidad de posiciones: ${_locations.length}'),
                            const SizedBox(
                              height: 20,
                            ),
                            Text('Promedio del gas 1: ${_locations.map((e) => e.gas1mean).reduce((a, b) => a + b) / _locations.length}'),
                            const SizedBox(
                              height: 20,
                            ),
                            Text('Promedio del gas 2: ${_locations.map((e) => e.gas2mean).reduce((a, b) => a + b) / _locations.length}'),
                            const SizedBox(
                              height: 20,
                            ),
                            Text('Promedio del gas 3: ${_locations.map((e) => e.gas3mean).reduce((a, b) => a + b) / _locations.length}'),
                            const SizedBox(
                              height: 20,
                            ),
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
  //gas1
  for (var location in locations) {
    dataRow1.add(location.gas1mean);
  }
  dataRows.add(dataRow1);
  //gas2
  for (var location in locations) {
    dataRow2.add(location.gas2mean);
  }
  dataRows.add(dataRow2);
  //gas3
  for (var location in locations) {
    dataRow3.add(location.gas3mean);
  }
  dataRows.add(dataRow3);
  // axisX
  List<String> labels = [];
  for (var location in locations) {
    labels.add(location.idx.toString());
  }
  // series
  List<String> series = ["gas 1", "gas 2", "gas 3"];
  chartData = ChartData(
    dataRows: dataRows,
    xUserLabels: labels,
    dataRowsLegends: series,
    chartOptions: chartOptions,
  );
  // chartData.dataRowsDefaultColors(); // if not set, called in constructor
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
