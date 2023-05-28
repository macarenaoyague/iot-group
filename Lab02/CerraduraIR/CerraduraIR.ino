// Librerías para usar el teclado y el servo
#include <Keypad.h>
#include <Servo.h>

// Definición del objeto servo
Servo servoMotor;

// Definición del teclado de 4 filas y 4 columnas
const int ROW_NUM = 4;
const int COLUMN_NUM = 4;
char keys[ROW_NUM][COLUMN_NUM] = {
  {'1','2','3', 'A'},
  {'4','5','6', 'B'},
  {'7','8','9', 'C'},
  {'*','0','#', 'D'}
};

// Pines de las filas y columnas del teclado
byte pin_rows[ROW_NUM] = {9, 8, 7, 6};
byte pin_column[COLUMN_NUM] = {5, 4, 3, 2};

// Definición del objeto teclado
Keypad keypad = Keypad( makeKeymap(keys), pin_rows, pin_column, ROW_NUM, COLUMN_NUM );

// Definición de la contraseña
const String password = "1234";

// Variable para guardar la contraseña introducida
String input_password;

// Definición de los pines del servo y el sensor
const int servoPin = 11;
const int sensorPin = 10;

// Definición del ángulo de apertura de la puerta
const int angle = 90;

void setup(){
    // Inicialización de la variable de la contraseña
    input_password.reserve(32); 

    // Inicialización del pin del servo
    servoMotor.attach(servoPin);
    servoMotor.write(0);

    // Inicialización del pin del sensor
    pinMode(sensorPin , INPUT);

    // Inicialización del puerto serie
    Serial.begin(9600);
}

void loop(){
    // Lectura de la tecla pulsada
    char key = keypad.getKey();

    // Si se ha pulsado una tecla
    if (key){
        if(key == '*') {
            // Si se ha pulsado la tecla de asterisco entonces se limpia la contraseña
            input_password = "";
            Serial.println("password cleaned");
        } else if(key == '#') {
            // Si se ha pulsado la tecla de almohadilla entonces se comprueba la contraseña
            if(password == input_password) {
                // Si la contraseña es correcta se muestra un mensaje por el puerto serie
                Serial.println("password is correct");
                Serial.println("Opening door");
                // Abrimos la puerta
                for (int i = 0; i <= angle; i++){
                    servoMotor.write(i);
                    delay(10);
                }
                // Esperamos a que el sensor detecte que no hay nadie en la puerta
                while(1){
                    int value = digitalRead(sensorPin);
                    if(value == HIGH){
                        delay(1000);
                        break;
                    }
                }
                delay(2000);
                // Cerramos la puerta
                Serial.println("Closing door");
                for (int i = angle; i > 0; i--){
                    servoMotor.write(i);
                    delay(10);
                }
            } else {
                // Si la contraseña es incorrecta se muestra un mensaje por el puerto serie
                Serial.println("password is incorrect, try again");
            }
            // Se limpia la contraseña
            input_password = "";
        } else {
            // Se añade la tecla pulsada a la contraseña introducida
            input_password += key;
        }
        // Se muestra la contraseña introducida por el puerto serie
        Serial.println(input_password);
    }
}