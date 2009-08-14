//
//  TrainControllerAppDelegate.h
//  TrainController
//
//  Created by Carl Drinkwater on 08/05/2009.
//  Copyright 29degrees Limited 2009. All rights reserved.
//

@interface TrainControllerAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

