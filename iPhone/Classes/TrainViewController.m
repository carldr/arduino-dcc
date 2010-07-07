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

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)createStreams {
	NSLog( @"Setting up streams." );

	CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
	
    readStream = NULL;
    writeStream = NULL;
	
    CFStreamCreatePairWithSocketToHost(
									   NULL, 
									   (CFStringRef) @"localhost", 
									   7531, 
									   &readStream,
									   &writeStream
									   );
	
	if ( readStream == NULL || writeStream == NULL ) {
		NSLog( @"Dying." );
		exit(1);
	}
	
	iStream = (NSInputStream *)readStream;
	oStream = (NSOutputStream *)writeStream;	
	[iStream retain];
	[oStream retain];
	[iStream setDelegate:self];
	[oStream setDelegate:self];
	[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[iStream open];
	[oStream open];
	
	CFRelease( readStream );
	CFRelease( writeStream );
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

		float speedNumber = [speed intValue];
		speedSlider.value = speedNumber;
		[self hasLoadedSpeed];
	}
	
	NSLog( s );
	[s release];
}
	

- (void)timerFired:(NSTimer *)timer {
	if ( canWrite == YES ) {
		NSString *speed = [NSString stringWithFormat:@"%d:%d\r\n", [address intValue], (int)( [speedSlider value] ) ];

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

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

- (void)viewDidDisappear:(BOOL)animated {
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
	
	[super viewDidDisappear:animated];
}


- (void)dealloc {
	self.address = nil;
    
	[super dealloc];
}


@end
