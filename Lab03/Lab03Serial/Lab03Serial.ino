// this sample code provided by www.programmingboss.com
#include <WiFi.h>
#include <PubSubClient.h>
#include <Wire.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define RXp2 16
#define TXp2 17

// Replace the next variables with your SSID/Password combination
const char* ssid = "OnePlus 5T";
const char* password = "jneirar12345678";

// Add your MQTT Broker IP address, example:
const char* mqtt_server = "192.168.189.196";

WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[50];
int value = 0;

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
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial2.begin(9600, SERIAL_8N1, RXp2, TXp2);

  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
}

void loop() {
    // Recieve input from Arduino
    String input = Serial2.readString();
    Serial.println(input);

    int icomma = input.indexOf(',');
    String humidity = input.substring(0, icomma);
    String temperature = input.substring(icomma + 1);

    if (!client.connected()) {
      reconnect();
    }
    client.loop();
  
    long now = millis();
  
    if (now - lastMsg > 1000) {
      lastMsg = now;
      int humidityLen = humidity.length() + 1; 
      char charHumidity[humidityLen];
      humidity.toCharArray(charHumidity, humidityLen);
      int temperatureLen = temperature.length() + 1;
      char charTemperature[temperatureLen];
      temperature.toCharArray(charHumidity, humidityLen);
      
      client.publish("esp32/humidity", charHumidity);
      client.publish("esp32/temperature", charTemperature);
    }
}
