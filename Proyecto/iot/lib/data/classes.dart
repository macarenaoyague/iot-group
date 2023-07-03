class Location {
  final int idx;
  final double latitude;
  final double longitude;
  final double speed;
  final DateTime createdAt;

  int ngases = 0;
  double gasCOmean = 0;
  double gasCO2mean = 0;
  double gasAlcoholmean = 0;
  double gasLPGmean = 0;
  double gasPropanemean = 0;

  List<Gas> gases = [];

  Location({
    required this.idx,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.createdAt,
  });

  factory Location.fromMap(Map<String, dynamic> map, int idx) {
    return Location(
      idx: idx,
      latitude: map['latitude'],
      longitude: map['longitude'],
      speed: map['speed'],
      createdAt: map['createdAt'],
    );
  }

  void addGas(Gas gas) {
    gases.add(gas);
  }

  void calculate() {
    ngases = gases.length;
    if (ngases > 0) {
      gasCOmean = gases.map((e) => e.co).reduce((a, b) => a + b) / ngases;
      gasCO2mean = gases.map((e) => e.co2).reduce((a, b) => a + b) / ngases;
      gasAlcoholmean = gases.map((e) => e.alcohol).reduce((a, b) => a + b) / ngases;
      gasLPGmean = gases.map((e) => e.lpg).reduce((a, b) => a + b) / ngases;
      gasPropanemean = gases.map((e) => e.propane).reduce((a, b) => a + b) / ngases;
    }
  }
}

class Gas {
  final double co;
  final double co2;
  final double alcohol;
  final double lpg;
  final double propane;
  final DateTime createdAt;

  Gas({
    required this.co,
    required this.co2,
    required this.alcohol,
    required this.lpg,
    required this.propane,
    required this.createdAt,
  });

  factory Gas.fromMap(Map<String, dynamic> map) {
    return Gas(
      co: map['gases']['co'],
      co2: map['gases']['co2'],
      alcohol: map['gases']['alcohol'],
      lpg: map['gases']['lpg'],
      propane: map['gases']['propane'],
      createdAt: map['createdAt'],
    );
  }
}
