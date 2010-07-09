#define NUM_LOCOS 10
#define SLOW 1
#define LONG   delayMicroseconds( l * SLOW );
#define SHORT  delayMicroseconds( s * SLOW );

int l = 88;  // Digitrax : 100/58   Loksound : 90/50  Digitrax : 90/50
int s = 48;

int ledPin = 13;         // LED connected to digital pin 13
int dccPin1 = 3;
int dccPin2 = 4;
int enablePin = 2;

byte in_instruction = 0;

typedef struct {
  byte address;
  byte speed;  // This is the speed to pass directly in the DCC command.
  byte functions;
} Loco;

Loco locos[ NUM_LOCOS ];

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

void set_speed( byte addr, byte s ) {
  for ( int i = 0; i < NUM_LOCOS; i++ ) {
    if ( locos[ i ].address == addr ) {
      locos[ i ].speed = s;
      return;
    }
  }
}

void set_function( byte addr, byte func, byte status ) {
  for ( int i = 0; i < NUM_LOCOS; i++ ) {
    if ( locos[ i ].address == addr ) {
      if ( status == 1 ) {
        locos[ i ].functions |= 1 << ( func - 1 );
      } else {
        locos[ i ].functions &= ~( 1 << ( func - 1 ) );
      }
      
      return;
    }
  }  
}

void setup() {
  for ( int i = 0; i<NUM_LOCOS; i++ ) {
    locos[ i ].address = 0;
    locos[ i ].speed = 0;
    locos[ i ].functions = 0;
  }

  Serial.begin(115200);
  
  pinMode(ledPin, OUTPUT);      // sets the digital pin as output
  pinMode(dccPin1, OUTPUT);      // sets the digital pin as output
  pinMode(dccPin2, OUTPUT);      // sets the digital pin as output
  pinMode(enablePin, OUTPUT);
  
  pinMode(2, OUTPUT);
  
  locos[ 3 ].address = 3;
  locos[ 3 ].speed = 0;
  locos[ 3 ].functions = 0;

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
  for ( int i = 0; i < NUM_LOCOS; i++ ) {
    if ( locos[ i ].address ) {
      preamble();
      do_byte( locos[ i ].address );
      do_byte( 0x3f );
      do_byte( locos[ i ].speed );
      do_byte( locos[ i ].address ^ 0x3f ^ locos[ i ].speed );
      do_one();
      
      preamble();
      do_byte( locos[ i ].address );
      do_byte( 128 + locos[ i ].functions );
      do_byte( locos[ i ].address ^ ( 128 + locos[ i ].functions ) );
      do_one();
    }
  }
  
  // TODO:  Work out WTF this command does.
  preamble();
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

void loop() {
  do_instructions();

  do_readback();

  if ( !in_instruction ) {
    if ( Serial.available() >= 1 ) {
      in_instruction = Serial.read();
    }
  }

  switch ( in_instruction ) {
    case 's':
      if ( Serial.available() >= 2 ) {
        set_speed( Serial.read(), Serial.read() );
      }
      
      in_instruction = 0;
      break;
     
    case 'f':
      if ( Serial.available() >=3 ) {
        set_function( Serial.read(), Serial.read(), Serial.read() );
      }

      in_instruction = 0;
      break;
  } 
}

