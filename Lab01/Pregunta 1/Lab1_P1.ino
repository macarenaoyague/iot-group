// pin de output de posibles colores de semáforo de carros
const int redPin = 45;
const int yellowPin = 47;
const int greenPin = 49;

// pin de output de posibles colores de semáforo de peatones
const int redPedPin = 51;
const int greenPedPin = 53;

// pin de input de un botón digital para colocar la hora de un semáforo
const int resetButton = 52;

// pin de output de Binary Coded Decimal 7 segment de la decena del número del semáforo
const int bit0decena = 31;
const int bit1decena = 33;
const int bit2decena = 35;
const int bit3decena = 37;

// pin de output de Binary Coded Decimal 7 segment de la unidad del número del semáforo
const int bit0unidad = 23;
const int bit1unidad = 25;
const int bit2unidad = 27;
const int bit3unidad = 29;

// tiempos en ms en los que el semáforo en rojo se mantiene en esos estados
long int greenTime = 40000;
long int yellowTime = 3000;
long int redTime = 17000;
long int redToGreenTime = 3000;

// tiempo en ms de parpadeos
int blinkTime = 1000;
int frecBlink = 100;

// configurar horario del día para asignar comportamiento de semáfaro
int resetValue = LOW;
int resetValuePrev = LOW;

enum semaphoreState {GREEN, YELLOW, RED, REDTOGREEN, READTIME, NIGHT};

semaphoreState state;
semaphoreState startState = GREEN;
unsigned long prev, curr, elapsed;
String timeStr;
int hour, min;

void setup() {
	pinMode(redPin, OUTPUT);
	pinMode(yellowPin, OUTPUT);
	pinMode(greenPin, OUTPUT);
	pinMode(redPedPin, OUTPUT);
	pinMode(greenPedPin, OUTPUT);
	pinMode(resetButton, INPUT_PULLUP);
	pinMode(bit0decena, OUTPUT);
	pinMode(bit1decena, OUTPUT);
	pinMode(bit2decena, OUTPUT);
	pinMode(bit3decena, OUTPUT);
	pinMode(bit0unidad, OUTPUT);
	pinMode(bit1unidad, OUTPUT);
	pinMode(bit2unidad, OUTPUT);
	pinMode(bit3unidad, OUTPUT);
	elapsed = 0;
	prev = 0;
	state = startState;
	Serial.begin(9600);
	Serial.println("GREEN");
}

bool isValidTime(String timeStr){
	if(timeStr.length() != 5 && timeStr.length() != 4){
		return false;
	}
	String validChars = "0123456789:";
	for(int i = 0; i < timeStr.length(); i++){
		if(validChars.indexOf(timeStr[i]) == -1){
			return false;
		}
	}
	int colonPos = timeStr.indexOf(":");
	String hourStr = timeStr.substring(0, colonPos);
	String minStr = timeStr.substring(colonPos + 1);
	hour = hourStr.toInt();
	min = minStr.toInt();
	if(hour < 0 || hour > 23){
		return false;
	}
	if(min < 0 || min > 59){
		return false;
	}
	return true;
}

void writeNumberDecena(long int number){
	int decena;
	if (number < 10) decena = 0;
	else decena = (number - number%10)/10;
	digitalWrite(bit0decena, decena & 1);
	digitalWrite(bit1decena, decena & 2);
	digitalWrite(bit2decena, decena & 4);
	digitalWrite(bit3decena, decena & 8);
}

void writeNumberUnidad(long int number){
	int unidad = number%10;
	digitalWrite(bit0unidad, unidad & 1);
	digitalWrite(bit1unidad, unidad & 2);
	digitalWrite(bit2unidad, unidad & 4);
	digitalWrite(bit3unidad, unidad & 8);
}

void setCarColor(int red, int yellow, int green) {
	digitalWrite(redPin, red);
	digitalWrite(yellowPin, yellow);
	digitalWrite(greenPin, green);
}

void setPedestrianColor(int red, int green) {
	digitalWrite(redPedPin, red);
	digitalWrite(greenPedPin, green);
}

void setState(semaphoreState current) {
	state = current;
	switch (current) {
	case GREEN:
		Serial.println("GREEN");
		break;
	case YELLOW:
		Serial.println("YELLOW");
		break;
	case RED:
		Serial.println("RED");
		break;
	case REDTOGREEN:
		Serial.println("REDTOGREEN");
		break;
	case READTIME:
		Serial.println("READTIME");
		break;
	case NIGHT:
		Serial.println("NIGHT");
		break;
	}
	elapsed = 0;
}

void loop() {
	
	curr = millis();
	elapsed += curr - prev;
	prev = curr;

	switch(state){

		case GREEN:
			setCarColor(LOW, LOW, HIGH); //Coloca el color del semaforo de carros en verde
			setPedestrianColor(HIGH, LOW);//Coloca el color del semaforo de peaton en rojo
			
			if(elapsed >= greenTime){ // Cuando el tiempo excede el tiempo del semaforo en verde se cambia el estado
				setState(YELLOW); //Cambia el estado a amarillo

				//Coloca los segundos en vizualizador de siete segmentos
				writeNumberDecena(yellowTime / 1000 + 1);
				writeNumberUnidad(yellowTime / 1000 + 1);
			}

			//Coloca los segundos en vizualizador de siete segmentos
			writeNumberDecena((greenTime - elapsed) / 1000 + 1);
			writeNumberUnidad((greenTime - elapsed) / 1000 + 1);

			break;

		case YELLOW:
			setCarColor(LOW, HIGH, LOW); //Coloca el color del semaforo de carros en amarillo
			setPedestrianColor(HIGH, LOW); //Coloca el color del semaforo de peaton en rojo

			if(elapsed >= yellowTime){// Cuando el tiempo excede el tiempo del semaforo en amarillo se cambia el estado
				setState(RED);// Cambia al siguiente estado rojo

				//Coloca los segundos en vizualizador de siete segmentos
				writeNumberDecena(redTime / 1000 + 1 + redToGreenTime / 1000 + 1);
				writeNumberUnidad(redTime / 1000 + 1 + redToGreenTime / 1000 + 1);
			}

			//Coloca los segundos en vizualizador de siete segmentos
			writeNumberDecena((yellowTime - elapsed) / 1000 + 1);
			writeNumberUnidad((yellowTime - elapsed) / 1000 + 1);

			break;

		case RED:
		
			setCarColor(HIGH, LOW, LOW); //Coloca el color del semaforo de carros en rojo
			setPedestrianColor(LOW, HIGH); //Coloca el color del semaforo de peaton en verde

			if(elapsed >= redTime){ //Cuando el tiempo excede el tiempo del semaforo rojo cambiamos de estado
				setState(REDTOGREEN); //Se cambia al estado REDTOGREEN en donde se hara parpadear el semaforo del peaton
			}
			//Coloca los segundos en vizualizador de siete segmentos
			writeNumberDecena((redTime + redToGreenTime - elapsed) / 1000 + 1);
			writeNumberUnidad((redTime + redToGreenTime - elapsed) / 1000 + 1);
			
			break;

		case REDTOGREEN:

			setCarColor(HIGH, LOW, LOW);//Coloca el semaforo de carro en rojo
			setPedestrianColor(LOW, (elapsed / frecBlink) % 2);//Hace que el semaforo de peaton en un parpadeo

			if(elapsed >= redToGreenTime){ //Si excede el tiempo en este estado, se cambia al siguiente estado
				setState(GREEN); //Se cambia al estado verde

				//Coloca los segundos en vizualizador de siete segmentos
				writeNumberDecena(greenTime / 1000 + 1);
				writeNumberUnidad(greenTime / 1000 + 1);
			}
			
			//Coloca los segundos en vizualizador de siete segmentos
			writeNumberDecena((redToGreenTime - elapsed) / 1000 + 1);
			writeNumberUnidad((redToGreenTime - elapsed) / 1000 + 1);

			break;
			
		case NIGHT:

			setCarColor(LOW, (elapsed / frecBlink) % 2, LOW); //Colocar el semaforo de carros parpadeante
			setPedestrianColor((elapsed / frecBlink) % 2, LOW);//Colocar el semaforo de peaton parpadeante
			
			//Coloca los segundos en vizualizador de siete segmentos
			writeNumberDecena(0);
			writeNumberUnidad(0);

			if(elapsed >= blinkTime){ //Si excede el tiempo del parpadeo, se cambia el tiempo transcurrido a 0
				elapsed = 0;
			}

			break;

		case READTIME://Se toma la hora ingresada, y se verifica si el formato es correcto. Si lo es verifica en que estado colocarlo. Caso contrario pide de nuevo la entrada.
			setCarColor(LOW, LOW, LOW);
			setPedestrianColor(LOW,LOW);
			
			//Coloca los segundos en vizualizador de siete segmentos
			writeNumberDecena(0);
			writeNumberUnidad(0);

			while(Serial.available() > 0){
				Serial.read();
			}
			Serial.println("Ingrese una hora (HH:MM): ");

			do {
				while (!Serial.available()) {}
				timeStr = Serial.readString();
				if(isValidTime(timeStr))
					break;
				Serial.println("Formato incorrecto\nIngrese una hora (HH:MM): ");
			} while (1);

			if (hour >= 22 || hour <= 5) { // madrugada
				state = NIGHT;
				Serial.println("NIGHT");
				elapsed = 0;
			} 
			else {
				if ((hour >= 6 && hour < 10) || (hour >= 17 && hour < 21)) { // hora punta
					greenTime = 87000;
					yellowTime = 3000;
					redTime = 29000;
					redToGreenTime = 3000;
				} else { // hora normal
					greenTime = 40000;
					yellowTime = 3000;
					redTime = 17000;
					redToGreenTime = 3000;
				}

				state = startState;
				Serial.println("GREEN");
				elapsed = 0;

				//Coloca los segundos en vizualizador de siete segmentos
				writeNumberDecena(greenTime / 1000 + 1);
				writeNumberUnidad(greenTime / 1000 + 1);
			}

			break;
	}
	
	resetValue = digitalRead(resetButton);
	if(resetValue == LOW && resetValue != resetValuePrev){
		state = READTIME;
		Serial.println("READTIME");
	}
	resetValuePrev = resetValue;
}