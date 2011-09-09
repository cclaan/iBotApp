//
//  RobotAction.h
//  iBotApp
//
//  Created by Chris Laan on 9/2/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

// massive hack here.. but we get tons of animatable stuff..

@interface RobotAction : CALayer {
	
	float motorSpeed;
	
}

@property (nonatomic, readwrite) float motorSpeed;

@end
