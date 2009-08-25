#define SLOW 1

#define LONG   for ( int yy = 0; yy < SLOW; yy++ ) { delayMicroseconds( l * SLOW ); }
#define SHORT  for ( int yy = 0; yy < SLOW; yy++ ) { delayMicroseconds( s * SLOW ); }

int l = 100;
int s = 58;

char string[100];

int debug = ( SLOW == 1 ? 0 : 10 );
int dccPin = 7;                // LED connected to digital pin 13
int ledPin = 13;         // LED connected to digital pin 13
int enablePin = 6;
unsigned int instructions[64];

int b = 0;

void set_speed( int loco, int s ) {
  b = 1 - b;
  digitalWrite( 2, b );
  
  if ( loco == 3 ) {
    instructions[0] = 0x03;
    instructions[1] = 0x3f;
    instructions[2] = s;
    instructions[3] = ( instructions[0] ^ instructions[1] ^ instructions[2] );
  } else if ( loco == 4 ) {
    instructions[4] = 0x04;
    instructions[5] = 0x3f;
    instructions[6] = s;
    instructions[7] = ( instructions[4] ^ instructions[5] ^ instructions[6] );
  }
  
  instructions[8] = 0xff;
  instructions[9] = 0x85;
  instructions[10] = 0xff;
  instructions[11] = ( instructions[8] ^ instructions[9] ^ instructions[10] );
}

void setup()                    // run once, when the sketch starts
{
  Serial.begin(115200);
  
  pinMode(ledPin, OUTPUT);      // sets the digital pin as output
  pinMode(dccPin, OUTPUT);      // sets the digital pin as output
  pinMode(enablePin, OUTPUT);
  
  pinMode(2, OUTPUT);
  
  set_speed( 3, 0x00 );
  set_speed( 4, 0x00 );
  
  digitalWrite( enablePin, HIGH );
}

void preamble() {
  for ( int i = 0; i < 20; i++ ) {
    do_one();
  }
}

void do_instructions( int s, int e ) {
  for ( int i = s; i <= e; i++ ) {
    int t = 128;

    do_zero();

    for ( int b = 0; b <= 7; b++ ) {
      if ( instructions[ i ] & t ) {        
        do_one();
      } else {
        do_zero();
      }
      
      t /= 2;
    }
  }  
}

void do_readback() {
  digitalWrite( enablePin, LOW );
  
  SHORT;
  SHORT;
  SHORT;
  SHORT;
  
  digitalWrite( enablePin, HIGH );
}

void loop()                     // run over and over again
{
  preamble();
  do_instructions( 0, 3 );
  do_one();

  preamble();
  do_instructions( 4, 7 );
  do_one();

  preamble();
  do_instructions( 8, 11 );
  do_one();

  do_readback();

  if ( Serial.available() >= 2 ) {
    int l = Serial.read();
    int s = Serial.read();

    if ( l != -1 && s != -1 ) {
      set_speed( l, s );
    }    
  }  
}

inline void do_zero() {
  if ( debug ) { digitalWrite( 2, HIGH ); }
  
  digitalWrite( dccPin, HIGH );
  LONG;

  if ( debug ) { digitalWrite( 2, LOW ); }

  digitalWrite( dccPin, LOW );
  LONG;
}

inline void do_one() {
  if ( debug ) { digitalWrite( 2, HIGH ); }

  digitalWrite( dccPin, HIGH );
  SHORT;  

  if ( debug ) { digitalWrite( 2, LOW ); }

  digitalWrite( dccPin, LOW );
  SHORT;   
}
