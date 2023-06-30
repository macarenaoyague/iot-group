//Include the library
#include <MQUnifiedsensor.h>

//Definitions
#define placa "Arduino MEGA"
#define Voltage_Resolution 5
#define pin0 A0 //For MQ135
#define pin1 A1 //For MQ2
#define type "MQ-135" //MQ135
#define ADC_Bit_Resolution 10 // For arduino UNO/MEGA/NANO
#define RatioMQ135CleanAir 3.6//RS / R0 = 3.6 ppm  
#define RatioMQ2CleanAir (9.83) //RS / R0 = 9.83 ppm 

float ppmCO;
float ppmCO2;
float ppmNH;
float ppmLPG;

//Declare SensorS
MQUnifiedsensor MQ135(placa, Voltage_Resolution, ADC_Bit_Resolution, pin0, type);
MQUnifiedsensor MQ2(placa, Voltage_Resolution, ADC_Bit_Resolution, pin1, type);

void setup() {
  //Init the serial port communication - to debug the library
  Serial.begin(9600); //Init serial port
  
  // MQ135 calibration
  MQ135.setRegressionMethod(1); //_PPM =  a*ratio^b
  MQ135.init(); 
  MQ135.setRL(1);
  Serial.print("Calibrating MQ135 please wait.");
  float calcR0 = 0;
  for(int i = 1; i<=10; i ++)
  {
    MQ135.update(); // Update data, the arduino will read the voltage from the analog pin
    calcR0 += MQ135.calibrate(RatioMQ135CleanAir);
    Serial.print(".");
  }
  MQ135.setR0(calcR0/10);
  Serial.println("  done!.");
  
  if(isinf(calcR0)) {Serial.println("Warning: Conection issue, R0 is infinite (Open circuit detected) please check your wiring and supply"); while(1);}
  if(calcR0 == 0){Serial.println("Warning: Conection issue found, R0 is zero (Analog pin shorts to ground) please check your wiring and supply"); while(1);}
  
  // MQ2 calibration
  MQ2.setRegressionMethod(1); //_PPM =  a*ratio^b
  MQ2.setA(574.25); MQ2.setB(-2.222); // Configure the equation to to calculate LPG concentration
  MQ2.init(); 
  MQ2.setRL(1);
  Serial.print("Calibrating MQ2 please wait.");
  calcR0 = 0;
  for(int i = 1; i<=10; i ++)
  {
    MQ2.update(); // Update data, the arduino will read the voltage from the analog pin
    calcR0 += MQ2.calibrate(RatioMQ2CleanAir);
    Serial.print(".");
  }
  MQ2.setR0(calcR0/10);
  Serial.println("  done!.");
  
  if(isinf(calcR0)) {Serial.println("Warning: Conection issue, R0 is infinite (Open circuit detected) please check your wiring and supply"); while(1);}
  if(calcR0 == 0){Serial.println("Warning: Conection issue found, R0 is zero (Analog pin shorts to ground) please check your wiring and supply"); while(1);}


}

void loop() {
  MQ135.update(); // Update data, the arduino will read the voltage from the analog pin

  MQ135.setA(605.18); MQ135.setB(-3.937);
  ppmCO = MQ135.readSensor();

  MQ135.setA(110.47); MQ135.setB(-2.862);
  ppmCO2 = MQ135.readSensor() + 400;

  MQ135.setA(102.2 ); MQ135.setB(-2.473);
  ppmNH = MQ135.readSensor();

  MQ2.update();
  ppmLPG = MQ2.readSensor();

  Serial.print("CO: ");
  Serial.print(ppmCO);
  Serial.print(" - CO2: ");
  Serial.print(ppmCO2);
  Serial.print(" - NH: ");
  Serial.print(ppmNH);
  Serial.print(" - LPG: ");
  Serial.println(ppmLPG);
  delay(500); //Sampling frequency
}
