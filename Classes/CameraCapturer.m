//
//  CameraCapturer.m
//  ntpA
//
//  Created by Chris Laan on 8/12/11.
//  Copyright 2011 Ramsay Consulting. All rights reserved.
//

#import "CameraCapturer.h"
#import "SampleBufferHolder.h"



@implementation CameraCapturer

@synthesize previewLayer, waitingForCapture, capturedImage;

#if !TARGET_IPHONE_SIMULATOR 

#pragma mark -
#pragma mark Camera 

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		
		[self setupCamera];
		[self addVideoPreviewLayer];
		//[self beginCapturingCamera];
		
		currentDeviceOrientation = -1;
		
		orientationDetector = [[LLOrientationDetector alloc] init];
		orientationDetector.delegate = self;
		[orientationDetector startReceivingUpdates];
	
		imageBufferArray = [[NSMutableArray alloc] init];
		
		isFrontCamera = NO;
		
	}
	return self;
}


-(void) setupCamera {
	
	NSError *error = nil;
	
	videoInput = [[AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error] retain]; 
	
	
	videoOutput = [[AVCaptureVideoDataOutput alloc] init];
	
	
	// init session
	vidCaptureSession = [[AVCaptureSession alloc] init]; 
	
    // config
	[vidCaptureSession beginConfiguration]; 
    
	// set input/output
	[vidCaptureSession addInput:videoInput]; 
	
	[vidCaptureSession addOutput:videoOutput]; 
	
	[vidCaptureSession setSessionPreset:AVCaptureSessionPresetLow]; //this doesnt affect res on 3G, 
    //[vidCaptureSession setSessionPreset:AVCaptureSessionPresetMedium]; //this doesnt affect res on 3G, 
	
    //[videoOutput setAlwaysDiscardsLateVideoFrames:YES]; 
	
	[videoOutput setMinFrameDuration:CMTimeMake(1, 20)];
	
	
    // set colorspace
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 
	NSNumber* value = nil;
	
	BOOL useRGB = YES;
	
	if ( useRGB ) {
		
		value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
		
	}
	
	
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
	[videoOutput setVideoSettings:videoSettings]; 
	
	// more stable and faster
	dispatch_queue_t cameraDelegateQ = dispatch_queue_create("com.laan.CameraCapturer.frame_queue", NULL);
    
    dispatch_queue_t target = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	//dispatch_queue_t target = dispatch_get_main_queue();
	
    dispatch_set_target_queue(cameraDelegateQ, target);
    
	[videoOutput setSampleBufferDelegate:self queue:cameraDelegateQ];
	
	[vidCaptureSession commitConfiguration]; 
	
}

-(void) beginCapturingCamera {
	
	// turn on video capture
	[vidCaptureSession startRunning]; 
	
}

-(void) stopCapturingCamera {
	
	[vidCaptureSession stopRunning]; 
	
}


-(void) addVideoPreviewLayer {
	
	previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:vidCaptureSession];
	//previewLayer.frame = window.bounds;
	
	//previewLayer.masksToBounds = YES;
	//previewLayer.opaque = YES;
	
	[previewLayer setMasksToBounds:YES];
	[previewLayer setOpaque:YES];
	[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
	
	//[window.layer insertSublayer:previewLayer atIndex:0];
	//[window.layer addSublayer:previewLayer];

	
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer  fromConnection:(AVCaptureConnection *)connection
{
	
	

	
	if ( self.waitingForCapture ) { 
		
		CGImageRef cgImage = [self imageFromSampleBuffer:sampleBuffer];
		
		UIDeviceOrientation o = [LLOrientationDetector deviceOrientation];
		UIImageOrientation imageOrient = -1;
		
		switch (o) {
			case UIDeviceOrientationPortrait:
				imageOrient = UIImageOrientationRight;
				break;
			case UIDeviceOrientationPortraitUpsideDown:
				imageOrient = UIImageOrientationLeft;
				break;
			case UIDeviceOrientationLandscapeLeft:
				imageOrient = UIImageOrientationUp;
				break;
			case UIDeviceOrientationLandscapeRight:
				imageOrient = UIImageOrientationDown;
				break;
			case UIDeviceOrientationUnknown:
				imageOrient = UIImageOrientationRight;
				break;
			default:
				break;
		}
		
		if ( isFrontCamera ) {
			
			switch (o) {
				case UIDeviceOrientationPortrait:
					imageOrient = UIImageOrientationRight;
					break;
				case UIDeviceOrientationPortraitUpsideDown:
					imageOrient = UIImageOrientationLeft;
					break;
				case UIDeviceOrientationLandscapeLeft:
					imageOrient = UIImageOrientationDown;
					break;
				case UIDeviceOrientationLandscapeRight:
					imageOrient = UIImageOrientationUp;
					break;
				case UIDeviceOrientationUnknown:
					imageOrient = UIImageOrientationLeft;
					break;
				default:
					break;
			}
			
			
			
		}
		
		self.capturedImage = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:imageOrient];
		
		CGImageRelease( cgImage );
		//NSLog(@"captured photo");
		self.waitingForCapture = NO;
		
	}
	
	
}

-(void) saveBestPhotoFromArray {
	
	NSTimeInterval minMistmatch = 1000.0;
	SampleBufferHolder * bestImage = nil;
	
	for (SampleBufferHolder * _sampleHolder in imageBufferArray ) {
		if ( fabs(_sampleHolder.timeMismatch) < minMistmatch ) {
			minMistmatch = fabs(_sampleHolder.timeMismatch);
			bestImage = _sampleHolder;
		}	
	}
	
	NSLog(@"chose best image with mismatch: %f" , bestImage.timeMismatch );
	CGImageRef cgImage = [self imageFromSavedBuffer:bestImage];
	
	UIDeviceOrientation o = [LLOrientationDetector deviceOrientation];
	UIImageOrientation imageOrient = -1;
	
	switch (o) {
		case UIDeviceOrientationPortrait:
			imageOrient = UIImageOrientationRight;
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			imageOrient = UIImageOrientationLeft;
			break;
		case UIDeviceOrientationLandscapeLeft:
			imageOrient = UIImageOrientationUp;
			break;
		case UIDeviceOrientationLandscapeRight:
			imageOrient = UIImageOrientationDown;
			break;
		case UIDeviceOrientationUnknown:
			imageOrient = UIImageOrientationRight;
			break;
		default:
			break;
	}
	
	self.capturedImage = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:imageOrient];
	
	CGImageRelease( cgImage );
	NSLog(@"captured photo");
	self.waitingForCapture = NO;
	
	
}	


- (CGImageRef) imageFromSavedBuffer:(SampleBufferHolder*) sampleBufferHolder 
{
    
    uint8_t *baseAddress = (uint8_t *)[sampleBufferHolder.bufferData bytes];
    size_t bytesPerRow = sampleBufferHolder.bytesPerRow;
    size_t width = sampleBufferHolder.width;
    size_t height = sampleBufferHolder.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
	
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
    CGImageRef newImage = CGBitmapContextCreateImage(newContext); 
    CGContextRelease(newContext); 
	
    CGColorSpaceRelease(colorSpace); 
	
    return newImage;
}

- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer 
	
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image 
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
	
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
    CGImageRef newImage = CGBitmapContextCreateImage(newContext); 
    CGContextRelease(newContext); 
	
    CGColorSpaceRelease(colorSpace); 
    CVPixelBufferUnlockBaseAddress(imageBuffer,0); 
    /* CVBufferRelease(imageBuffer); */  // do not call this!
	
    return newImage;
}

-(void) capturePhotoAtTime:(NSTimeInterval)interval {
	
	[imageBufferArray removeAllObjects];
	NSLog(@"taking photo...");
	pendingCaptureTime = interval;
	self.waitingForCapture = YES;
	self.capturedImage = nil;
	
}

-(void) capturePhoto {
	
	self.waitingForCapture = YES;
	self.capturedImage = nil;
	/*
	while (self.waitingForCapture==YES) {
		[NSThread sleepForTimeInterval:0.01];
	}
	
	return self.capturedImage;
	*/
}

- (BOOL) cameraToggle
{
    BOOL success = NO;
    
    if ([self cameraCount] > 1) {
		
        NSError *error;
        
		//AVCaptureDeviceInput *videoInput = [self videoInput];
		
        AVCaptureDeviceInput *newVideoInput;
        
		AVCaptureDevicePosition position = [[videoInput device] position];
        
		BOOL mirror;
        
		if (position == AVCaptureDevicePositionBack) {
        
			newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
            mirror = NO;
			isFrontCamera = YES;
			
        } else if (position == AVCaptureDevicePositionFront) {
            
			newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
            mirror = YES;
			isFrontCamera = NO;
			
        } else {
            goto bail;
        }
        
        AVCaptureSession *session = vidCaptureSession;
		
        if (newVideoInput != nil) {
			
            [session beginConfiguration];
            [session removeInput:videoInput];
            
			NSString *currentPreset = [session sessionPreset];
            if (![[newVideoInput device] supportsAVCaptureSessionPreset:currentPreset]) {
                [session setSessionPreset:AVCaptureSessionPresetHigh]; // default back to high, since this will always work regardless of the camera
            }
            if ([session canAddInput:newVideoInput]) {
                
				[session addInput:newVideoInput];
                
				AVCaptureConnection *connection = [CameraCapturer connectionWithMediaType:AVMediaTypeVideo fromConnections:[videoOutput connections]];
                if ([connection isVideoMirroringSupported]) {
                    [connection setVideoMirrored:mirror];
                }
                //[self setVideoInput:newVideoInput];
				
				
            } else {
                [session setSessionPreset:currentPreset];
                [session addInput:videoInput];
            }
			
            [session commitConfiguration];
            success = YES;
            [newVideoInput release];
			
        } else if (error) {
            
			
        }
    }
    
bail:
    return success;
}

- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

#pragma mark -
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
	
#if !(TARGET_IPHONE_SIMULATOR)	
	
	
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
	
#endif	
	
    return nil;
}

- (AVCaptureDevice *) frontFacingCamera
{
	
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
	
}

- (AVCaptureDevice *) backFacingCamera
{
	
	return [self cameraWithPosition:AVCaptureDevicePositionBack];
	
}

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return [[connection retain] autorelease];
			}
		}
	}
	return nil;
}


#pragma mark -
#pragma mark LLOrientationDetectorDelegate

-(void) deviceOrientationDidChange:(LLOrientationDetector*)detector {
	
	// using interface orientation since it hides face up / face down
	//[self updateOrientationImages:YES];
	
	
}
// dont need both of these vvv ^^^
-(void) interfaceOrientationDidChange:(LLOrientationDetector*)detector {
	
	NSLog(@"Orientation!");
	//[self updateOrientationImages:YES];
	
	
}

#endif

@end
