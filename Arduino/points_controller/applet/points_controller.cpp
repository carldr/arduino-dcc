#include "WProgram.h"
void setup();
void change_point( int pin );
void straight();
void curve();
void loop();
int ledPin = 13;
int pointStraight = 24;
int pointCurved = 26;

void setup() {
  pinMode( ledPin, OUTPUT );
  pinMode( pointStraight, OUTPUT );
  pinMode( pointCurved, OUTPUT );
}

int a = 16000;

void change_point( int pin ) {
  digitalWrite( pin, HIGH );
  digitalWrite( ledPin, HIGH );
  delayMicroseconds( a );
 
  digitalWrite( pin, LOW );
  digitalWrite( ledPin, LOW );
  delayMicroseconds( a );

  digitalWrite( pin, HIGH );
  digitalWrite( ledPin, HIGH );
  delayMicroseconds( a );

  digitalWrite( pin, LOW );
  digitalWrite( ledPin, LOW );
  delayMicroseconds( a );
}

void straight() {
  change_point( pointStraight );
}

void curve() {
  change_point( pointCurved );
}  

void loop() {
  straight();
  delay(5000);

  curve();
  delay(5000);
}


int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

