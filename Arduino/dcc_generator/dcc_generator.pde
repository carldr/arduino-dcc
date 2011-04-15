#define LONG   delayMicroseconds( 100 );
#define SHORT  delayMicroseconds( 58 );

#define LED_PIN 13
#define DCC_PIN_1 3
#define DCC_PIN_2 4
#define ENABLE_PIN 2

#define OUTPUT_STATE_1 B00001100;
#define OUTPUT_STATE_2 B00010100;

// Global vars
byte in_instruction = 0;

// Functions
inline void do_instructions();
inline void do_readback();
void set_point( byte addr, byte s );
void set_speed( byte addr, byte s );
void set_function( byte addr, byte func, byte status );
inline void do_preamble();
inline void do_byte( byte a );
inline void do_one();
inline void do_zero();

// Linked lists
struct _loco {
	byte address;
	byte speed;  // This is the speed to pass directly in the DCC command.
	byte functions;
	
	struct _loco *next;
};
typedef struct _loco Loco;

struct _point {
	byte address;
	boolean straight;
	
	struct _point *next;
};
typedef struct _point Point;

Loco *locos = NULL;
Loco *firstLoco = NULL;

Point *points = NULL;
Point *firstPoint = NULL;


// Here we go!

void setup() {
	Serial.begin(115200);

	pinMode( LED_PIN, OUTPUT );
	pinMode( DCC_PIN_1, OUTPUT );
	pinMode( DCC_PIN_2, OUTPUT );
	pinMode( ENABLE_PIN, OUTPUT );

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

void set_point( byte addr, byte s ) {
	for ( Point *curPoint = firstPoint; curPoint; curPoint = curPoint->next ) {
		if ( curPoint->address == addr ) {
			curPoint->straight = (s>0);
			return;
		}
	}
	
	//  Didn't find an existing point with that address, so create a new one
	//  and stick it at the front of the queue.
	Point *newPoint = (Point *)malloc( sizeof( Point ) * 1 );
	newPoint->address = addr;
	newPoint->straight = (s>0);
	newPoint->next = firstPoint;
	
	firstPoint = newPoint;
}  

void set_speed( byte addr, byte s ) {
	for ( Loco *curLoco = firstLoco; curLoco; curLoco = curLoco->next ) {
		if ( curLoco->address == addr ) {
			curLoco->speed = s;
			return;
		}
	}

	//  Didn't find an existing loco with that address, so create a new one
	//  and stick it at the front of the queue.
	Loco *newLoco = (Loco *)malloc( sizeof( Loco ) * 1 );
	newLoco->address = addr;
	newLoco->speed = s;
	newLoco->next = firstLoco;
	
	firstLoco = newLoco;
}

void set_function( byte addr, byte func, byte status ) {
	for ( Loco *curLoco = firstLoco; curLoco; curLoco = curLoco->next ) {
		if ( curLoco->address == addr ) {
			if ( status == 1 ) {
				curLoco->functions |= 1 << ( func - 1 );
			} else {
				curLoco->functions &= ~( 1 << ( func - 1 ) );
			}

			return;
		}
	}  
}



inline void do_instructions() {
	for ( Loco *curLoco = firstLoco; curLoco; curLoco = curLoco->next ) {
		if ( curLoco->address ) {
			do_preamble();
			do_byte( curLoco->address );
			do_byte( 0x3f );
			do_byte( curLoco->speed );
			do_byte( curLoco->address ^ 0x3f ^ curLoco->speed );
			do_one();

			do_preamble();
			do_byte( curLoco->address );
			do_byte( 128 + curLoco->functions );
			do_byte( curLoco->address ^ ( 128 + curLoco->functions ) );
			do_one();
		}
	}

	for ( Point *curPoint = firstPoint; curPoint; curPoint = curPoint->next ) {
		if ( curPoint->address ) {
			int channel = (( ( curPoint->address - 1 ) & 0x03 ) << 1 );
			if ( curPoint->straight ) {
				channel |= 1;
			}

			int address = ( curPoint->address - 1 ) >> 2;
			address += 1;

			int a = 0x80 | ( address & 0x3f );
			int b = 0x80 | ( ( ( ( ~address ) >> 6 ) & 0x07 ) << 4 ) | 0x08 /* always active */ | ( channel & 0x07 );

			do_preamble();
			do_byte( a );
			do_byte( b );
			do_byte( a ^ b );
			do_one();
		}
	}

	// TODO:  Work out WTF this command does.
	do_preamble();
	do_byte( 0xff );
	do_byte( 0x85 );
	do_byte( 0xff );
	do_byte( 0xff ^ 0x85 ^ 0xff );
	do_one();
}

inline void do_readback() {
	digitalWrite( ENABLE_PIN, LOW );

	SHORT;
	SHORT;
	SHORT;
	SHORT;

	digitalWrite( ENABLE_PIN, HIGH );
}


inline void do_preamble() {
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
