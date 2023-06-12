// Incluimos librería que permite leer las variables del sensor DHT11
#include <DHT.h>

// Definimos el pin digital donde se conecta el sensor
#define DHTPIN 2

// Definimos el tipo de sensor
#define DHTTYPE DHT11
 
// Inicializamos el objeto sensor DHT11
DHT dht(DHTPIN, DHTTYPE);
 
void setup() {
  // Inicializamos la comunicación Serial
  Serial.begin(9600);
 
  // Iniciamos las lecturas del sensor de humedad
  dht.begin();
 
}
 
void loop() {
  // Definimos una espera de 1.5 segundos para realizar la siguiente lectura
  delay(1500);
 
  // Leemos la humedad relativa
  float h = dht.readHumidity();
  // Leemos la temperatura en grados centígrados (por defecto)
  float t = dht.readTemperature();
  // Leemos la temperatura en grados Fahreheit
  float f = dht.readTemperature(true);
 
  // Comprobamos si ha habido algún error en la lectura
  if (isnan(h) || isnan(t) || isnan(f)) {
    Serial.println("Error obteniendo los datos del sensor DHT11");
    return;
  }
 
  // Calcular el índice de calor en grados Fahreheit
  float hif = dht.computeHeatIndex(f, h);
  // Calcular el índice de calor en grados centígrados
  float hic = dht.computeHeatIndex(t, h, false);
 
  // Enviamos las variables humedad y temperatura por el puerto serial para que
  // sean leídas por el ESP32. Para esto, se envía la humedad, una coma y luego
  // la temperatura.
  Serial.print(h);
  Serial.print(",");
  Serial.print(t);
}