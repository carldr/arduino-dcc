#include "WProgram.h"
void setup();
void change_point( int pin );
void loop();
int ledPin = 13;

void setup() {
  for ( int i = 0; i < 16; i++ ) {
    pinMode( i + 22, OUTPUT );
  }
  
  pinMode( ledPin, OUTPUT );
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

/* void straight() {
  change_point( pointStraight );
}

void curve() {
  change_point( pointCurved );
}  */

void loop() {
  for ( int i = 0; i < 16; i++ ) {
    change_point( i + 22 );
    
    delay( 1000 );
  }
  
/*  straight();
  delay(5000);

  curve();
  delay(5000); */
}


int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

