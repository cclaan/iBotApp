//
//  BotController.m
//  ServoTest
//
//  Created by Chris Laan on 8/27/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "RemoteBotController.h"

#import "RobotConstants.h"

#import "RemoteRobotModel.h"

#import <QuartzCore/QuartzCore.h>


@interface RemoteBotController()

-(void) createiPadInterface;
-(void) createInterface;
-(void) createTurningSliders;
-(void) setSpeedsFromSliders;
-(void) turnSliderChanged;
-(void) thrustSliderChanged;

-(void) processImagePacket:(NSData*) data;
-(void) sendSoundPacket:(NSString*)soundName;

@end


@implementation RemoteBotController

@synthesize imageView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	

	//[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
	
	
	[[RemoteRobotModel sharedRemoteRobot] initRemoteRobot];
	//[RemoteRobotModel sharedRemoteRobot].delegate = self;
	
	
	[[RemoteRobotModel sharedRemoteRobot] addObserver:self forKeyPath:@"isConnectedToRemoteRobot" options:(NSKeyValueObservingOptionNew) context:NULL];
	[[RemoteRobotModel sharedRemoteRobot] addObserver:self forKeyPath:@"isConnectedToServer" options:(NSKeyValueObservingOptionNew) context:NULL];
	
	
	[[RemoteRobotModel sharedRemoteRobot] addObserver:self forKeyPath:@"serverPingTime" options:(NSKeyValueObservingOptionNew) context:NULL];
	[[RemoteRobotModel sharedRemoteRobot] addObserver:self forKeyPath:@"robotPingTime" options:(NSKeyValueObservingOptionNew) context:NULL];
	
	//[self updateStatusImages];
	
	
	walkieTalkie = [[WalkieTalkie alloc] init];
	walkieTalkie.delegate = self;
	[walkieTalkie start];
	

	// when we recieve a packet from the bot 
	UInt8 code = ROBOT_IMAGE_PACKET_START_BYTE;
	[[RemoteRobotModel sharedRemoteRobot] addSubscriber:self forCode:[NSValue valueWithBytes:&code objCType:@encode(UInt8)]];
	
	
	[self startVideo];
	
	
}



-(void) viewWillAppear:(BOOL)animated {
	
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self createiPadInterface];
	} else {
		[self createInterface];
	}
	
	runTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/24.0) target:self selector:@selector(runLoop) userInfo:nil repeats:YES];
	
	soundsArray = [[NSArray arrayWithObjects:@"All Your Base.wav",@"sad trombone.wav",@"Clown Horn.wav",@"Bark.wav",@"Cat Hiss.wav",@"Horse Buck.wav",nil] retain];
	
	
}

#pragma mark -


-(IBAction) startVideo {
	
	if (!videoBroadcaster){ 
		
		videoBroadcaster = [[VideoBroadcaster alloc] init];
		[videoBroadcaster initCamera];
		//videoBroadcaster.previewLayer.frame = CGRectMake(5, 300, 120, 120);
		[videoBroadcaster.previewLayer setFrame:CGRectMake(380, 40, 100, 100)];
		videoBroadcaster.delegate = self;
		[self.view.layer addSublayer:videoBroadcaster.previewLayer];
		[videoBroadcaster startStream];
		
#if !TARGET_IPHONE_SIMULATOR
		videoBroadcaster.previewLayer.transform = CATransform3DMakeRotation(-M_PI/2.0, 0, 0, 1.0);
#endif
		
		[videoBroadcaster performSelector:@selector(cameraToggle) withObject:nil afterDelay:5.0];
	}
	
}

-(IBAction) talkDown {
	walkieTalkie.isTalking = YES;
}

-(IBAction) talkUp {
	walkieTalkie.isTalking = NO;
}


#pragma mark -
#pragma mark Video Broadcaster delegate

-(void) videoBroadcasterHasFrame:(NSData*)dataPacket {
	
	[[RemoteRobotModel sharedRemoteRobot] sendMediaDataToRobot:dataPacket];
	
	
}




//-(void) walkieTalkieHasDataToSend:(MySampleType*)_samples numFrames:(int)_numFrames {

-(void) walkieTalkieHasDataToSend:(uint8_t*)_bytes numBytes:(int)_numBytes {
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	// construct packet here...
		
	RobotDataHeaderPacket data_header_packet;
	RobotDataFooterPacket data_footer_packet;
	
	data_header_packet.startByte = ROBOT_SOUND_PACKET_START_BYTE;
	data_footer_packet.startByte = ROBOT_SOUND_PACKET_START_BYTE;
	
	int len = _numBytes;//sizeof(MySampleType) * _numFrames;
	
	//NSLog(@"sending sound with num samples: %i , %u " , len , _samples[40] );
	
	data_header_packet.msgLen = len;
	data_footer_packet.msgLen = len;
	
	char * imgBytes = (char*)_bytes;
	
	char * _fullbytes = malloc(sizeof(RobotDataHeaderPacket) + len + sizeof(RobotDataFooterPacket) );
	
	memcpy(_fullbytes , &data_header_packet, sizeof(RobotDataHeaderPacket));
	memcpy(_fullbytes+sizeof(RobotDataHeaderPacket) , imgBytes, len);
	memcpy(_fullbytes+sizeof(RobotDataHeaderPacket)+len , &data_footer_packet, sizeof(RobotDataFooterPacket));
	
	int totalLen = sizeof(RobotDataHeaderPacket) + len + sizeof(RobotDataFooterPacket);
	
	NSData * data = [NSData dataWithBytes:_fullbytes length:totalLen];
	
	[[RemoteRobotModel sharedRemoteRobot] sendMediaDataToRobot:data];
	
	free(_fullbytes);
	
	[pool release];
	
	
	
}


#pragma mark -


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	
	//NSLog(@"Key changed! %@  " , keyPath  );
    
	if ([keyPath isEqual:@"isConnectedToRemoteRobot"] || [keyPath isEqual:@"isConnectedToServer"] ) {
		
		
		[self updateStatusImages];
		
		
	} else if ([keyPath isEqual:@"serverPingTime"] || [keyPath isEqual:@"robotPingTime"] ) {
		
		int sping = [RemoteRobotModel sharedRemoteRobot].serverPingTime * 1000;
		serverPingLabel.text = [NSString stringWithFormat:@"Server: %i ms" , sping];
		
		int rping = [RemoteRobotModel sharedRemoteRobot].robotPingTime * 1000;
		robotPingLabel.text = [NSString stringWithFormat:@"Bot: %i ms" , rping];
		
	}
	
	
}

-(void) updateStatusImages {
	
	robotStatusImage.image = ([RemoteRobotModel sharedRemoteRobot].isConnectedToRemoteRobot ) ? ([UIImage imageNamed:@"GreenLight.png"]) : ([UIImage imageNamed:@"RedLight.png"]);
	serverStatusImage.image = ([RemoteRobotModel sharedRemoteRobot].isConnectedToServer ) ? ([UIImage imageNamed:@"GreenLight.png"]) : ([UIImage imageNamed:@"RedLight.png"]);
	/*
	 if ( [RemoteRobotModel sharedRemoteRobot].isConnectedToServer ) {
	 serverStatusImage.image = [UIImage imageNamed:@"GreenLight.png"];
	 } else {
	 serverStatusImage.image = [UIImage imageNamed:@"RedLight.png"];
	 }
	 */
	
	
	
}


#pragma mark -

-(void) createiPadInterface {
	
	[self createTurningSliders];
	
	imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 580, 420)];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.image = [UIImage imageNamed:@"noise.png"];
	
	//imageView.transform = CGAffineTransformMakeRotation(90.0 * (M_PI/180.0));
	imageView.backgroundColor = [UIColor darkGrayColor];
	[self.view insertSubview:imageView atIndex:0];
	imageView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
	
	
}

-(void) createInterface {
	
	[self createTurningSliders];
	
	imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.image = [UIImage imageNamed:@"noise.png"];
	
	//imageView.transform = CGAffineTransformMakeRotation(90.0 * (M_PI/180.0));
	imageView.backgroundColor = [UIColor darkGrayColor];
	[self.view insertSubview:imageView atIndex:0];
	imageView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);

	
}

-(IBAction) closeView {
	
	[self dismissModalViewControllerAnimated:YES];

	
}

#pragma mark -
#pragma mark Run Loop


-(void) runLoop {
	
	
	if ( !thrustSlider.isDragging ) {
		thrustSlider.value *= 0.92;
		[self thrustSliderChanged];
	}
	
	if ( !turnSlider.isDragging ) {
		turnSlider.value *= 0.92;
		[self turnSliderChanged];
	}
	
	[self setSpeedsFromSliders];
	
	//[self broadcastMotorSpeed];
	
	//[self sendHeartbeatIfNeeded];
	
	
}


#pragma mark -

-(void) createMotorSliders {
	
	CGRect frame = CGRectMake(20, 30, 280, 110);
	
	motor1Slider = [[CustomSlider alloc] initWithFrame:frame];
	
	[motor1Slider addTarget:self action:@selector(motor1SliderChanged) forControlEvents:UIControlEventValueChanged];
	
	motor1Slider.minimumValue = 0.0;
	motor1Slider.maximumValue = 1.0;
	motor1Slider.trackHeadWidth = 80;
	motor1Slider.tapIncrement = 0.1;
	motor1Slider.value = 0.5;
	motor1Slider.supportsHoldToSlide = NO;
	motor1Slider.centerValue = 0.5;
	[self.view addSubview:motor1Slider];
	
	frame.origin.y += (110 + 20);
	
	motor2Slider = [[CustomSlider alloc] initWithFrame:frame];
	
	[motor2Slider addTarget:self action:@selector(motor2SliderChanged) forControlEvents:UIControlEventValueChanged];
	
	motor2Slider.minimumValue = 0.0;
	motor2Slider.maximumValue = 1.0;
	motor2Slider.trackHeadWidth = 80;
	motor2Slider.tapIncrement = 0.1;
	motor2Slider.value = 0.5;
	motor2Slider.supportsHoldToSlide = NO;
	motor2Slider.centerValue = 0.5;
	
	[self.view addSubview:motor2Slider];
	
}

-(void) createTurningSliders {
	
	
	NSLog(@"self.bounds %f " , self.view.bounds.size.width );
	
	CGRect frame = CGRectMake(0, 0, 300, 130);
	
	//frame.origin.x = 0;
	
	thrustSlider = [[CustomSlider alloc] initWithFrame:frame];
	
	[thrustSlider addTarget:self action:@selector(thrustSliderChanged) forControlEvents:UIControlEventValueChanged];
	
	thrustSlider.minimumValue = -1.0;
	thrustSlider.maximumValue = 1.0;
	thrustSlider.trackHeadWidth = 98;
	thrustSlider.tapIncrement = 0.1;
	thrustSlider.value = 0.0;
	thrustSlider.supportsHoldToSlide = NO;
	thrustSlider.centerValue = 0.0;
	
	thrustSlider.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
	thrustSlider.trackHead.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];

	thrustSlider.layer.cornerRadius = 5.0;
	thrustSlider.layer.borderWidth = 2;
	thrustSlider.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;

	thrustSlider.trackHead.layer.cornerRadius = 3.0;
	thrustSlider.trackHead.layer.borderWidth = 2;
	thrustSlider.trackHead.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
	thrustSlider.transform = CGAffineTransformMakeRotation(-90.0 * (M_PI/180.0));
	
	thrustSlider.center = CGPointMake(75, self.view.bounds.size.height - 150 - 10);
	
	[self.view addSubview:thrustSlider];
	
	/*
	frame.origin.y += (210);
	frame.origin.x = 60;
	
	frame.size.width = 290;
	frame.size.height = 160;
	*/
	
	
	turnSlider = [[CustomSlider alloc] initWithFrame:frame];
	
	[turnSlider addTarget:self action:@selector(turnSliderChanged) forControlEvents:UIControlEventValueChanged];
	
	turnSlider.minimumValue = -1.0;
	turnSlider.maximumValue = 1.0;
	turnSlider.trackHeadWidth = 98;
	turnSlider.tapIncrement = 0.1;
	turnSlider.value = 0.0;
	turnSlider.supportsHoldToSlide = NO;
	turnSlider.centerValue = 0.0;
	//turnSlider.transform = CGAffineTransformMakeRotation(90.0 * (M_PI/180.0));
	
	
	turnSlider.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
	turnSlider.trackHead.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:1.0 alpha:0.3];

	turnSlider.layer.cornerRadius = 5.0;
	turnSlider.layer.borderWidth = 2;
	turnSlider.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
	
	turnSlider.trackHead.layer.cornerRadius = 3.0;
	turnSlider.trackHead.layer.borderWidth = 2;
	turnSlider.trackHead.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
	
	turnSlider.center = CGPointMake(self.view.bounds.size.width - 150 - 10, self.view.bounds.size.height - 85);
	
	[self.view addSubview:turnSlider];
	
}


#pragma mark -
#pragma mark Data from Robot  

-(void) receivedDataFromNetwork:(NSData*)data withCode:(NSValue*)_code {
	
	//NSLog(@"recd bytes from net..");
	
	UInt8 code;
	
	[_code getValue:&code];
	
	if ( code == ROBOT_IMAGE_PACKET_START_BYTE ) {
		[self processImagePacket:data];
	}

}

/*
-(void) receivedDataFromRobot:(NSData*)data {
	
	[data retain];
		
	char * bytes = (char*)[data bytes];
	
	if ( bytes[0] == ROBOT_IMAGE_PACKET_START_BYTE ) {
			
		[self processImagePacket:data];
		
	} 
	
	[data release];

}
*/

#pragma mark -

-(void) processImagePacket:(NSData*) data {
	
	char * bytes = (char*)[data bytes];
	
	RobotImageHeaderPacket img_header_packet;
	RobotImageFooterPacket img_footer_packet;
	
	memcpy(&img_header_packet , bytes, sizeof(RobotImageHeaderPacket));
	
	int imgLen = img_header_packet.msgLen;
	
	char * _imgBytes = malloc(imgLen);
	
	memcpy(_imgBytes , bytes+sizeof(RobotImageHeaderPacket) , imgLen);
	
	memcpy(&img_footer_packet , bytes+sizeof(RobotImageHeaderPacket)+imgLen, sizeof(RobotImageFooterPacket));
	
	NSData * imgData = [NSData dataWithBytes:_imgBytes length:imgLen];
	
	UIImage * img = [[UIImage alloc] initWithData:imgData];
	
	//NSLog(@"img: %f , %f " , img.size.width , img.size.height );
	
	//imgView.image = img;
	[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:YES];
	[img release];
	
	//[imgData release];
	
	free(_imgBytes);

	
}



#pragma mark - UIButton Callback


-(IBAction) animalTouched {
		
	[self sendSoundPacket:@"Bark.wav"];
	
}

-(IBAction) botTouched {
	
	[self sendSoundPacket:@"All Your Base.wav"];
}

-(IBAction) horseTouched {
	
	[self sendSoundPacket:@"Horse Buck.wav"];
}

-(IBAction) catTouched {
	
	[self sendSoundPacket:@"Cat Hiss.wav"];
}

-(IBAction) randomSoundTouched {
	
	int rnd = random() % ([soundsArray count]-1);
	NSString * rndString = [soundsArray objectAtIndex:rnd];
	
	[self sendSoundPacket:rndString];
	
}

-(void) sendSoundPacket:(NSString*)soundName {
	
	
	//char Sentence[] = "motor"; 
	RobotStringPacket r_packet;
	
	r_packet.startByte = ROBOT_STRING_PACKET_START_BYTE;
	
	int len = [soundName length];
	
	char * msg = (char*)[soundName UTF8String];
	memcpy(r_packet.message , msg, len );
	r_packet.msgLen = len;
	
	NSData * data = [NSData dataWithBytes:&r_packet length:sizeof(RobotStringPacket)];
	
	[[RemoteRobotModel sharedRemoteRobot] sendMediaDataToRobot:data];
	
	
	
	
}


-(IBAction) stopMotors {
	
	gyroSwitch.on = NO;
	
	//motor1Speed = 127;
	//motor2Speed = 127;

	//[self broadcastMotorSpeed];
	[[RemoteRobotModel sharedRemoteRobot] stopMotors];
	
	
}

-(IBAction) gyroSwitched {
	
	
	if ( gyroSwitch.on ) {
		
		[self startGyro];
		gyroTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/16.0) target:self selector:@selector(setSpeedFromGyro) userInfo:nil repeats:YES];
		
	} else {
		
		[motionManager stopDeviceMotionUpdates];
		[gyroTimer invalidate];
		
	}	
	
	
}


-(IBAction) startGyro {
	
	
	if (motionManager == nil) {
		motionManager = [[CMMotionManager alloc] init];
	}
	
	motionManager.deviceMotionUpdateInterval = 0.2;
	[motionManager startDeviceMotionUpdates];
	
	
}

#pragma mark -

-(IBAction) markerSwitched {
	
	if ( !markerImageView ) {
		markerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Marker 2.png"]];
		markerImageView.contentMode = UIViewContentModeScaleAspectFit;
		markerImageView.frame = CGRectInset(imageView.frame, -120, -100);
		[self.view addSubview:markerImageView];
	} 
	
	markerImageView.hidden = !markerSwitch.on;

	
}

#pragma mark -

-(void) motor1SliderChanged {
	
	[RemoteRobotModel sharedRemoteRobot].motorSpeedLeft = motor1Slider.value;
	
	
}


-(void) motor2SliderChanged {
	
	[RemoteRobotModel sharedRemoteRobot].motorSpeedRight = motor2Slider.value;
	
}

#pragma mark -

-(void) thrustSliderChanged {
	
	//-[self setSpeedsFromSliders];
	//NSLog(@"turn %3.2f " , turnSlider.value );
	
}


-(void) turnSliderChanged {
	
	//-[self setSpeedsFromSliders];
	//NSLog(@"turn %3.2f " , turnSlider.value );
	
}


-(void) setSpeedsFromSliders {

	float mLThrust = 0.0;
	float mRThrust = 0.0;

	float thrust = thrustSlider.value;
	thrust = fmin(thrust , 1.0);
	thrust = fmax(thrust , -1.0);
	
	float turn = turnSlider.value; 
	turn = fmin(turn , 1.0 );
	turn = fmax(turn , -1.0 );
	
	
	mLThrust = turn*0.6;
	mRThrust = -turn*0.6;
	
	mLThrust += thrust;
	mRThrust += thrust;
	
	mLThrust = fmin(0.99, mLThrust);
	mLThrust = fmax(-0.99, mLThrust);
	
	mRThrust = fmin(0.99, mRThrust);
	mRThrust = fmax(-0.99, mRThrust);
	
	[RemoteRobotModel sharedRemoteRobot].motorSpeedLeft = mLThrust;
	[RemoteRobotModel sharedRemoteRobot].motorSpeedRight = mRThrust;
	
	/*
	float m1s = 127.0 + (mLThrust * 127.0);
	float m2s = 127.0 + (mRThrust * 127.0);
	
	m1s = fmin(fmax(0.0, round(m1s)), 255.0 );
	m2s = fmin(fmax(0.0, round(m2s)), 255.0 );
	
	motor1Speed = (UInt8)m1s;
	motor2Speed = (UInt8)m2s;
	*/
	
	//[self broadcastMotorSpeed];
	
	//NSLog(@"L: %3.2f R: %3.2f --- Left Motor: %u Right Motor: %u " , mLThrust , mRThrust , motor2Speed , motor1Speed );
	
}


-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	
	if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ) {
		return YES;
	} else {
		return NO;
	}
	
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	[runTimer invalidate];
	
	
    [super dealloc];
}


@end
