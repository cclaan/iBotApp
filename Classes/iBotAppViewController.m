//
//  iBotAppViewController.m
//  iBotApp
//
//  Created by Chris Laan on 9/2/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "iBotAppViewController.h"
#import "RobotAction.h"
#import "AutonomyViewController.h"

@implementation iBotAppViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	
	
	
}


-(IBAction) showBotBrainController {
	
	BotBrainController * bbc = [[BotBrainController alloc] init];
	[self presentModalViewController:bbc animated:YES];
	
}

-(IBAction) showRemoteBrainController {
	
	RemoteBotController * rmb = [[RemoteBotController alloc] init];
	[self presentModalViewController:rmb animated:YES];
	
	
}

-(IBAction) showAutoBrainController {
	
	AutonomyViewController * avc = [[AutonomyViewController alloc] init];
	[self presentModalViewController:avc animated:YES];
	
	
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
