#include <SoftwareSerial.h>

const byte rxPin = 15;
const byte txPin = 14;

SoftwareSerial mySerial (rxPin, txPin);

void setup() {
  Serial.begin(9600);
  mySerial.begin(9600);
}

void loop() {
  // Read values from sensors every 1 seconds
  delay(1000);

  // Read MQ-2 analogic output
  int adc_MQ2 = analogRead(A0);
  // Read MQ-135 analogic output
  int adc_MQ135 = analogRead(A1);

  // Convert MQ-2 input to voltage value
  float voltaje_MQ2 = adc_MQ2 * (5.0 / 1023.0);
  // Convert MQ-135 input to voltage value
  float voltaje_MQ135 = adc_MQ135 * (5.0 / 1023.0);

  Serial.print(voltaje_MQ2);
  Serial.print(",");
  Serial.println(voltaje_MQ135);
  mySerial.print(voltaje_MQ2);
  mySerial.print(",");
  mySerial.print(voltaje_MQ135);


}