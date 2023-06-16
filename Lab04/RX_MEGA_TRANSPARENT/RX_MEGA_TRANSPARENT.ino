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
  Serial.println("Esperando mensajes LoRa en canal de 433MHz: ");
}
 
void loop() {
  // Verifica si hay buffer en el Ebyte.
  if (e32ttl100.available()>1) {
    // Lee la cadena recibida.
    ResponseContainer rc = e32ttl100.receiveMessage();
    // Avisa si hay error.
    if (rc.status.code!=1){
        rc.status.getResponseDescription();
    }else{
        // Imprime la data recibida.
        Serial.println(rc.data);
    }
  }
}