//
//  VideoBroadcastController.h
//  RobotBrain
//
//  Created by Chris Laan on 8/30/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CameraCapturer.h"

@interface VideoBroadcaster : NSObject {
	
	
	CameraCapturer * cameraCapturer;
	
	NSTimer * videoTimer;
	
	int fps;
	
	id delegate;
	
}

-(void) sendFrame;

-(void) startStream;

-(void) stopStream;

-(void) setFramerate:(int)_fps;

-(void) cameraToggle;

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer * previewLayer;
@property (assign) id delegate;

@end
