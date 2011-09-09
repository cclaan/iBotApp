//
//  LLOrientationDetector.h
//  TimeLapse
//
//  Created by Chris Laan on 4/18/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreMotion/CoreMotion.h>
#import "LLOrientationVector.h"


@class LLOrientationDetector;

@protocol LLOrientationDetectorDelegate

-(void) deviceOrientationDidChange:(LLOrientationDetector*)detector;
-(void) interfaceOrientationDidChange:(LLOrientationDetector*)detector;

@end


@interface LLOrientationDetector : NSObject {
	
	id delegate;
	UIDeviceOrientation deviceOrientation;
	UIInterfaceOrientation interfaceOrientation;
	
	//CMMotionManager * motionManager;
	LLOrientationVector * gravityVector;
	NSMutableArray * orientationVectors;
	
	
}

@property (nonatomic, assign) id delegate;
@property UIDeviceOrientation deviceOrientation;
@property UIInterfaceOrientation interfaceOrientation;

-(void) startReceivingUpdates;
-(void) stopReceivingUpdates;

+(UIDeviceOrientation) deviceOrientation;
+(UIInterfaceOrientation) interfaceOrientation;

@end
