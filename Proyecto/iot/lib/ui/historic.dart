import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:iot/data/classes.dart';
import 'package:iot/data/mongodb.dart';
import 'package:iot/functions.dart';
import 'package:iot/ui/components/show_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoricPage extends StatefulWidget {
  HistoricPage({super.key});

  final MongoDB mongoDB = GetIt.instance.get<MongoDB>();
  final SharedPreferences prefs = GetIt.instance.get<SharedPreferences>();

  @override
  State<HistoricPage> createState() => _HistoricPageState();
}

class _HistoricPageState extends State<HistoricPage> {
  final dateFormat = DateFormat('dd-MM-yyyy');
  bool gettingData = false;
  List<DateTime?> _startDate = [DateTime.now()];
  List<DateTime?> _endDate = [DateTime.now()];
  bool validData = true;

  List<Gas> _gases = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    setState(() {
      gettingData = true;
    });
    String id = widget.prefs.getString('imeID') ?? '';
    DateTime start = DateTime(_startDate[0]!.year, _startDate[0]!.month, _startDate[0]!.day);
    DateTime end = DateTime(_endDate[0]!.year, _endDate[0]!.month, _endDate[0]!.day, 23, 59, 59);
    _gases = await widget.mongoDB.getGases(id, start, end);
    if (_gases.isEmpty) {
      validData = false;
      Gas dummyGas = Gas(
        co: 0,
        co2: 0,
        alcohol: 0,
        lpg: 0,
        propane: 0,
        timestamp: DateTime.now(),
      );
      _gases.add(dummyGas);
    } else {
      validData = true;
    }
    setState(() {
      gettingData = false;
    });
  }

  void updateGases() {
    setState(() {
      _gases = [];
    });
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
      ),
      body: gettingData
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Obteniendo datos...'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final startDate = await showCalendarDatePicker2Dialog(
                                context: context,
                                config: CalendarDatePicker2WithActionButtonsConfig(),
                                dialogSize: const Size(325, 400),
                                borderRadius: BorderRadius.circular(15),
                                value: _startDate,
                                dialogBackgroundColor: Colors.white,
                              );
                              if (startDate != null) {
                                setState(() {
                                  _startDate = startDate;
                                });
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 100,
                              child: const Text(
                                'Fecha inicial',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            dateFormat.format(_startDate[0]!),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final endDate = await showCalendarDatePicker2Dialog(
                                context: context,
                                config: CalendarDatePicker2WithActionButtonsConfig(),
                                dialogSize: const Size(325, 400),
                                borderRadius: BorderRadius.circular(15),
                                value: _endDate,
                                dialogBackgroundColor: Colors.white,
                              );
                              if (endDate != null) {
                                setState(() {
                                  _endDate = endDate;
                                });
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 100,
                              child: const Text(
                                'Fecha final',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            dateFormat.format(_endDate[0]!),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_endDate[0]!.isBefore(_startDate[0]!)) {
                            showAlert(context, "Error", "La fecha final es anterior a la fecha inicial");
                            return;
                          }
                          updateGases();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50,
                          width: 100,
                          child: const Text(
                            'PROCESAR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 350,
                        height: 450,
                        color: Colors.white,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              chartToRun(_gases, dateFormat),
                              const SizedBox(height: 10),
                              validData && _gases.isNotEmpty ? resume(_gases) : const Text("No hay datos para mostrar"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

Widget resume(List<Gas> gases) {
  double minCO = gases.map((e) => e.co).reduce((a, b) => a < b ? a : b);
  double maxCO = gases.map((e) => e.co).reduce((a, b) => a > b ? a : b);
  double meanCO = gases.map((e) => e.co).reduce((a, b) => a + b) / gases.length;

  double minCO2 = gases.map((e) => e.co2).reduce((a, b) => a < b ? a : b);
  double maxCO2 = gases.map((e) => e.co2).reduce((a, b) => a > b ? a : b);
  double meanCO2 = gases.map((e) => e.co2).reduce((a, b) => a + b) / gases.length;

  double minAlcohol = gases.map((e) => e.alcohol).reduce((a, b) => a < b ? a : b);
  double maxAlcohol = gases.map((e) => e.alcohol).reduce((a, b) => a > b ? a : b);
  double meanAlcohol = gases.map((e) => e.alcohol).reduce((a, b) => a + b) / gases.length;

  double minLPG = gases.map((e) => e.lpg).reduce((a, b) => a < b ? a : b);
  double maxLPG = gases.map((e) => e.lpg).reduce((a, b) => a > b ? a : b);
  double meanLPG = gases.map((e) => e.lpg).reduce((a, b) => a + b) / gases.length;

  double minPropane = gases.map((e) => e.propane).reduce((a, b) => a < b ? a : b);
  double maxPropane = gases.map((e) => e.propane).reduce((a, b) => a > b ? a : b);
  double meanPropane = gases.map((e) => e.propane).reduce((a, b) => a + b) / gases.length;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
      const SizedBox(height: 10),
      Container(
        alignment: Alignment.center,
        child: Text("Total de muestras: ${gases.length}"),
      ),
      const SizedBox(height: 10),
      //formatGasData(String gas, String range, String mean, double value, int index)
      formatGasData("CO", "${minCO.toStringAsFixed(2)} - ${maxCO.toStringAsFixed(2)}", meanCO.toStringAsFixed(2), meanCO, 0),
      const SizedBox(height: 10),
      formatGasData("CO2", "${minCO2.toStringAsFixed(2)} - ${maxCO2.toStringAsFixed(2)}", meanCO2.toStringAsFixed(2), meanCO2, 1),
      const SizedBox(height: 10),
      formatGasData("Alcohol", "${minAlcohol.toStringAsFixed(2)} - ${maxAlcohol.toStringAsFixed(2)}", meanAlcohol.toStringAsFixed(2), meanAlcohol, 2),
      const SizedBox(height: 10),
      formatGasData("GLP", "${minLPG.toStringAsFixed(2)} - ${maxLPG.toStringAsFixed(2)}", meanLPG.toStringAsFixed(2), meanLPG, 3),
      const SizedBox(height: 10),
      formatGasData("Propano", "${minPropane.toStringAsFixed(2)} - ${maxPropane.toStringAsFixed(2)}", meanPropane.toStringAsFixed(2), meanPropane, 4),
      const SizedBox(height: 20),
      legend(),
      const SizedBox(height: 20),
    ],
  );
}

Widget chartToRun(List<Gas> gases, DateFormat dateFormat) {
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
  for (var gas in gases) {
    dataRow1.add(gas.co);
  }
  dataRows.add(dataRow1);
  //gas2
  for (var gas in gases) {
    dataRow2.add(gas.co2);
  }
  dataRows.add(dataRow2);
  //gas3
  for (var gas in gases) {
    dataRow3.add(gas.alcohol);
  }
  dataRows.add(dataRow3);
  //gas4
  for (var gas in gases) {
    dataRow4.add(gas.lpg);
  }
  dataRows.add(dataRow4);
  //gas5
  for (var gas in gases) {
    dataRow5.add(gas.propane);
  }
  dataRows.add(dataRow5);
  // axisX
  List<String> labels = [];
  for (var gas in gases) {
    labels.add(dateFormat.format(gas.timestamp));
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
    size: const Size(600, 300),
  );
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: lineChart,
  );
}
