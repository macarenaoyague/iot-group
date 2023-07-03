// Definimos las librerías que vamos a utilizar

// La librería WiFi.h nos permite conectarnos a una red WiFi
#include <WiFi.h>

// La librería PubSubClient.h nos permite conectarnos a un servidor MQTT
#include <PubSubClient.h>

// La librería Wire.h nos permite comunicarnos con dispositivos I2C
#include <Wire.h>

// Las siguientes librerías nos permiten utilizar funciones básicas para el manejo de cadenas de caracteres
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Definimos los pines que vamos a utilizar para la comunicación serial del ESP32 con el Arduino
#define RXp2 16
#define TXp2 17

// Definimos el SSID y la contraseña de la red WiFi a la que el ESP32 se va a conectar (red local generada por el celular)
const char* ssid = "OnePlus 5T";
const char* password = "jneirar12345678";

// Definimos la dirección IP del servidor MQTT
const char* mqtt_server = "192.168.189.196";

// Definimos el cliente WiFi y el cliente MQTT, así como las variables que vamos a utilizar para el manejo de mensajes
WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[50];
int value = 0;

// Función callback que se ejecuta cuando se recibe un mensaje en el tópico esp32/output. Puede ser utilizado para dar inicio a la comunicación entre el ESP32 y el servidor MQTT.
void callback(char* topic, byte* message, unsigned int length) {
  Serial.print("Message arrived on topic: ");
  Serial.print(topic);
  Serial.print(". Message: ");
  String messageTemp;
  for (int i = 0; i < length; i++) {
    Serial.print((char)message[i]);
    messageTemp += (char)message[i];
  }
  Serial.println();
  
  // Si se recibe un mensaje en el tópico esp32/output, se verifica si el mensaje es "on" o "off".
  // Cambia el estado de la salida de acuerdo al mensaje
  if (String(topic) == "esp32/output") {
    Serial.print("Changing output to ");
    if(messageTemp == "on"){
      Serial.println("on");
    }
    else if(messageTemp == "off"){
      Serial.println("off");
    }
  }
}

// Función que se ejecuta cuando se pierde la conexión con el servidor MQTT. Se intenta reconectar hasta que se logra la conexión.
void reconnect() {
  // Bucle hasta que se logre la conexión
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Intenta conectar
    if (client.connect("ESP32Client")) {
      Serial.println("connected");
      // Una vez conectado, se suscribe al tópico esp32/output
      client.subscribe("esp32/output");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Espera 5 segundos antes de volver a intentar
      delay(5000);
    }
  }
}

// Función que se ejecuta al inicio del programa. Se conecta a la red WiFi y al servidor MQTT.
void setup_wifi() {
  delay(10);
  // Nos conectamos a la red WiFi
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  // Esperamos a que se establezca la conexión
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  // Mostramos la dirección IP del ESP32 en la red WiFi a la que se conectó
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void setup() {
  // Inicializamos la comunicación serial con el monitor serial
  Serial.begin(115200);

  // Inicializamos la comunicación serial con el Arduino, la velocidad de comunicación debe ser la misma que la velocidad de comunicación definida en el Arduino
  Serial2.begin(9600, SERIAL_8N1, RXp2, TXp2);

  // Inicializamos la conexión WiFi
  setup_wifi();

  // Inicializamos la conexión con el servidor MQTT en el puerto 1883
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
}

void loop() {
    // Recibimos los datos del Arduino por medio de la comunicación serial
    String input = Serial2.readString();
    Serial.println(input);

    // Si no se ha logrado la conexión con el servidor MQTT, se intenta reconectar
    if (!client.connected()) {
      reconnect();
    }
    client.loop();

    // Definimos la variable para almacenar el tiempo actual
    long now = millis();

    // Si ha pasado un segundo desde el último mensaje, se publica la humedad y la temperatura en los tópicos esp32/humidity y esp32/temperature
    if (now - lastMsg > 1000) {
      lastMsg = now;
      
      // Publicamos la humedad y la temperatura en los tópicos esp32/humidity y esp32/temperature
      client.publish("esp32/data", input);
    }
}
