#define LDR A0         // PIN ANALOGO PARA LDR
#define DELAY_LDR 3000  // DELAY DE LDR en ms

#include "Arduino.h"    //Libreria de Arduino
#include "LoRa_E32.h"   //Libreria de Ebyte E32-433T30D

// Construccion de objeto contenedor del Ebyte.
// Serial1 refiere a los pines de ARDUINO: RX 19 AMARILLO | TX 18 NARANJA
LoRa_E32 e32ttl100(&Serial1); 
const int Trigger = 7;   //Pin digital 2 para el Trigger del sensor
const int Echo = 6;   //Pin digital 3 para el Echo del sensor

void setup() {
  Serial.begin(9600);
  delay(500); 
  // Inicializa los pines y el UART para el Ebyte.
  e32ttl100.begin();

  pinMode(Trigger, OUTPUT); //pin como salida
  pinMode(Echo, INPUT);  //pin como entrada
  digitalWrite(Trigger, LOW);//Inicializamos el pin con 0
}
 
void loop() {
  // Seccion de Lectura del sensor de distancia -----------------------------------
  long t; //timepo que demora en llegar el eco
  long d; //distancia en centimetros

  digitalWrite(Trigger, HIGH);
  delayMicroseconds(10);          //Enviamos un pulso de 10us
  digitalWrite(Trigger, LOW);
  
  t = pulseIn(Echo, HIGH); //obtenemos el ancho del pulso
  d = t/59;             //escalamos el tiempo a una distancia en cm

  Serial.println(String(d) + " cm");
  delay(DELAY_US);

  // Seccion de envio de mensaje LoRa-----------------------------
  // Envia el mensaje a todos los dispositivos en el canal de 433 MHz
  ResponseStatus rs = e32ttl100.sendMessage(String(d) + " cm");
  // Revisa si existe algun problema. En caso contrario imprime un
  // Success.
  Serial.print("Estado de envio: \t");
  Serial.println(rs.getResponseDescription());  
}
