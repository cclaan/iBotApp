//
//  SimpleUDPSocket.m
//  UDPRobotTesting
//
//  Created by Chris Laan on 8/29/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "SimpleUDPSocket.h"


@implementation SimpleUDPSocket

@synthesize port, serverIp, delegate;

- (id) initWithServerIp:(NSString*)_ip andPort:(int)_port
{
	self = [super init];
	if (self != nil) {
		
		self.serverIp = _ip;
		self.port = _port;
		
	}
	return self;
}


-(void) openSocket {
	
	//port = 8000;
	host = [self.serverIp cString];
	
	NSLog(@"opening socket");
	
	//clientSocket = socket(PF_INET, SOCK_DGRAM, 0);
	clientSocket = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
	
	if (clientSocket < 0) {
		fprintf(stderr, "socket creation failed\n");
		exit(1);
	}
	
	/* determine the server's address */
	
	memset((char *)&sad,0,sizeof(sad)); /* clear sockaddr structure */
	sad.sin_family = AF_INET;           /* set family to Internet     */
	sad.sin_port = htons((u_short)port);
	ptrh = gethostbyname(host); /* Convert host name to equivalent IP address and copy to sad. */
	
	if ( ((char *)ptrh) == NULL ) {
		fprintf(stderr,"invalid host: %s\n", host);
		exit(1);
	}
	
	memcpy(&sad.sin_addr, ptrh->h_addr, ptrh->h_length);
	
	[self performSelectorInBackground:@selector(listeningLoop) withObject:nil];
	
	
}


-(void) closeSocket {
	
	close(clientSocket);
	
}

#pragma mark -

-(void) sendString:(NSString*)str {
	
	NSData * data = [NSData dataWithBytes:[str UTF8String] length:[str length]];

	[self sendData:data];
	
}

-(void) sendData:(NSData*)data {
	
	[data retain];
	
	int n;
	
	if ( clientSocket < 0 ) {
		NSLog(@"no socket?");
	}
	
	//char Sentence[] = "motor"; 
	
	//startTime = [NSDate timeIntervalSinceReferenceDate];
	
	n = sendto(clientSocket, [data bytes], [data length], 0 , (struct sockaddr *) &sad, sizeof(struct sockaddr));
	
	[self logText:[NSString stringWithFormat:@"Client sent %d bytes to server " , n ]];
	
	[data release];
	
	
}

-(void) sendBytes:(const void*)_bytes withLength:(int)_len {
	
	int n;
	
	if ( clientSocket < 0 ) {
		NSLog(@"no socket?");
	}
	
	n = sendto(clientSocket, _bytes, _len, 0 , (struct sockaddr *) &sad, sizeof(struct sockaddr));
	
	[self logText:[NSString stringWithFormat:@"Client sent %d bytes to server " , n ]];
	
}

#pragma mark -


-(void) listeningLoop {
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	if ( clientSocket <= 0 ) {
		NSLog(@"seems socket not there");
		return;
	}
	
	[self logText:@"starting to listen now"];
	
	char    buff[128];
	int     n;
	
	while (1) {
		
		rxPointer = 0;
		
		NSMutableData * data = [[NSMutableData alloc] init];
		
		//n = read(clientSocket, rxBuffer, sizeof(buff));
		n = read(clientSocket, rxBuffer, RX_BUFFER_SIZE);
		
		rxPointer+=n;
		
		//if ( n > 0 ) {
		//[data appendBytes:rxBuffer length:n];
		//[NSThr
		
		
		while(n > 0){
			
			[data appendBytes:rxBuffer length:n];
			
			//NSLog(@"got data: %i , len: %i " , n , [data length] );
			
			// fix for overflow here..
			/*char * _dater = [data bytes];
			*/
			
			if ( n >= 5 ) {
				// n >= 5
				//NSLog(@"data limit ?");
				break;
			}
			
			
			n = read(clientSocket, rxBuffer, RX_BUFFER_SIZE);
			//NSLog(@"just read: %i " , n ) ;
			
			rxPointer+=n;
			
			
		}
		
		
		
		if ( delegate && [data length] > 0 ) {
			
			//NSLog(@"del YA ");
			
			//[delegate dataRecieved:data];
			//[delegate performSelectorOnMainThread:@selector(dataRecieved:) withObject:data waitUntilDone:YES];
			[self performSelectorOnMainThread:@selector(dataRecieved:) withObject:data waitUntilDone:YES];
			
		}
		
		[data release];
		
		//[self logText:[NSString stringWithFormat:@"Rec'd: %s" , modifiedSentence ]];
		
		
		
	}
	
	[pool release];
	
	
}

-(void) dataRecieved:(NSData*)data {
	
	[delegate simpleSocket:self dataRecieved:data];
	
}

-(void) logText:(NSString*) txt {
	
	NSLog(txt);
	
}





@end
