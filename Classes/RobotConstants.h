/*
 *  RobotConstants.h
 *  RobotBrain
 *
 *  Created by Chris Laan on 8/29/11.
 *  Copyright 2011 Laan Labs. All rights reserved.
 *
 */

#define REMOTE_SERVER_PORT 8101
#define REMOTE_SERVER_MEDIA_PORT 8100
#define REMOTE_SERVER_IP @"204.232.206.169"

#define HEARTBEAT_INTERVAL 4.0

#define ROBOT_PACKET_START_BYTE 101
#define ROBOT_STRING_PACKET_START_BYTE 102
#define ROBOT_IMAGE_PACKET_START_BYTE 104

#define ROBOT_HEARTBEAT_PACKET_START_BYTE 105
#define CONTROLLER_HEARTBEAT_PACKET_START_BYTE 106
#define CONTROLLER_HEARTBEAT_REPLY_PACKET_START_BYTE 107

#define ROBOT_SOUND_PACKET_START_BYTE 108

#define ROBOT_DATA_PACKET_START_BYTE 109

#define MOTOR_COMMAND 90
#define SOUND_COMMAND 95

#define IMAGE_COMMAND 98

#define ROBOT_RUN_LOOP_INTERVAL (1.0/30.0)

//////

#define BUFFER_LEN 512

#define MSG_LEN 5
#define START_BYTE 69

#define MOTOR_1_CODE 11
#define MOTOR_2_CODE 22

typedef struct SensorPacket {
	
	UInt8 startByte;
	
	UInt8 analog1;
	UInt8 analog2;
	UInt8 analog3;
	UInt8 analog4;
	
	// UInt8 checkSum;
	
} SensorPacket;


typedef struct RobotPacket {
	
	UInt8 startByte;
	UInt8 commandType;
	
	UInt8 motor1Speed;
	UInt8 motor2Speed;
	
	UInt8 checkSum;
	
} RobotPacket;

typedef struct RobotStringPacket {
	
	UInt8 startByte;
	UInt8 commandType;
	
	char message[64];
	UInt8 msgLen;
	
	UInt8 checkSum;
	
} RobotStringPacket;


/// image..
typedef struct RobotImageHeaderPacket {
	
	UInt8 startByte;
	UInt8 commandType;
	UInt8 frameNumber;
	UInt8 checkSum;
	int msgLen;	

	
} RobotImageHeaderPacket;

typedef struct RobotImageFooterPacket {
	
	UInt8 startByte;
	UInt8 commandType;
	UInt8 frameNumber;
	UInt8 checkSum;
	int msgLen;	
	
} RobotImageFooterPacket;


// sound...
typedef struct RobotDataHeaderPacket {
	
	UInt8 startByte;
	UInt8 commandType;
	UInt8 frameNumber;
	UInt8 checkSum;
	int msgLen;	
	
	
} RobotDataHeaderPacket;

typedef struct RobotDataFooterPacket {
	
	UInt8 startByte;
	UInt8 commandType;
	UInt8 frameNumber;
	UInt8 checkSum;
	int msgLen;	
	
} RobotDataFooterPacket;

///

typedef struct RobotHeartBeat {
	
	UInt8 startByte;
	UInt8 commandType;
	double timestamp;
	UInt64 sequence;
	
} RobotHeartBeat;


typedef struct ControllerHeartBeat {
	
	UInt8 startByte;
	UInt8 commandType;
	double timestamp;
	UInt64 sequence;
	
} ControllerHeartBeat;




