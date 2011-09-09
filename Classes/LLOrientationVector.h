//
//  LLOrientationVector.h
//  TimeLapse
//
//  Created by Chris Laan on 4/18/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LLOrientationVector : NSObject {
	
	float x;
	float y;
	float z;
	
	float distance;
	
	UIDeviceOrientation orientation;
	
	// makes the face up and face down require closer distances to match up
	float importance;
	
	NSString * name;
}

@property float x;
@property float y;
@property float z;
@property float importance;

@property UIDeviceOrientation orientation;
@property (nonatomic, retain) NSString * name;
@property float distance;

-(float) getDistanceToVector:(LLOrientationVector*)vec;

+(NSMutableArray*) getDeviceVectors;

@end
