const int signalPin = 0;
const int resetButton = 52;

float val;
unsigned long prev, curr, elapsed;

int samplingTime = 1000;
int delayTime = 200;
const int N = 16;
int vals[N];
int printed = 0;

int resetValue = LOW;
int resetValuePrev = LOW;

void setup() {
    pinMode(signalPin, INPUT);
    pinMode(resetButton, INPUT_PULLUP);
    Serial.begin(9600);
    prev = 0;
    elapsed = 0;
    for(int i = 0; i < N; i++){
        vals[i] = 0;
    }
}

void loop() {
    if(!printed && elapsed >= samplingTime){
        printed = 1;
        for(int i = 0; i < N; i++){
            Serial.print(i);
            Serial.print(": ");
            Serial.println(vals[i]);
        }
    }else{
        curr = millis();
        elapsed += curr - prev;
        prev = curr;
        if(elapsed >= delayTime){
            val = analogRead(signalPin);
		    val = 16.0 * val / 1023.0;
            vals[int(val)] = 1;
        }
    }
    resetValue = digitalRead(resetButton);
	if(resetValue == LOW && resetValue != resetValuePrev){
		printed = 0;
        elapsed = 0;
        for(int i = 0; i < N; i++){
            vals[i] = 0;
        }
	}
	resetValuePrev = resetValue;
}