import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iot/data/classes.dart';

class ExamplePopup extends StatefulWidget {
  final Marker marker;
  final Location location;

  const ExamplePopup(this.marker, this.location, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExamplePopupState();
}

class _ExamplePopupState extends State<ExamplePopup> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _cardDescription(context),
          ],
        ),
      ),
    );
  }

  Widget _cardDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Punto ${widget.location.idx}',
              overflow: TextOverflow.fade,
              softWrap: false,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
            Text(
              'Número de muestras: ${widget.location.ngases}',
              style: const TextStyle(fontSize: 12.0),
            ),
            Text(
              'Concentración media del gas 1: ${widget.location.gas1mean}',
              style: const TextStyle(fontSize: 12.0),
            ),
            Text(
              'Concentración media del gas 2: ${widget.location.gas2mean}',
              style: const TextStyle(fontSize: 12.0),
            ),
            Text(
              'Concentración media del gas 3: ${widget.location.gas3mean}',
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }
}
