//
//  LLOrientationDetector.m
//  TimeLapse
//
//  Created by Chris Laan on 4/18/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "LLOrientationDetector.h"

// TODO: rewrite this to be more singleton like

@implementation LLOrientationDetector


@synthesize delegate, deviceOrientation, interfaceOrientation;

static UIDeviceOrientation _deviceOrientation = -1;
static UIInterfaceOrientation _interfaceOrientation = -1;

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		_deviceOrientation = -1;
		_interfaceOrientation = -1;
		self.deviceOrientation = -1;
		
	}
	return self;
}


-(void) startReceivingUpdates {
	
	[self startAccelerometer];
	
}

-(void) stopReceivingUpdates {
	
	[self stopAccelerometer];
	
}


-(void) startAccelerometer {
	
	[[UIAccelerometer sharedAccelerometer] setDelegate: self ];
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:( 1.0f / 5.0f )];
	
	orientationVectors = [[LLOrientationVector getDeviceVectors] retain];
	
	
}

-(void) stopAccelerometer {
	
	[[UIAccelerometer sharedAccelerometer] setDelegate: nil ];
	//[[UIAccelerometer sharedAccelerometer] setUpdateInterval:0];
	
	
}

#define kFilteringFactor			0.6

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	
	// could maybe use some sort of delay to prevent flipping back and forth between different orientations...
	
	if ( !gravityVector ) {
		gravityVector = [[LLOrientationVector alloc] init];
	}
	
	//Use a basic low-pass filter to only keep the gravity in the accelerometer values
	gravityVector.x = acceleration.x * kFilteringFactor + gravityVector.x * (1.0 - kFilteringFactor);
	gravityVector.y = acceleration.y * kFilteringFactor + gravityVector.y * (1.0 - kFilteringFactor);
	gravityVector.z = acceleration.z * kFilteringFactor + gravityVector.z * (1.0 - kFilteringFactor);
	
	float minDist = 10000;
	LLOrientationVector * bestVec = nil;
	
	for (LLOrientationVector * vec in orientationVectors) {
		
		float dist = [vec getDistanceToVector:gravityVector];
		
		if ( dist < minDist ) {
			minDist = dist;
			bestVec = vec;
		}
		
	}
	
	if ( self.deviceOrientation != bestVec.orientation ) {
		
		[self checkInterfaceOrientation: bestVec.orientation];
		
		self.deviceOrientation = bestVec.orientation;
		_deviceOrientation = self.deviceOrientation;
		
		if ( self.delegate ) {
			[self.delegate deviceOrientationDidChange:self];
		}
		
		
		
	}
	
	//NSLog(@"best vec: %@ " ,  bestVec.name );
	
	
	
}

-(void) checkInterfaceOrientation:(UIDeviceOrientation) newOrientation {
	
	
	UIInterfaceOrientation oldOrientation = self.deviceOrientation;
	
	if ( !UIDeviceOrientationIsValidInterfaceOrientation(newOrientation) ) {
		
		if ( UIDeviceOrientationIsValidInterfaceOrientation(oldOrientation) ) {
			self.interfaceOrientation = oldOrientation;
		} else {
			self.interfaceOrientation = UIInterfaceOrientationPortrait;
		}
		
	} else {
		self.interfaceOrientation = newOrientation;
	}
	
	_interfaceOrientation = newOrientation;
	
	if ( self.interfaceOrientation != oldOrientation ) {
		
		if ( self.delegate ) {
			[self.delegate interfaceOrientationDidChange:self];
		}
		
	}
	
	
	
}

/*
-(void) startMotionManager {
	
	if (motionManager == nil) {
		motionManager = [[CMMotionManager alloc] init];
	}
	
	NSOperationQueue * cmq = [[NSOperationQueue alloc] init];
	
	//typedef void (^CMGyroHandler)(CMGyroData *gyroData, NSError *error);
	//typedef void (^CMDeviceMotionHandler)(CMDeviceMotion *motion, NSError *error);
	
	motionManager.deviceMotionUpdateInterval = (1.0 / 3.0 );
	
	[motionManager startDeviceMotionUpdatesToQueue:cmq withHandler:^(CMDeviceMotion *motion, NSError *error) {
		
		
	}];
	
}
*/
+(UIDeviceOrientation) deviceOrientation {
	return _deviceOrientation;
}	

+(UIInterfaceOrientation) interfaceOrientation {
	return _interfaceOrientation;
}	


@end
