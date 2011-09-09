//
//  RobotAction.m
//  iBotApp
//
//  Created by Chris Laan on 9/2/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "RobotAction.h"


@implementation RobotAction

@synthesize motorSpeed;


-(void) setMotorSpeed:(float) ms {
	
	NSLog(@"set motor speed: %f " , ms );
	motorSpeed = ms;
	
	
}	



+ (BOOL)needsDisplayForKey:(NSString*)key {
    if ([key isEqualToString:@"motorSpeed"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}

@end
