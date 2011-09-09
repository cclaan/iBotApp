//
//  RobotObject.m
//  iBotApp
//
//  Created by Chris Laan on 9/6/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "RobotObject.h"


@implementation RobotObject


- (id) init
{
	self = [super init];
	if (self != nil) {
		
		subscribers = [[NSMutableDictionary alloc] init];
		
		//NSLog(@"init Robot Object");
		
	}
	return self;
}

-(void) addSubscriber:(id)obj forCode:(NSValue*)val {
	
	if ( ![subscribers objectForKey:val] ) {
		
		NSMutableArray * arr = [[NSMutableArray alloc] init];
		[arr addObject:obj];
		[subscribers setObject:arr forKey:val];
		
	} else {
		
		NSMutableArray * subs = [subscribers objectForKey:val];
	
		if ( ![subs containsObject:obj] ) {
			[subs addObject:obj];
		}
		
	}
	
}


@end
