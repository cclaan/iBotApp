//
//  RobotObject.h
//  iBotApp
//
//  Created by Chris Laan on 9/6/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleUDPSocket.h"


@protocol RobotSubscriber

-(void) receivedDataFromNetwork:(NSData*)data withCode:(NSValue*)_code;

@end

@interface RobotObject : NSObject {
	
@protected
	
	//int peepie;
	
	SimpleUDPSocket * mediaSocket;
	
	SimpleUDPSocket * controlSocket;
	
	NSMutableDictionary * subscribers;
	
	
}


-(void) addSubscriber:(id)obj forCode:(NSValue*)val;

//-(NSData*) processDataPacket:
 

@end
