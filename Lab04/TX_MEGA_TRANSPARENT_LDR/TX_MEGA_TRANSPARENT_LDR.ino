#define LDR A0         // PIN ANALOGO PARA LDR
#define DELAY_LDR 3000  // DELAY DE LDR en ms

float LDR_PERC; // Variable auxiliar para lectura.

#include "Arduino.h"    //Libreria de Arduino
#include "LoRa_E32.h"   //Libreria de Ebyte E32-433T30D

// Construccion de objeto contenedor del Ebyte.
// Serial1 refiere a los pines de ARDUINO: RX 19 AMARILLO | TX 18 NARANJA
LoRa_E32 e32ttl100(&Serial1); 

void setup() {
  Serial.begin(9600);
  delay(500); 
  // Inicializa los pines y el UART para el Ebyte.
  e32ttl100.begin();
}
 
void loop() {
  // Seccion de Lectura de LDR -----------------------------------
  Serial.print("Lectura de LDR: \t\t");
  LDR_PERC = (analogRead(LDR))*0.097;
  Serial.println(String(LDR_PERC)+"%");
  delay(DELAY_LDR);

  // Seccion de envio de mensaje LoRa-----------------------------
  // Envia el mensaje a todos los dispositivos en el canal de 433 MHz
  ResponseStatus rs = e32ttl100.sendMessage(String(LDR_PERC));
  // Revisa si existe algun problema. En caso contrario imprime un
  // Success.
  Serial.print("Estado de envio: \t");
  Serial.println(rs.getResponseDescription());  
}
