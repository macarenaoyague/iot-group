// Librería para enviar datos por el puerto serial
#include <SoftwareSerial.h>
// Librería para leer los sensores MQ2 y MQ135
#include <MQUnifiedsensor.h>

// Pines de comunicación serial conectados al ESP32
const byte rxPin = 15;
const byte txPin = 14;

//Objeto para comunicación serial
SoftwareSerial mySerial (rxPin, txPin);

//Definiciones
#define placa "Arduino MEGA"
#define Voltage_Resolution 5
#define pin0 A0 // Para el MQ135
#define pin1 A1 // Para el MQ2
#define typeMQ135 "MQ-135" // MQ135
#define typeMQ2 "MQ-2" // MQ2
#define ADC_Bit_Resolution 10 // Resolución de bits del ADC
#define RatioMQ135CleanAir 3.6 //RS / R0 = 3.6 ppm, para MQ135
#define RatioMQ2CleanAir 9.83 //RS / R0 = 9.83 ppm, para MQ2

// Variables para almacenar los valores de los sensores
float ppmCO;
float ppmCO2;
float ppmAlcohol;
float ppmLPG;
float ppmPropane;

// Declaración de los sensores
MQUnifiedsensor MQ135(placa, Voltage_Resolution, ADC_Bit_Resolution, pin0, typeMQ135);
MQUnifiedsensor MQ2(placa, Voltage_Resolution, ADC_Bit_Resolution, pin1, typeMQ2);

void setup() {
  // Inicialización de la comunicación serial con la computadora
  Serial.begin(9600);
  // Inicialización de la comunicación serial con el ESP32
  mySerial.begin(9600);

  // Calibración del sensor MQ135
  MQ135.setRegressionMethod(1); //_PPM =  a*ratio^b
  MQ135.init();
  MQ135.setRL(1);
  Serial.print("Calibrando MQ135. Por favor espere.");
  float calcR0 = 0;
  for (int i = 1; i <= 10; i++)
  {
    MQ135.update(); // Update data, Arduino leerá el voltaje del pin analógico
    calcR0 += MQ135.calibrate(RatioMQ135CleanAir);
    Serial.print(".");
  }
  MQ135.setR0(calcR0 / 10);
  Serial.println("  hecho!.");
  
  if(isinf(calcR0)) {Serial.println("Warning: Conection issue, R0 is infinite (Open circuit detected) please check your wiring and supply"); while(1);}
  if(calcR0 == 0){Serial.println("Warning: Conection issue found, R0 is zero (Analog pin shorts to ground) please check your wiring and supply"); while(1);}

  // Calibración del sensor MQ2
  MQ2.setRegressionMethod(1); //_PPM =  a*ratio^b
  MQ2.init();
  MQ2.setRL(1);
  Serial.print("Calibrando MQ2. Por favor espere.");
  float calcR02 = 0;
  for (int i = 1; i <= 10; i++)
  {
    MQ2.update(); // Update data, Arduino leerá el voltaje del pin analógico
    calcR02 += MQ2.calibrate(RatioMQ2CleanAir);
    Serial.print(".");
  }
  MQ2.setR0(calcR02 / 10);
  Serial.println("  hecho!.");

  if(isinf(calcR02)) {Serial.println("Warning: Conection issue, R0 is infinite (Open circuit detected) please check your wiring and supply"); while(1);}
  if(calcR02 == 0){Serial.println("Warning: Conection issue found, R0 is zero (Analog pin shorts to ground) please check your wiring and supply"); while(1);}
}

void loop() {
  // Actualizar valores del sensor MQ135
  MQ135.update();

  // Leer ppm de CO del sensor MQ135
  MQ135.setA(605.18); MQ135.setB(-3.937);
  ppmCO = MQ135.readSensor();

  // Leer ppm de CO2 del sensor MQ135
  MQ135.setA(110.47); MQ135.setB(-2.862);
  ppmCO2 = MQ135.readSensor();

  // Leer ppm de Alcohol del sensor MQ135
  MQ135.setA(77.255); MQ135.setB(-3.18);
  ppmAlcohol = MQ135.readSensor();

  // Actualizar valores del sensor MQ2
  MQ2.update();

  // Leer ppm de LPG del sensor MQ2
  MQ2.setA(574.25); MQ2.setB(-2.222);
  ppmLPG = MQ2.readSensor();

  // Leer ppm de Propano del sensor MQ2
  MQ2.setA(658.71); MQ2.setB(-2.168);
  ppmPropane = MQ2.readSensor();

  // Definimos el id del dispositivo IOT
  String id = "ime1";

  // Imprimir valores de los sensores
  Serual.print("ID: ");
  Serial.print(id);
  Serial.print("\t");
  Serial.print(ppmCO);
  Serial.print(" ppm\t");
  Serial.print("CO2: ");
  Serial.print(ppmCO2);
  Serial.print(" ppm\t");
  Serial.print("Alcohol: ");
  Serial.print(ppmAlcohol);
  Serial.print(" ppm\t");
  Serial.print("LPG: ");
  Serial.print(ppmLPG);
  Serial.print(" ppm\t");
  Serial.print("Propano: ");
  Serial.print(ppmPropane);
  Serial.println(" ppm");

  // Enviar valores de los sensores al ESP32
  mySerial.print(id);
  mySerial.print(" ");
  mySerial.print(ppmCO);
  mySerial.print(" ");
  mySerial.print(ppmCO2);
  mySerial.print(" ");
  mySerial.print(ppmAlcohol);
  mySerial.print(" ");
  mySerial.print(ppmLPG);
  mySerial.print(" ");
  mySerial.println(ppmPropane);

  // Read values from sensors every 1 seconds
  delay(1000);
}