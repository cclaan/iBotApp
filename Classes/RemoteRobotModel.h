//
//  ControllerModel.h
//  iBotApp
//
//  Created by Chris Laan on 9/2/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RobotObject.h"

#import "SynthesizeSingleton.h"

#import "RobotConstants.h"

//#import "SimpleUDPSocket.h"



@protocol RemoteRobotDelegate

-(void) receivedDataFromRobot:(NSData*)data;

@end



@interface RemoteRobotModel : RobotObject {
	
	//BOOL isConnectedToHardware;
	BOOL isConnectedToServer;	
	BOOL isConnectedToRemoteRobot;	
		
	float distanceSensorL, distanceSensorR;
	
	//SimpleUDPSocket * simpleSocket;
	
	//int     port; 
	//NSString * serverIp;
	
	
	
	NSTimeInterval lastRobotHeartbeatTime;
	UInt64 lastRobotSeq;
	
	NSTimeInterval lastSentHeartbeatTime;
	UInt64 myHeartbeatSeq;
	
	NSTimer * runTimer;
	
	
	float motorSpeedLeft, motorSpeedRight;
	
	//// local
	UInt8 rawMotorSpeedL,rawMotorSpeedR;
	UInt8 lastSentRawMotorSpeedL;
	UInt8 lastSentRawMotorSpeedR;
	
}

SINGLETON_INTERFACE(RemoteRobotModel , sharedRemoteRobot)

@property (readwrite) BOOL isConnectedToRemoteRobot;

// not really used yet..
@property (readwrite) BOOL isConnectedToServer;
//@property (readwrite) BOOL isConnectedToHardware;


@property (readwrite) float motorSpeedLeft;
@property (readwrite) float motorSpeedRight;

@property (readwrite) NSTimeInterval serverPingTime;
@property (readwrite) NSTimeInterval robotPingTime;

@property (nonatomic, assign) id delegate;

-(void) initRemoteRobot;

-(void) setMotorSpeeds:(float)m1 :(float)m2;

-(void) setMotorSpeeds:(float)m1 :(float)m2 duration:(float)secs;

-(void) stopMotors;

-(void) sendDataToRobot:(NSData*)data;
-(void) sendMediaDataToRobot:(NSData*)data;


@end
