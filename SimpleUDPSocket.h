//
//  SimpleUDPSocket.h
//  UDPRobotTesting
//
//  Created by Chris Laan on 8/29/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

// a super simple crappy UDP socket.. most likely has many issues
// just testing out communication for robot

#import <Foundation/Foundation.h>
//#import "common.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

#include <netinet/in.h>
#include <arpa/inet.h>

//#define RX_BUFFER_SIZE 128
#define RX_BUFFER_SIZE 9600 // for the images and what not

@class SimpleUDPSocket;

@protocol SimpleUDPSocketDelegate 

-(void) simpleSocket:(SimpleUDPSocket*)_sock dataRecieved:(NSData*) data;

@end


@interface SimpleUDPSocket : NSObject {
	
	id delegate;
	NSString * serverIp;
	//int port;
	
	
	int     clientSocket;    /* socket descriptor                   */ 
	
	struct  sockaddr_in sad; /* structure to hold an IP address     */
	
	struct  hostent  *ptrh;  /* pointer to a host table entry       */
	
	char    *host;           /* pointer to host name                */
	int     port;            /* protocol port number                */  
	
	
	struct  sockaddr_in cad; /* structure to hold client's address  */
	uint     alen;            /* length of address                   */
	
	int     serverSocket;     /* socket descriptors  */
	
	char rxBuffer[RX_BUFFER_SIZE];
	int rxPointer;
	
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSString * serverIp;
@property (nonatomic, readwrite) int port;

- (id) initWithServerIp:(NSString*)_ip andPort:(int)_port;
-(void) openSocket;
-(void) closeSocket;
-(void) sendData:(NSData*)data;
-(void) sendString:(NSString*)str;


@end
