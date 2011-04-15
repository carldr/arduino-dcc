#define NUM_LOCOS 10
#define NUM_POINTS 10
#define LONG   delayMicroseconds( 100 );
#define SHORT  delayMicroseconds( 58 );

#define LED_PIN 13
#define DCC_PIN_1 3
#define DCC_PIN_2 4
#define ENABLE_PIN 2

#define OUTPUT_STATE_1 B00001100;
#define OUTPUT_STATE_2 B00010100;

byte in_instruction = 0;

typedef struct {
  byte address;
  byte speed;  // This is the speed to pass directly in the DCC command.
  byte functions;
} Loco;

typedef struct {
  byte address;
  boolean straight;
} Point;

Loco locos[ NUM_LOCOS ];
Point points[ NUM_POINTS ];

inline void do_zero() {
  PORTD = OUTPUT_STATE_1;
  LONG;

  PORTD = OUTPUT_STATE_2;
  LONG;
}

inline void do_one() {
  PORTD = OUTPUT_STATE_1;
  SHORT;

  PORTD = OUTPUT_STATE_2;
  SHORT;   
}

void set_point( byte addr, byte s ) {
  for ( int i = 0; i < NUM_POINTS; i++ ) {
    if ( points[ i ].address == addr ) {
      points[ i ].straight = (s>0);
      return;
    }
  }
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


  for ( int i = 0; i<NUM_POINTS; i++ ) {
    points[ i ].address = 0;
    points[ i ].straight = false;
  }

  Serial.begin(115200);
  
  pinMode( LED_PIN, OUTPUT );
  pinMode( DCC_PIN_1, OUTPUT );
  pinMode( DCC_PIN_2, OUTPUT );
  pinMode( ENABLE_PIN, OUTPUT );
  
  locos[ 0 ].address = 35;
  locos[ 0 ].speed = 0;
  locos[ 0 ].functions = 0;

  locos[ 1 ].address = 13;
  locos[ 1 ].speed = 0;
  locos[ 1 ].functions = 0;

  locos[ 2 ].address = 18;
  locos[ 2 ].speed = 0;
  locos[ 2 ].functions = 0;

  locos[ 2 ].address = 74;
  locos[ 2 ].speed = 0;
  locos[ 2 ].functions = 0;

  points[ 0 ].address = 1;
  points[ 0 ].straight = true;
  
  points[ 1 ].address = 2;
  points[ 1 ].straight = true;

  points[ 2 ].address = 3;
  points[ 2 ].straight = true;

  points[ 3 ].address = 4;
  points[ 3 ].straight = true;

  digitalWrite( ENABLE_PIN, HIGH );
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

  for ( int i = 0; i < NUM_POINTS; i++ ) {
    if ( points[ i ].address ) {
      int channel = (( ( points[i].address - 1 ) & 0x03 ) << 1 );
      if ( points[ i ].straight ) {
        channel |= 1;
      }
      
      int address = ( points[i].address - 1 ) >> 2;
      address += 1;
      
      int a = 0x80 | ( address & 0x3f );
      int b = 0x80 | ( ( ( ( ~address ) >> 6 ) & 0x07 ) << 4 ) | 0x08 /* always active */ | ( channel & 0x07 );

      preamble();
      do_byte( a );
      do_byte( b );
      do_byte( a ^ b );
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
  digitalWrite( ENABLE_PIN, LOW );
  
  SHORT;
  SHORT;
  SHORT;
  SHORT;
  
  digitalWrite( ENABLE_PIN, HIGH );
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
    
    case 'p':
      if ( Serial.available() >= 2 ) {
        set_point( Serial.read(), Serial.read() );
      }
      
      in_instruction = 0;
      break;
  } 
}

