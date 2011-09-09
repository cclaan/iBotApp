//
//  CameraCapturer.h
//  ntpA
//
//  Created by Chris Laan on 8/12/11.
//  Copyright 2011 Ramsay Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LLOrientationDetector.h"

#if TARGET_IPHONE_SIMULATOR 
@class AVCaptureSession,AVCaptureVideoDataOutput,AVCaptureDeviceInput,AVCaptureVideoPreviewLayer,AVCaptureOutput,AVCaptureConnection,AVCaptureDevice;
#define AVCaptureSessionPresetLow 0
#endif

@interface CameraCapturer : NSObject {
	
	// new Camera stuff:
	AVCaptureSession * vidCaptureSession;
	AVCaptureVideoDataOutput * videoOutput;
	AVCaptureDeviceInput *videoInput;
	AVCaptureVideoPreviewLayer * previewLayer;
	
	UIImage * capturedImage;
	
	LLOrientationDetector * orientationDetector;	
	UIDeviceOrientation currentDeviceOrientation;
	
	NSTimeInterval pendingCaptureTime;
	
	NSMutableArray * imageBufferArray;
	
	BOOL isFrontCamera;
	
}

@property (nonatomic, retain) AVCaptureVideoPreviewLayer * previewLayer;

@property (readwrite) BOOL waitingForCapture;
@property (retain) UIImage * capturedImage;

-(void) capturePhotoAtTime:(NSTimeInterval)interval;

-(void) beginCapturingCamera;
-(void) stopCapturingCamera;

-(void) capturePhoto;

@end
