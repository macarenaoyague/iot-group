

#include <Servo.h>
#include <Keypad.h>

///////////////////// USO DE LA LIBRERÍA KEYPAD CON LA AYUDA DE LA DOCUMENTACIÓN//////////////////////////
const int ROW_NUM = 4; //four rows
const int COLUMN_NUM = 4; //four columns
char keys[ROW_NUM][COLUMN_NUM] = {
  {'1','2','3', 'A'},
  {'4','5','6', 'B'},
  {'7','8','9', 'C'},
  {'*','0','#', 'D'}
};
byte pin_rows[ROW_NUM] = {9, 8, 7, 6}; //connect to the row pinouts of the keypad
byte pin_column[COLUMN_NUM] = {5, 4, 3, 2}; //connect to the column pinouts of the keypad
Keypad keypad = Keypad( makeKeymap(keys), pin_rows, pin_column, ROW_NUM, COLUMN_NUM );
/////////////////////////////////////////////////////////////////////////////////////////////////////////



const String password = "1234"; // Elegiremos una contraseña
String input_password; //String donde se concatenaran los caracteres ingresados por el keypad
Servo servo;  // un motor que simulara la puerta abierta/cerrada


int pos = 0;
float duration_us, distance_cm; //Tenemos dos valores flotantes en donde almacenaremos la duracion del pulso y en la otra la distancia en la que se encuentra el objeto/persona
int trigPin = 12;    // TRIG pin
int echoPin = 13;    // ECHO pin

void setup(){
  Serial.begin(9600);
  input_password.reserve(32); //reservamos una cantidad de caracteres para la cadena
  servo.attach(11);  //conectamos el motor en el pin 11
  servo.write(90);  //elegimos la posicion inicial (cerrado) que es 90°
  //configuramos el trigPin
  pinMode(trigPin, OUTPUT);
  //configuramos el echoPin
  pinMode(echoPin, INPUT);                
}


void loop(){
  char key = keypad.getKey(); //Tomamos el numero ingresado en el keypad
  if (key){
    Serial.println(key);
    if(key == '*') { //Boton para limpiar la cadena en donde esta la contraseña
      input_password = ""; //Limpiar cadena input
    } else if(key == '#') { //Boton de enviar - para empezar el proceso de investigación
      if(password == input_password) { //Si la contraseña ingresada es igual a la contraseña elegida la contraseña es correcta
        Serial.println("password is correct");
        servo.write(0);//abrimos la puerta cambiando la posicion a 0°
        delay(5000); //Esperamos 5 segundos
        do{ 

		  //creamos un pulso de 10 microsegundos en el trigPin
          digitalWrite(trigPin, HIGH);
          delayMicroseconds(10);
          digitalWrite(trigPin, LOW);
            
		  //medimos la duracion del pulso en el echoPin
          duration_us = pulseIn(echoPin, HIGH);

          //a partir de la duracion del pulso, hallamos la distancia en la que se encuentra la persona
          distance_cm = 0.017 * duration_us;
          Serial.print("distance: ");
          Serial.print(distance_cm);
          Serial.println(" cm");
        } while (distance_cm < 30); //Mientras que la persona se encuentre a menos de 30 cm de distancia del sensor de ultrasonido
        servo.write(90); //cerramos la puerda                               
      } else {
        Serial.println("password is incorrect, try again");
      }
      input_password = ""; //Limpiamos la contraseña
    } else {
      input_password += key; //si es que no se pone #, concatenamos el caracter ingresado en la cadena
    }
  }
}

