//
//  BotBrainController.m
//  iBotApp
//
//  Created by Chris Laan on 9/2/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "BotBrainController.h"
#import "RobotModel.h"

@implementation BotBrainController

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
	
	
	[[RobotModel sharedRobot] initLocalRobot];
	
	[[RobotModel sharedRobot] addObserver:self forKeyPath:@"isConnectedToRemoteController" options:(NSKeyValueObservingOptionNew) context:NULL];
	[[RobotModel sharedRobot] addObserver:self forKeyPath:@"isConnectedToHardware" options:(NSKeyValueObservingOptionNew) context:NULL];
	[[RobotModel sharedRobot] addObserver:self forKeyPath:@"isConnectedToServer" options:(NSKeyValueObservingOptionNew) context:NULL];
	
	[self updateStatusImages];
	
	
	walkieTalkie = [[WalkieTalkie alloc] init];
	[walkieTalkie start];
	
	// when we recieve a packet from the controller... 
	UInt8 code = ROBOT_SOUND_PACKET_START_BYTE;
	[[RobotModel sharedRobot] addSubscriber:self forCode:[NSValue valueWithBytes:&code objCType:@encode(UInt8)]];
	
	code = ROBOT_IMAGE_PACKET_START_BYTE;
	[[RobotModel sharedRobot] addSubscriber:self forCode:[NSValue valueWithBytes:&code objCType:@encode(UInt8)]];
	
	
	
	
}

-(void) viewWillAppear:(BOOL)animated {
	
	remoteVideoImageView.frame = self.view.bounds;
	[self.view insertSubview:remoteVideoImageView atIndex:0];
	
}

-(void) receivedDataFromNetwork:(NSData*)data withCode:(NSValue*)_code {
	
	//NSLog(@"recd bytes from net..");
	
	UInt8 code;
	
	[_code getValue:&code];
	
	if ( code == ROBOT_SOUND_PACKET_START_BYTE ) {
	
		char * bytes = (char*)[data bytes];
		
		RobotDataHeaderPacket data_header_packet;
		RobotDataFooterPacket data_footer_packet;
		
		memcpy(&data_header_packet , bytes, sizeof(RobotDataHeaderPacket));
		
		int soundLen = data_header_packet.msgLen;
		
		char * _soundBytes = malloc(soundLen);
		
		memcpy(_soundBytes , bytes+sizeof(RobotDataHeaderPacket) , soundLen);
		
		memcpy(&data_footer_packet , bytes+sizeof(RobotDataHeaderPacket)+soundLen, sizeof(RobotDataFooterPacket));

		//int _num = soundLen / sizeof(MySampleType);
		
		//NSLog(@"Sound bytes %i .." , soundLen );
		
		//[walkieTalkie outputSoundData:(MySampleType*)_soundBytes numFrames:_num];
		[walkieTalkie soundDataReceived:_soundBytes withSize:soundLen];
		
		
		free(_soundBytes);
		
	} else if ( code == ROBOT_IMAGE_PACKET_START_BYTE ) {
		
		[self processImagePacket:data];
		
	}
	
	
}

#pragma mark -
#pragma mark Video Broadcaster delegate

-(void) videoBroadcasterHasFrame:(NSData*)dataPacket {
	
	[[RobotModel sharedRobot] sendMediaDataToController:dataPacket];
	
}

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
	[remoteVideoImageView performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:YES];
	[img release];
	
	//[imgData release];
	
	free(_imgBytes);
	
	
}




#pragma mark -
#pragma mark Buttons


-(IBAction) startVideo {
	
	if (!videoBroadcaster){ 
		
		videoBroadcaster = [[VideoBroadcaster alloc] init];
		[videoBroadcaster initCamera];
		//videoBroadcaster.previewLayer.frame = CGRectMake(5, 300, 120, 120);
		[videoBroadcaster.previewLayer setFrame:CGRectMake(5, 300, 120, 120)];
		videoBroadcaster.delegate = self;
		[self.view.layer addSublayer:videoBroadcaster.previewLayer];
		[videoBroadcaster startStream];
		
		[videoBroadcaster performSelector:@selector(cameraToggle) withObject:nil afterDelay:4.0];
		
	}
	
}


-(IBAction) setMotors {
	[[RobotModel sharedRobot] setMotorSpeeds:1.0 :1.0];
}

-(IBAction) stopMotors {
	[[RobotModel sharedRobot] setMotorSpeeds:0.0 : 0.0];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	
	NSLog(@"Key changed! %@ " , keyPath );
    
	if ([keyPath isEqual:@"isConnectedToRemoteController"] || [keyPath isEqual:@"isConnectedToHardware"] || [keyPath isEqual:@"isConnectedToServer"] ) {
		
		
		[self updateStatusImages];
		
		
	}
	
	
}

-(void) updateStatusImages {
		
	remoteStatusImage.image = ([RobotModel sharedRobot].isConnectedToRemoteController) ? ([UIImage imageNamed:@"GreenLight.png"]) : ([UIImage imageNamed:@"RedLight.png"]);
	cableStatusImage.image = ([RobotModel sharedRobot].isConnectedToHardware) ? ([UIImage imageNamed:@"GreenLight.png"]) : ([UIImage imageNamed:@"RedLight.png"]);
	serverStatusImage.image = ([RobotModel sharedRobot].isConnectedToServer) ? ([UIImage imageNamed:@"GreenLight.png"]) : ([UIImage imageNamed:@"RedLight.png"]);
	
	int ping = 1000 * [RobotModel sharedRobot].serverPingTime;
	serverPingLabel.text = [NSString stringWithFormat:@"Server (%i ms) " , ping];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
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
    [super dealloc];
}


@end
