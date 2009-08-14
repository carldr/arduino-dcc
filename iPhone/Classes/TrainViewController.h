//
//  TrainViewController.h
//  TrainController
//
//  Created by Carl Drinkwater on 08/05/2009.
//  Copyright 2009 29degrees Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrainViewController : UIViewController {
	IBOutlet UIActivityIndicatorView *activitySpinner;
	IBOutlet UISlider *speedSlider;
	
	NSString *address;
	
	NSOutputStream *oStream;
	NSInputStream *iStream;
	
	NSTimer *timer;
	NSMutableData *_data;
	bool canWrite;
}

@property (retain)  NSString *address;

- (void)hasLoadedSpeed;
- (void)createStreams;
- (void)timerFired:(NSTimer *)theTimer;

@end
