//
//  ControllerModel.m
//  iBotApp
//
//  Created by Chris Laan on 9/2/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "RemoteRobotModel.h"

#import "SimpleUDPSocket.h"

#import "RobotObject.h"



@interface RemoteRobotModel()

-(void) sendHeartbeatIfNeeded;
-(void) connectToRemoteServer;
-(void) sendRawMotorSpeedToRemoteRobot;
-(void) sendMotorSpeedToRemoteRobot;
@end


@implementation RemoteRobotModel


@synthesize isConnectedToRemoteRobot, isConnectedToServer, delegate;
//@synthesize isConnectedToHardware;
@synthesize motorSpeedRight, motorSpeedLeft;
@synthesize serverPingTime, robotPingTime;

SINGLETON_IMPLEMENTATION(RemoteRobotModel , sharedRemoteRobot)

#pragma mark -

-(void) initRemoteRobot {

	
	
	runTimer = [NSTimer scheduledTimerWithTimeInterval:(ROBOT_RUN_LOOP_INTERVAL) target:self selector:@selector(runLoop) userInfo:nil repeats:YES];
	
	motorSpeedLeft = 0.0;
	motorSpeedRight = 0.0;
	
	//isConnectedToHardware = NO;
	self.isConnectedToServer = NO;
	self.isConnectedToRemoteRobot = NO;
	
	[self connectToRemoteServer];
	
}


-(void) runLoop {
	
	
	[self sendHeartbeatIfNeeded];
	
}

#pragma mark -
#pragma mark Fake Robot Interface 


-(void) setMotorSpeedLeft:(float)ml {
	motorSpeedLeft = ml;
	[self sendMotorSpeedToRemoteRobot];
}

-(void) setMotorSpeedRight:(float)mr {
	motorSpeedRight = mr;
	[self sendMotorSpeedToRemoteRobot];
}

-(void) setMotorSpeeds:(float)m1 :(float)m2 {
	
	motorSpeedLeft = m1;
	motorSpeedRight = m2;
	
	[self sendMotorSpeedToRemoteRobot];
	
}

-(void) setMotorSpeeds:(float)m1 :(float)m2 duration:(float)secs {
	
	[self setMotorSpeeds:m1 :m2];
	
}

-(void) stopMotors {
	
	[self setMotorSpeeds:0.0 :0.0];
	
}


#pragma mark -
#pragma mark SimpleUDPSocket

-(void) connectToRemoteServer {
	
	//port = REMOTE_SERVER_PORT;
	//serverIp = REMOTE_SERVER_IP;
	
	mediaSocket = [[SimpleUDPSocket alloc] initWithServerIp:REMOTE_SERVER_IP andPort:REMOTE_SERVER_MEDIA_PORT ];
	mediaSocket.delegate = self;
	[mediaSocket openSocket];
	
	
	controlSocket = [[SimpleUDPSocket alloc] initWithServerIp:REMOTE_SERVER_IP andPort:REMOTE_SERVER_PORT ];
	controlSocket.delegate = self;
	[controlSocket openSocket];
	
	
	
}



-(void) simpleSocket:(SimpleUDPSocket*)_sock dataRecieved:(NSData*) data {
	
	if ( _sock == mediaSocket ) {
		
		NSLog(@"Contr: got media data ");
		[self gotMediaSocketData:data];
		
	} else if ( _sock == controlSocket ) {
		
		[self gotControlSocketData:data];
		NSLog(@"Contr: got control data ");
		
	} else {
		NSLog(@"no socket? ");
	}	
	
}

-(void) gotMediaSocketData:(NSData*)data {
	
	char * bytes = (char*)[data bytes];
	
	// can move this into super and include all above functions...
	NSValue * val = [NSValue valueWithBytes:&bytes[0] objCType:@encode(UInt8)];
	
	NSArray * subs = [subscribers objectForKey:val];
	
	if ( subs && [subs count] > 0 ) {
		for (id <RobotSubscriber> obj in subs) {
			[obj receivedDataFromNetwork:data withCode:val];
		}	
	}
	
	
}

-(void) gotControlSocketData:(NSData*)data {

	char * bytes = (char*)[data bytes];
	
	if ( bytes[0] == ROBOT_HEARTBEAT_PACKET_START_BYTE ) {
		
		
		RobotHeartBeat rHeart;
		
		memcpy(&rHeart , bytes, sizeof(RobotHeartBeat));
		
		lastRobotSeq = rHeart.sequence;
		lastRobotHeartbeatTime = [NSDate timeIntervalSinceReferenceDate];
		
		if ( !self.isConnectedToRemoteRobot ) {
			//statusImage.image = [UIImage imageNamed:@"GreenLight.png"];
			self.isConnectedToRemoteRobot = YES;
		}
		
	} else if ( bytes[0] == CONTROLLER_HEARTBEAT_PACKET_START_BYTE ) {
		
		ControllerHeartBeat cHeart;
		
		memcpy(&cHeart , bytes, sizeof(ControllerHeartBeat));
		
		self.serverPingTime = ([NSDate timeIntervalSinceReferenceDate] - cHeart.timestamp );
		NSLog(@"SERVER ping: %f" , serverPingTime);
		
		if ( !self.isConnectedToServer ) {
			self.isConnectedToServer = YES;
		}
		
	} else if ( bytes[0] == CONTROLLER_HEARTBEAT_REPLY_PACKET_START_BYTE ) {
		
		ControllerHeartBeat cHeart;
		
		memcpy(&cHeart , bytes, sizeof(ControllerHeartBeat));
		
		self.robotPingTime = ([NSDate timeIntervalSinceReferenceDate] - cHeart.timestamp );
		NSLog(@"ROBOT ping: %f" , robotPingTime);
		
		//if ( !self.isConnectedToServer ) {
		//	self.isConnectedToServer = YES;
		//}
		
	} else {
		
		// can move this into super and include all above functions...
		NSValue * val = [NSValue valueWithBytes:&bytes[0] objCType:@encode(UInt8)];
		
		NSArray * subs = [subscribers objectForKey:val];
		
		if ( subs && [subs count] > 0 ) {
			for (id <RobotSubscriber> obj in subs) {
				[obj receivedDataFromNetwork:data withCode:val];
			}	
		}
		
	}
	
}

#pragma mark -
#pragma mark Outgoing to server / Robot 


-(void) sendMotorSpeedToRemoteRobot {
	
	float mLThrust, mRThrust;
	
	mLThrust = fmin(0.99, motorSpeedLeft);
	mLThrust = fmax(-0.99, mLThrust);
	
	mRThrust = fmin(0.99, motorSpeedRight);
	mRThrust = fmax(-0.99, mRThrust);
	
	float m1s = 127.0 + (mLThrust * 127.0);
	float m2s = 127.0 + (mRThrust * 127.0);
	
	m1s = fmin(fmax(0.0, round(m1s)), 255.0 );
	m2s = fmin(fmax(0.0, round(m2s)), 255.0 );
	
	rawMotorSpeedL = (UInt8)m1s;
	rawMotorSpeedR = (UInt8)m2s;
	
	
	[self sendRawMotorSpeedToRemoteRobot];
	
}

-(void) sendRawMotorSpeedToRemoteRobot {
	
	if ( controlSocket && self.isConnectedToRemoteRobot ) {
		
		if ( (lastSentRawMotorSpeedL == rawMotorSpeedL) && (lastSentRawMotorSpeedR == rawMotorSpeedR) ) {
			return;
		}
		
		RobotPacket r_packet;
		
		r_packet.startByte = ROBOT_PACKET_START_BYTE;
		
		r_packet.motor1Speed = rawMotorSpeedL;
		r_packet.motor2Speed = rawMotorSpeedR;
		
		NSData * data = [NSData dataWithBytes:&r_packet length:sizeof(RobotPacket)];
		
		[controlSocket sendData:data];
		
		lastSentRawMotorSpeedL = rawMotorSpeedL;
		lastSentRawMotorSpeedR = rawMotorSpeedR;
		
		
	}
	
}


-(void) sendHeartbeatIfNeeded {
	
	NSTimeInterval ts = [NSDate timeIntervalSinceReferenceDate];
	
	if ( ((ts - lastRobotHeartbeatTime) > HEARTBEAT_INTERVAL ) && isConnectedToRemoteRobot ) {
		
		//statusImage.image = [UIImage imageNamed:@"RedLight.png"];
		self.isConnectedToRemoteRobot = NO;
		
	}
	
	if ( (ts-lastSentHeartbeatTime) > HEARTBEAT_INTERVAL/2.0 ) {
		
		ControllerHeartBeat c_packet;
		
		c_packet.startByte = CONTROLLER_HEARTBEAT_PACKET_START_BYTE;
		c_packet.sequence = myHeartbeatSeq++;
		c_packet.timestamp = [NSDate timeIntervalSinceReferenceDate];
		NSData * data = [NSData dataWithBytes:&c_packet length:sizeof(ControllerHeartBeat)];
		
		[controlSocket sendData:data];
		
		[mediaSocket sendData:data];
		
		lastSentHeartbeatTime = ts;
		
	}
	
}

-(void) sendMediaDataToRobot:(NSData*)data {
	
	
	if ( mediaSocket && self.isConnectedToRemoteRobot ) {
		[mediaSocket sendData:data];
	}
	
	
}

-(void) sendDataToRobot:(NSData*)data {
	
	
	if ( controlSocket && self.isConnectedToRemoteRobot ) {
		[controlSocket sendData:data];
	}
	
	
}



- (void) dealloc
{
	[runTimer invalidate];
	// [simpleSocket disconnect]; // release
	[super dealloc];
}






@end
