//
//  TrainViewController.m
//  TrainController
//
//  Created by Carl Drinkwater on 08/05/2009.
//  Copyright 2009 29degrees Limited. All rights reserved.
//

#import "TrainViewController.h"

@implementation TrainViewController

@synthesize address;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)createStreams {
	NSLog( @"Setting up streams." );

	CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
	
    readStream = NULL;
    writeStream = NULL;
	
    CFStreamCreatePairWithSocketToHost(
									   NULL, 
									   (CFStringRef) @"192.168.0.128", 
									   7531, 
									   ((iStream  != nil) ? &readStream : NULL),
									   ((oStream != nil) ? &writeStream : NULL)
									   );
	
    if (iStream != NULL) {
        iStream  = [NSMakeCollectable(readStream) autorelease];
    }
    if (oStream != NULL) {
        iStream = [NSMakeCollectable(writeStream) autorelease];
    }
	
	if ( oStream == NULL && iStream == NULL ) {
		NSLog( @"Dying." );
		exit(1);
	}
	
	[iStream retain];
	[oStream retain];
	[iStream setDelegate:self];
	[oStream setDelegate:self];
	[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[iStream open];
	[oStream open];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
	NSLog( @"stream:handleEvent is invoked ..." );
	
	switch( eventCode ) {
		case NSStreamEventHasBytesAvailable: {
			if ( !_data ) {
				_data = [[NSMutableData data] retain];
			}
			
			uint8_t buf[1024];
			unsigned int len = 0;
			len = [(NSInputStream *)stream read:buf maxLength:1024];
			if ( len ) {
				NSLog( @"Added '%s'", buf );
				[_data appendBytes:(const void *)buf length:len];
			} else {
				NSLog( @"No buffer!" );
			}
			
			break;
		}

		case NSStreamEventHasSpaceAvailable: {
			canWrite = YES;

			break;
		}
	}

	
	// See if there is any input for us
	NSString *s = [[NSString alloc] initWithData:_data encoding:NSASCIIStringEncoding ];
	
	NSRange r = [s rangeOfString:@"\r\n"];
	if ( r.location != NSNotFound ) {
		NSLog( @"Hmmm!" );
		
		NSLog( @"Location: %d  Length: %d", r.location, r.length );
		
		NSString *speed = [s substringToIndex:r.location];
		NSLog( @"Got speed : %@", speed );

		s = [s substringFromIndex:r.location + 2];
		[_data setData:[s dataUsingEncoding:NSASCIIStringEncoding]];

		float speedNumber = [speed intValue] / 100.0;
		speedSlider.value = speedNumber;
		[self hasLoadedSpeed];
	}
	
	NSLog( s );
	[s release];
}
	

- (void)timerFired:(NSTimer *)timer {
	if ( canWrite == YES ) {
		NSString *speed = [NSString stringWithFormat:@"%d\r\n", (int)( [speedSlider value] * 100.0 ) ];

		NSLog( @"Going to write data '%@'", speed );

		const char *rawstring = [speed cStringUsingEncoding:NSASCIIStringEncoding];

		NSLog( @"Writing data '%s'", rawstring );

		NSInteger err = [oStream write:(uint8_t *)rawstring maxLength:strlen( rawstring )];
		
		NSLog( @"Write returned %d", err );
		
		canWrite = NO;
	}
}

- (void)hasLoadedSpeed {
	speedSlider.enabled = true;
	activitySpinner.hidden = true;	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	canWrite = NO;
	
	timer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector( timerFired: ) userInfo:nil repeats:YES ] retain];
	
	[self createStreams];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	if ( oStream ) {
		[oStream close];
		[oStream release];
		oStream = nil;
	}
	
	if ( iStream ) {
		[iStream close];
		[iStream release];
		iStream = nil;
	}
	
	if ( _data ) {
		[_data release];
		_data = nil;
	}
	
	if ( timer ) {
		[timer invalidate];
		[timer release];
		timer = nil;
	}
}


- (void)dealloc {
	self.address = nil;
    
	[super dealloc];
}


@end