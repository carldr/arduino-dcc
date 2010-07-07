#define NUM_LOCOS 10
#define SLOW 1
#define LONG   for ( int yy = 0; yy < SLOW; yy++ ) { delayMicroseconds( l * SLOW ); }
#define SHORT  for ( int yy = 0; yy < SLOW; yy++ ) { delayMicroseconds( s * SLOW ); }

int l = 90;  // Digitrax : 100/58   Loksound : 90/50  Digitrax : 90/50
int s = 50;

char string[100];

int debug = ( SLOW == 1 ? 0 : 10 );
int ledPin = 13;         // LED connected to digital pin 13

int dccPin1 = 3;
int dccPin2 = 4;
int enablePin = 2;
unsigned int instructions[64];

typedef struct {
  byte address;
  byte speed;  // This is the speed to pass directly in the DCC command.
} Loco;

Loco locos[ NUM_LOCOS ];

void set_speed( byte addr, byte s ) {
  for ( int i = 0; i < NUM_LOCOS; i++ ) {
    if ( locos[ i ].address == addr ) {
      locos[ i ].speed = s;
      return;
    }
  }
}

void setup()                    // run once, when the sketch starts
{
  for ( int i = 0; i<NUM_LOCOS; i++ ) {
    locos[ i ].address = 0;
    locos[ i ].speed = 0;
  }

  Serial.begin(115200);
  
  pinMode(ledPin, OUTPUT);      // sets the digital pin as output
  pinMode(dccPin1, OUTPUT);      // sets the digital pin as output
  pinMode(dccPin2, OUTPUT);      // sets the digital pin as output
  pinMode(enablePin, OUTPUT);
  
  pinMode(2, OUTPUT);
  
  locos[ 3 ].address = 3;
  locos[ 3 ].speed = 0;

  digitalWrite( enablePin, HIGH );
}

void preamble() {
  for ( int i = 0; i < 20; i++ ) {
    do_one();
  }
}

inline void do_byte( byte a ) {
  int t = 128;

  do_zero();      

  for ( int b = 0; b <= 7; b++ ) {
    if ( a & t ) {
      do_one();
    } else {
      do_zero();
    }
      
    t /= 2;
  }
}

inline void do_instructions() {
  preamble();

  for ( int i = 0; i < NUM_LOCOS; i++ ) {
    if ( locos[ i ].address ) {
      do_byte( locos[ i ].address );
      do_byte( 0x3f );
      do_byte( locos[ i ].speed );
      do_byte( locos[ i ].address ^ 0x3f ^ locos[ i ].speed );
      do_one();
    }
  }
  
  // TODO:  Work out WTF this command does.
  do_byte( 0xff );
  do_byte( 0x85 );
  do_byte( 0xff );
  do_byte( 0xff ^ 0x85 ^ 0xff );
  do_one();
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
  do_instructions();

  do_readback();

  if ( Serial.available() >= 2 ) {
    byte a = Serial.read();
    byte s = Serial.read();

    if ( a != -1 && s != -1 ) {
      set_speed( a, s );
    }    
  }  
}

inline void do_zero() {
  digitalWrite( dccPin1, HIGH );
  digitalWrite( dccPin2, LOW );
  LONG;

  digitalWrite( dccPin1, LOW );
  digitalWrite( dccPin2, HIGH );
  LONG;
}

inline void do_one() {
  digitalWrite( dccPin1, HIGH );
  digitalWrite( dccPin2, LOW );
  SHORT;  

  digitalWrite( dccPin1, LOW );
  digitalWrite( dccPin2, HIGH );
  SHORT;   
}
