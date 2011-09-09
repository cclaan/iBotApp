//
//  AutonomyViewController.m
//  iBotApp
//
//  Created by Chris Laan on 9/8/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "AutonomyViewController.h"
#import "RobotModel.h"


@implementation AutonomyViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	
	[[RobotModel sharedRobot] initLocalRobot];
	
	//[[RobotModel sharedRobot] addObserver:self forKeyPath:@"isConnectedToRemoteController" options:(NSKeyValueObservingOptionNew) context:NULL];
	[[RobotModel sharedRobot] addObserver:self forKeyPath:@"isConnectedToHardware" options:(NSKeyValueObservingOptionNew) context:NULL];
	//[[RobotModel sharedRobot] addObserver:self forKeyPath:@"isConnectedToServer" options:(NSKeyValueObservingOptionNew) context:NULL];
	
	[self updateStatusImages];
	
	runTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/10.0) target:self selector:@selector(runLoop) userInfo:nil repeats:YES];
	
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	
	NSLog(@"Key changed! %@ " , keyPath );
    
	if ([keyPath isEqual:@"isConnectedToRemoteController"] || [keyPath isEqual:@"isConnectedToHardware"] || [keyPath isEqual:@"isConnectedToServer"] ) {
		
		
		[self updateStatusImages];
		
		
	}
	
	
}

-(void) viewWillAppear:(BOOL)animated {
	
	
	
}

-(void) runLoop {
	
	static int state = 0;
	// 0 = explore, 1 = turnaround, 
	static float turnClock = 0.0;
	static float backupClock = 0.0;
	
	if ( [RobotModel sharedRobot].isConnectedToHardware  ) {
		

		float _dL = [RobotModel sharedRobot].distanceSensorL;
		float _dR = [RobotModel sharedRobot].distanceSensorR;
		
		dR = dR - (dR - _dR)*0.3;
		dL = dL - (dL - _dL)*0.3;
		
		float mR, mL;
		mR = mL = 0.0;
		
		if ( state == 0 ) {
			
			if ( dL < 60 && dR < 60 ) {
				
				state = 1;
				turnClock = 0;
				
			} else if ( dL > 220 && dR > 220 ) {
				
				mL = mR = 0.25;
				
			} else if ( dL < 100 && dR > 100 ) {
				
				mL = 0.2;
				mR = 0.0;
				
			} else if ( dR < 100 && dL > 100 ) {
				
				mL = 0.0;
				mR = 0.2;
				
			}
		
		} else if ( state == 1 ) {
		
			mR = -0.2;
			mL = 0.2;
			
			turnClock++;
			
			if ( turnClock > 24 ) {
				state = 0;
				turnClock=0;
			}
			
		} else if ( state == 2 ) {
			
			backupClock ++;
			mR = mL = -0.2;
			
			if ( backupClock >10 ) {
				turnClock = 0;
				state = 1;
			}
			
		}
		
		label.text = [NSString stringWithFormat:@"state: %i\ndL:%3.2f\ndR:%3.2ft:%2.2f" , state, dL, dR , turnClock ];
		
		[RobotModel sharedRobot].motorSpeedLeft = mL;
		[RobotModel sharedRobot].motorSpeedRight = mR;
		
			
	}
	
	
}

-(void) updateStatusImages {
	
	
	cableStatusImage.image = ([RobotModel sharedRobot].isConnectedToHardware) ? ([UIImage imageNamed:@"GreenLight.png"]) : ([UIImage imageNamed:@"RedLight.png"]);
	
	
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
