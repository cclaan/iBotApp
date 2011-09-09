//
//  RobotModel.m
//  RobotBrain
//
//  Created by Chris Laan on 8/31/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "RobotModel.h"
#import <AVFoundation/AVFoundation.h>
#import "SimpleUDPSocket.h"

@interface RobotModel(privates)

-(void) updateScaledSpeedsFromRawSpeeds;
-(void) sendRawMotorSpeedToHardware;
-(void) sendMotorSpeedToHardware;

-(void) connectToRemoteServer;
-(void) receivedStateFromHardware;
-(void) sendHeartbeatIfNeeded;
-(void) wakeupCable;

@end


@implementation RobotModel


@synthesize isConnectedToRemoteController, isConnectedToHardware, isConnectedToServer, delegate;
@synthesize motorSpeedRight, motorSpeedLeft;
@synthesize serverPingTime;
@synthesize distanceSensorR, distanceSensorL;

SINGLETON_IMPLEMENTATION(RobotModel , sharedRobot)

#pragma mark -

-(void) initLocalRobot {
	
	
	manager = [[RscMgr alloc] init]; 
	[manager setDelegate:self];
	
	msgIndex = 0;
	
	runTimer = [NSTimer scheduledTimerWithTimeInterval:(ROBOT_RUN_LOOP_INTERVAL) target:self selector:@selector(runLoop) userInfo:nil repeats:YES];
	
	[self setMotorSpeeds:0.0 :0.0];
	
	self.isConnectedToHardware = NO;
	self.isConnectedToServer = NO;
	self.isConnectedToRemoteController = NO;
	
	[self connectToRemoteServer];
	
	[self wakeupCable];
	
	
}


-(void) runLoop {
		
	[self sendRawMotorSpeedToHardware];
	
	[self sendHeartbeatIfNeeded];
	
	
}	


#pragma mark -
#pragma mark Outgoing to hardware

-(void) setMotorSpeedLeft:(float)ml {
	motorSpeedLeft = ml;
	[self sendMotorSpeedToHardware];
}

-(void) setMotorSpeedRight:(float)mr {
	motorSpeedRight = mr;
	[self sendMotorSpeedToHardware];
}

-(void) setMotorSpeeds:(float)m1 :(float)m2 {
	
	motorSpeedLeft = m1;
	motorSpeedRight = m2;
	
	[self sendMotorSpeedToHardware];
	
}

-(void) setMotorSpeeds:(float)m1 :(float)m2 duration:(float)secs {
	
	[self setMotorSpeeds:m1 :m2];
	
}

-(void) updateScaledSpeedsFromRawSpeeds {
	motorSpeedLeft = -1.0 + 2.0 * ((float)rawMotorSpeedL) / 255.0;
	motorSpeedRight = -1.0 + 2.0 * ((float)rawMotorSpeedR) / 255.0;
}

-(void) sendRawMotorSpeedToHardware {
	[self sendRawMotorSpeedToHardware:NO];
}

-(void) sendRawMotorSpeedToHardware:(BOOL) force {
	
	if ( !force && !isConnectedToHardware ) return;
	
	if ( !force && (lastSentRawMotorSpeedL == rawMotorSpeedL && lastSentRawMotorSpeedR == rawMotorSpeedR) ) {
		return;
	}
	
	txBuffer[0] = START_BYTE;
    txBuffer[1] = MOTOR_1_CODE;
	txBuffer[2] = rawMotorSpeedL;
	txBuffer[3] = MOTOR_2_CODE;
	txBuffer[4] = -rawMotorSpeedR; // flip since they're facing opposite direction
	
	txBuffer[5] = 0;
	txBuffer[6] = 0;
	txBuffer[7] = 0;
	
	lastSentRawMotorSpeedL = rawMotorSpeedL;
	lastSentRawMotorSpeedR = rawMotorSpeedR;
	
	[manager write:txBuffer Length:8];
	
}

-(void) sendMotorSpeedToHardware {
	
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
	
	
	[self sendRawMotorSpeedToHardware];
	
	
}


-(void) wakeupCable {
	
	// send some junk, since it seems the cable won't connect for like 10 seconds sometimes...
	txBuffer[0] = 1;
    txBuffer[1] = 1;
	txBuffer[2] = 1;
	txBuffer[3] = 0;
	txBuffer[4] = 5;
	txBuffer[5] = 1;
	txBuffer[6] = 4;
	txBuffer[7] = 5;

	[manager write:txBuffer Length:8];
	
}



#pragma mark -
#pragma mark - Red Park Cable

- (void) cableConnected:(NSString *)protocol {
	
	NSLog(@"Cable Connected: %@", protocol);
    
	serialPortConfig portConfig;
	
	[manager getPortConfig:&portConfig];
	
	//NSLog(@"got config.. baud: %i  forward count: %i " , portConfig.baudHi, portConfig.rxForwardCount );
	
	// low timeout for sending data, and max bytes before flush...
	portConfig.rxForwardCount = 8;
	portConfig.rxForwardingTimeout = 8;
	
	[manager setPortConfig:&portConfig RequestStatus:NO];
	
	[manager setBaud:38400];
	[manager open];
	

	self.isConnectedToHardware = YES;
	
	
}

- (void) cableDisconnected {
    
	NSLog(@"Cable disconnected");
 
	self.isConnectedToHardware = NO;
	
}


- (void) portStatusChanged {
   
	NSLog(@"portStatusChanged");
    
}


- (void) readBytesAvailable:(UInt32)numBytes {
	
    int bytesRead = [manager read:rxBuffer Length:numBytes];	
	
	//totalBytes += bytesRead;
	
	//bytesLabel.text = [NSString stringWithFormat:@"%i" , totalBytes];
	
	/*
	 for (int i = 0; i < bytesRead; i++) {
	 textView.text = [NSString stringWithFormat:@"%@ %u" , textView.text , rxBuffer[i] ];
	 }*/
	
	
	/*
	 UInt16 tester = 0;
	 UInt8 lowByte = rxBuffer[1];
	 UInt8 highByte = rxBuffer[2];
	 
	 tester = (highByte << 8) | lowByte;
	 
	 textView.text = [NSString stringWithFormat:@"%@ \n Int: %i" , textView.text , tester ];
	 */
	
	char * pnter = (char*)&currentState;
	
	if ( readingMessage ) {
		
		int numToCopy = MSG_LEN - msgIndex;
		numToCopy = fmin(numToCopy,bytesRead);
		
		memcpy(pnter+msgIndex, rxBuffer, numToCopy);
		msgIndex += numToCopy;
		
		if ( msgIndex >= MSG_LEN ) {
			[self receivedStateFromHardware];
			readingMessage = NO;
			msgIndex = 0;
		}
		
	} else {
		
		for (int i = 0; i < bytesRead; i++) {
			
			if ( rxBuffer[i] == START_BYTE ) {   // start byte
				
				int numToCopy = (bytesRead-i);
				
				if ( numToCopy >= MSG_LEN ) {
					
					memcpy(pnter, rxBuffer+i, MSG_LEN);
					[self receivedStateFromHardware];
					readingMessage = NO;
					msgIndex = 0;
					
				} else {
					
					readingMessage = YES;
					msgIndex = 0;
					
					memcpy(pnter, rxBuffer+i, numToCopy);
					msgIndex += numToCopy;
					
				}
				
			}
			
		}
		
	}
	
}

- (BOOL) rscMessageReceived:(UInt8 *)msg TotalLength:(int)len {
    NSLog(@"rscMessageRecieved:TotalLength:");
    return FALSE;    
}

- (void) didReceivePortConfig {
    NSLog(@"didRecievePortConfig");
}


#pragma mark -

-(void) receivedStateFromHardware {
	
	
	float an1 = currentState.analog1 * 4;
	float volts = an1*0.0048828125;   // value from sensor * (5/1024) - if running 3.3.volts then change 5 to 3.3
	
	float dl = 65*pow(volts, -1.10);          // worked out from graph 65 = theretical distance / (1/Volts)S - luckylarry.co.uk
	
	if ( !isinf(dl) && !isnan(dl) ) {
		distanceSensorL = dl;
	}
	
	float an2 = currentState.analog2 * 4;
	float volts2 = an2*0.0048828125;   // value from sensor * (5/1024) - if running 3.3.volts then change 5 to 3.3
	float dr = 65*pow(volts2, -1.10);          // worked out from graph 65 = theretical distance / (1/Volts)S - luckylarry.co.uk
	
	if ( !isinf(dr) && !isnan(dr) ) {
		distanceSensorR = dr;
	}
	
	
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
	
	if ( bytes[0] == ROBOT_STRING_PACKET_START_BYTE ) {
		
		if ( [data length] != sizeof(RobotStringPacket) ) {
			NSLog(@"Bad packet");
			return;
		}
		
		RobotStringPacket s_packet;
		[data getBytes:&s_packet];
		
		NSString * wav = [NSString stringWithCString:&s_packet.message length:s_packet.msgLen];
		
		AVAudioPlayer * av = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:wav]] error:nil];
		[av play];
		
		
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

-(void) gotControlSocketData:(NSData*)data {
	
	//NSLog(@"Simple UDP got data Len: %i " , [data length] ); 
	
	char * bytes = (char*)[data bytes];
	
	if ( bytes[0] == ROBOT_PACKET_START_BYTE ) {
		
		if ( [data length] != sizeof(RobotPacket) ) {
			NSLog(@"Bad packet");
			return;
		}
		
		RobotPacket r_packet;
		
		[data getBytes:&r_packet];
		
		rawMotorSpeedL = r_packet.motor1Speed;
		rawMotorSpeedR = r_packet.motor2Speed;
		
		[self updateScaledSpeedsFromRawSpeeds];
		[self sendRawMotorSpeedToHardware];
		
	} else if ( bytes[0] == ROBOT_STRING_PACKET_START_BYTE ) {
		
		if ( [data length] != sizeof(RobotStringPacket) ) {
			NSLog(@"Bad packet");
			return;
		}
		
		RobotStringPacket s_packet;
		[data getBytes:&s_packet];
		
		NSString * wav = [NSString stringWithCString:&s_packet.message length:s_packet.msgLen];
		
		AVAudioPlayer * av = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:wav]] error:nil];
		[av play];
		
		
	} else if ( bytes[0] == CONTROLLER_HEARTBEAT_PACKET_START_BYTE ) {
		
		ControllerHeartBeat cHeart;
		
		memcpy(&cHeart , bytes, sizeof(ControllerHeartBeat));
		
		lastControllerSeq = cHeart.sequence;
		lastControllerHeartbeatTime = [NSDate timeIntervalSinceReferenceDate];
		
		if ( !self.isConnectedToRemoteController ) {
			self.isConnectedToRemoteController = YES;
		}
		
		cHeart.startByte = CONTROLLER_HEARTBEAT_REPLY_PACKET_START_BYTE;
		
		// modify and send back to give controller an idea of total time from controller to robot...
		NSData * data = [NSData dataWithBytes:&cHeart length:sizeof(ControllerHeartBeat)];
		[controlSocket sendData:data];
		
		
	} else if ( bytes[0] == ROBOT_HEARTBEAT_PACKET_START_BYTE ) {
		
		// this has bounced back from server to tell us round trip time...
		
		RobotHeartBeat rHeart;
		
		memcpy(&rHeart , bytes, sizeof(RobotHeartBeat));
		
		self.serverPingTime = ([NSDate timeIntervalSinceReferenceDate] - rHeart.timestamp );
		NSLog(@"robot ping: %f" , serverPingTime);
		
		if ( !self.isConnectedToServer ) {
			self.isConnectedToServer = YES;
		}
		
		
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

-(void) sendDataToController:(NSData*)data {
	
	
	if ( controlSocket && self.isConnectedToRemoteController ) {
		[controlSocket sendData:data];
	}
	
	
}

-(void) sendMediaDataToController:(NSData*)data {
	
	
	if ( mediaSocket && self.isConnectedToRemoteController ) {
		[mediaSocket sendData:data];
	}
	
	
}


#pragma mark -
#pragma mark Outgoing to Server 


-(void) sendHeartbeatIfNeeded {
	
	NSTimeInterval ts = [NSDate timeIntervalSinceReferenceDate];
	
	if ( ((ts - lastControllerHeartbeatTime) > HEARTBEAT_INTERVAL) && self.isConnectedToRemoteController ) {
		
		self.isConnectedToRemoteController = NO;
		
	}
	
	if ( (ts-lastSentHeartbeatTime) > HEARTBEAT_INTERVAL/2.0 ) {
		
		RobotHeartBeat r_packet;
		
		r_packet.startByte = ROBOT_HEARTBEAT_PACKET_START_BYTE;
		r_packet.sequence = myHeartbeatSeq++;
		r_packet.timestamp = [NSDate timeIntervalSinceReferenceDate];
		
		NSData * data = [NSData dataWithBytes:&r_packet length:sizeof(RobotHeartBeat)];
		
		[controlSocket sendData:data];
		
		// this will set address for media...
		[mediaSocket sendData:data];
		
		lastSentHeartbeatTime = ts;
		
		// also ping the cable to maybe wake it up..
		//[self wakeupCable];
		[self sendRawMotorSpeedToHardware:YES];
		
	}
	
}


- (void) dealloc
{
	[runTimer invalidate];
	// [simpleSocket disconnect]; // release
	[super dealloc];
}






@end
