//
//  RootViewController.m
//  TrainController
//
//  Created by Carl Drinkwater on 08/05/2009.
//  Copyright 29degrees Limited 2009. All rights reserved.
//

#import "RootViewController.h"
#import "TrainViewController.h"


@implementation RootViewController

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier;
    
	NSLog( @"%d", [indexPath indexAtPosition:1 ] );
	
	if ( [indexPath indexAtPosition:1 ] == 0 ) {
		cellIdentifier = @"0003";
	} else {
		cellIdentifier = @"0004";
	}
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
	cell.textLabel.text = [ @"Loco " stringByAppendingString:cellIdentifier ];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	// Configure the cell.

    return cell;
}


// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
    // Navigation logic may go here -- for example, create and push another view controller.
	TrainViewController *trainViewController = [[TrainViewController alloc] initWithNibName:@"TrainViewController" bundle:nil];

	if ( [indexPath indexAtPosition:1 ] == 0 ) {
		trainViewController.address = @"0003";
	} else {
		trainViewController.address = @"0004";
	}
	
	[self.navigationController pushViewController:trainViewController animated:YES];
	[trainViewController release];
}

- (void)dealloc {
    [super dealloc];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

@end

