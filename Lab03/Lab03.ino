#include "DHT.h"
#include <WiFi.h>
#include <PubSubClient.h>
#include <Wire.h>

#define DHTPIN 18
#define DHTTYPE DHT11

// Replace the next variables with your SSID/Password combination
const char* ssid = "OnePlus 5T";
const char* password = "jneirar12345678";

// Add your MQTT Broker IP address, example:
const char* mqtt_server = "127.0.0.1";

WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[50];
int value = 0;

DHT dht(DHTPIN, DHTTYPE); // constructor to declare our sensor


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
  
  // If a message is received on the topic esp32/output, you check if the message is either "on" or "off". 
  // Changes the output state according to the message
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

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    if (client.connect("ESP32Client")) {
      Serial.println("connected");
      // Subscribe
      client.subscribe("esp32/output");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}


void setup_wifi() {
  delay(10);
  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void setup() {
  Serial.begin(115200);

  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);


  dht.begin();
}



void loop() {

  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  long now = millis();

  
  

  if (now - lastMsg > 1000) {
    lastMsg = now;
    
    // The DHT11 returns at most one measurement every 1s
    float h = dht.readHumidity();
    //Read the moisture content in %.
    float t = dht.readTemperature();
    //Read the temperature in degrees Celsius
    float f = dht.readTemperature(true);
    // true returns the temperature in Fahrenheit

    if (isnan(h) || isnan(t) || isnan(f)) {
      Serial.println("Failed reception");
      //Returns an error if the ESP32 does not receive any measurements
    } else {
       Serial.print("Humidite: ");
      Serial.print(h);
      Serial.print("%  Temperature: ");
      Serial.print(t);
      Serial.print("°C, ");
      Serial.print(f);
      Serial.println("°F");
      // Transmits the measurements received in the serial monitor
      
      // Convert the value to a char array
      char tempString[8];
      char humString[8];
      dtostrf(t, 1, 2, tempString);
      Serial.print("Temperature: ");
      Serial.println(tempString);
      client.publish("esp32/temperature", tempString);    
      // Convert the value to a char array
      dtostrf(h, 1, 2, humString);
      Serial.print("Humidity: ");
      Serial.println(humString);
      client.publish("esp32/humidity", humString);
    }
  }

}