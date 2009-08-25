//
//  TrainControllerAppDelegate.m
//  TrainController
//
//  Created by Carl Drinkwater on 08/05/2009.
//  Copyright 29degrees Limited 2009. All rights reserved.
//

#import "TrainControllerAppDelegate.h"
#import "RootViewController.h"


@implementation TrainControllerAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

