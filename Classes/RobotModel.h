//
//  RobotModel.h
//  RobotBrain
//
//  Created by Chris Laan on 8/31/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RobotObject.h"

#import "SynthesizeSingleton.h"
#import "RobotConstants.h"

#import "RscMgr.h"

//#import "SimpleUDPSocket.h"

#import <CoreMotion/CoreMotion.h>



@interface RobotModel : RobotObject <RscMgrDelegate> {
	
	BOOL isConnectedToHardware;
	BOOL isConnectedToServer;	
	BOOL isConnectedToRemoteController;	
	
	// red park cable
	RscMgr *manager;
    UInt8 rxBuffer[BUFFER_LEN];
	UInt8 txBuffer[BUFFER_LEN];
	int msgIndex;
	BOOL readingMessage;
	
	SensorPacket currentState;
	
	float distanceSensorL, distanceSensorR;
	
	//SimpleUDPSocket * simpleSocket;
	
	//int     port; 
	//NSString * serverIp;
	
	NSTimeInterval lastControllerHeartbeatTime;
	UInt64 lastControllerSeq;
	
	NSTimeInterval lastSentHeartbeatTime;
	UInt64 myHeartbeatSeq;
	
	//BOOL controllerConnected;
	
	float motorSpeedLeft, motorSpeedRight;
	
	NSTimer * runTimer;
	
	//// local
	UInt8 rawMotorSpeedL,rawMotorSpeedR;
	UInt8 lastSentRawMotorSpeedL;
	UInt8 lastSentRawMotorSpeedR;
	
}

SINGLETON_INTERFACE(RobotModel , sharedRobot)


@property (nonatomic, assign) id delegate;

@property (readwrite) BOOL isConnectedToHardware;
@property (readwrite) BOOL isConnectedToServer;
@property (readwrite) BOOL isConnectedToRemoteController;

@property (readwrite) NSTimeInterval serverPingTime;

@property (readwrite) float motorSpeedLeft;
@property (readwrite) float motorSpeedRight;

@property (readwrite) float distanceSensorL;
@property (readwrite) float distanceSensorR;


-(void) initLocalRobot;

-(void) setMotorSpeeds:(float)m1 :(float)m2;

-(void) setMotorSpeeds:(float)m1 :(float)m2 duration:(float)secs;

-(void) sendDataToController:(NSData*)data;
-(void) sendMediaDataToController:(NSData*)data;

@end
