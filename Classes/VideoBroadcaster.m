//
//  VideoBroadcastController.m
//  RobotBrain
//
//  Created by Chris Laan on 8/30/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "VideoBroadcaster.h"
#import "RobotConstants.h"

//#import "RobotModel.h"

@implementation VideoBroadcaster

@synthesize previewLayer, delegate;



- (id) init
{
	self = [super init];
	if (self != nil) {
		fps = 5;
		
	}
	return self;
}





-(AVCaptureVideoPreviewLayer*) previewLayer {

	if ( cameraCapturer && cameraCapturer.previewLayer ) {
		return cameraCapturer.previewLayer;
	}
	
	
}


#pragma mark photo capture

-(void) initCamera {
	
	cameraCapturer = [[CameraCapturer alloc] init];
	
	//[self.view.layer insertSublayer:cameraCapturer.previewLayer atIndex:1];
	
	//cameraCapturer.previewLayer.frame = CGRectMake(0, 0, 160, 240);
	
	[cameraCapturer beginCapturingCamera];
	
}

-(void) cameraToggle {
	[cameraCapturer cameraToggle];
}

-(void) setFrameRate:(int) _fps {
	
	fps = _fps;
	
	[self startStream];
	
}

-(void) startStream {
	
	[videoTimer invalidate];
	
	videoTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/((float)fps)) target:self selector:@selector(sendFrame) userInfo:nil repeats:YES];
	
}

-(void) sendFrame {
	
	[self performSelectorInBackground:@selector(sendVideoFrame) withObject:nil];
	
}

-(void) sendVideoFrame {
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	
	//if ( ![RobotModel sharedRobot].isConnectedToRemoteController ) return;
	
	
	[cameraCapturer capturePhoto];
	
	while (cameraCapturer.capturedImage == nil ) {
		[NSThread sleepForTimeInterval:0.002];
	}
	
	NSData * imgData = UIImageJPEGRepresentation(cameraCapturer.capturedImage, 0.2);
	[imgData retain];
	
	RobotImageHeaderPacket img_header_packet;
	RobotImageFooterPacket img_footer_packet;
	
	//img_header_packet.checkSum = 33;
	img_header_packet.frameNumber = 69;
	//img_header_packet.timestamp = 456;
	
	img_header_packet.startByte = ROBOT_IMAGE_PACKET_START_BYTE;
	img_footer_packet.startByte = ROBOT_IMAGE_PACKET_START_BYTE;
	
	int len = [imgData length];
	
	//NSLog(@"sending img length: %i " , len );
	
	img_header_packet.msgLen = len;
	img_footer_packet.msgLen = len;
	
	char * imgBytes = [imgData bytes];
	
	char * _fullbytes = malloc(sizeof(RobotImageHeaderPacket) + len + sizeof(RobotImageFooterPacket) );
	
	memcpy(_fullbytes , &img_header_packet, sizeof(RobotImageHeaderPacket));
	memcpy(_fullbytes+sizeof(RobotImageHeaderPacket) , imgBytes, len);
	memcpy(_fullbytes+sizeof(RobotImageHeaderPacket)+len , &img_footer_packet, sizeof(RobotImageFooterPacket));
	
	int totalLen = sizeof(RobotImageHeaderPacket) + len + sizeof(RobotImageFooterPacket);
	
	NSData * data = [NSData dataWithBytes:_fullbytes length:totalLen];
	
	//[[RobotModel sharedRobot] sendMediaDataToController:data];
	if ( delegate ) {
		[delegate performSelectorOnMainThread:@selector(videoBroadcasterHasFrame:) withObject:data waitUntilDone:YES];
	}
	
	[imgData release];
	
	free(_fullbytes);
		   
		
	[pool release];
	
	
	
}



-(void) decodeBuffer {
		
	
}

- (void)dealloc {
	
	[videoTimer invalidate];
	
    [super dealloc];
}


@end
