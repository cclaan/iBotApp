//
//  LLOrientationVector.m
//  TimeLapse
//
//  Created by Chris Laan on 4/18/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "LLOrientationVector.h"


@implementation LLOrientationVector

@synthesize x,y,z, orientation, name, distance, importance;


- (id) init
{
	self = [super init];
	if (self != nil) {
		
		importance = 1.0;
		
	}
	return self;
}


-(float) getDistanceToVector:(LLOrientationVector*)vec {
	
	
	float mag = sqrt( (self.x - vec.x)*(self.x - vec.x) + (self.y - vec.y)*(self.y - vec.y) + (self.z - vec.z)*(self.z - vec.z) );
	mag = (1.0/self.importance)*(1.0/vec.importance)*mag;
	
	self.distance = mag;
	
	return mag;
	
}	

+(NSMutableArray*) getDeviceVectors {
	
	NSMutableArray * arr = [NSMutableArray array];
	
	LLOrientationVector * vec = nil;
	
	vec = [[[LLOrientationVector alloc] init] autorelease];
	vec.name = @"Portrait";
	vec.orientation = UIDeviceOrientationPortrait;
	vec.x = 0.0;
	vec.y = -0.9;
	vec.z = 0.0;
	[arr addObject:vec];
	
	vec = [[[LLOrientationVector alloc] init] autorelease];
	vec.name = @"Portrait Upside Down";
	vec.orientation = UIDeviceOrientationPortraitUpsideDown;
	vec.x = 0.0;
	vec.y = 0.9;
	vec.z = 0.0;
	[arr addObject:vec];
	
	vec = [[[LLOrientationVector alloc] init] autorelease];
	vec.name = @"Landscape Left";
	vec.orientation = UIDeviceOrientationLandscapeLeft;
	vec.x = -0.9;
	vec.y = 0.0;
	vec.z = 0.0;
	[arr addObject:vec];
	
	vec = [[[LLOrientationVector alloc] init] autorelease];
	vec.name = @"Landscape Right";
	vec.orientation = UIDeviceOrientationLandscapeRight;
	vec.x = 0.9;
	vec.y = 0.0;
	vec.z = 0.0;
	[arr addObject:vec];
	
	vec = [[[LLOrientationVector alloc] init] autorelease];
	vec.name = @"Face Up";
	vec.orientation = UIDeviceOrientationFaceUp;
	vec.x = 0.0;
	vec.y = 0.0;
	vec.z = -0.9;
	vec.importance = 0.62;
	[arr addObject:vec];
	
	vec = [[[LLOrientationVector alloc] init] autorelease];
	vec.name = @"Face Down";
	vec.orientation = UIDeviceOrientationFaceDown;
	vec.x = 0.0;
	vec.y = 0.0;
	vec.z = 0.9;
	vec.importance = 0.62;
	[arr addObject:vec];
	
	return arr;
	
}

@end
