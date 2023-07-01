import 'package:flutter/material.dart';
import 'package:iot/constant.dart';

RichText formatGasData(String gas, String range, String mean, double value, int index) {
  double limit1 = limits[2 * index];
  double limit2 = limits[2 * index + 1];
  Color colorSelected = value <= limit1
      ? Colors.green
      : value <= limit2
          ? Colors.yellow.shade700
          : Colors.red;
  return RichText(
    text: TextSpan(
      children: [
        const TextSpan(
          text: "Gas ",
          style: TextStyle(color: Colors.black),
        ),
        TextSpan(
          text: gas,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: ": $range ppm (",
          style: const TextStyle(color: Colors.black),
        ),
        TextSpan(
          text: " $mean ",
          style: TextStyle(color: Colors.white, backgroundColor: colorSelected, fontWeight: FontWeight.bold),
        ),
        const TextSpan(
          text: " ppm de media)",
          style: TextStyle(color: Colors.black),
        ),
      ],
    ),
  );
}

Row legend() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 20,
        height: 20,
        color: Colors.green,
      ),
      const SizedBox(width: 5),
      const Text("Todo bien"),
      const SizedBox(width: 10),
      Container(
        width: 20,
        height: 20,
        color: Colors.yellow.shade700,
      ),
      const SizedBox(width: 5),
      const Text("Cuidado"),
      const SizedBox(width: 10),
      Container(
        width: 20,
        height: 20,
        color: Colors.red,
      ),
      const SizedBox(width: 5),
      const Text("Peligroso"),
      const SizedBox(width: 10),
    ],
  );
}
