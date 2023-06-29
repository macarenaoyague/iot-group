class Location {
  final int idx;
  final double latitude;
  final double longitude;
  final double speed;
  final DateTime timestamp;

  int ngases = 0;
  double gas1mean = 0;
  double gas2mean = 0;
  double gas3mean = 0;

  List<Gas> gases = [];

  Location({
    required this.idx,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.timestamp,
  });

  factory Location.fromMap(Map<String, dynamic> map, int idx) {
    return Location(
      idx: idx,
      latitude: map['latitude'],
      longitude: map['longitude'],
      speed: map['speed'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'].toInt()),
    );
  }

  void addGas(Gas gas) {
    gases.add(gas);
  }

  void calculate() {
    ngases = gases.length;
    if (ngases > 0) {
      gas1mean = gases.map((e) => e.gas1).reduce((a, b) => a + b) / ngases;
      gas2mean = gases.map((e) => e.gas2).reduce((a, b) => a + b) / ngases;
      gas3mean = gases.map((e) => e.gas3).reduce((a, b) => a + b) / ngases;
    }
  }
}

class Gas {
  final double gas1;
  final double gas2;
  final double gas3;
  final DateTime timestamp;

  Gas({
    required this.gas1,
    required this.gas2,
    required this.gas3,
    required this.timestamp,
  });

  factory Gas.fromMap(Map<String, dynamic> map) {
    return Gas(
      gas1: map['gas1'],
      gas2: map['gas2'],
      gas3: map['gas3'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'].toInt()),
    );
  }
}
