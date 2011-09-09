//
//  BotController.h
//  ServoTest
//
//  Created by Chris Laan on 8/27/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomSlider.h"

#import <CoreMotion/CoreMotion.h>

#import "WalkieTalkie.h"

#import "VideoBroadcaster.h"

@interface RemoteBotController : UIViewController <WalkieTalkieDelegate, RobotSubscriber> {
	
	
	CustomSlider * motor1Slider;
	CustomSlider * motor2Slider;
	
	CustomSlider * thrustSlider;
	CustomSlider * turnSlider;
	
	WalkieTalkie * walkieTalkie;
	
	VideoBroadcaster * videoBroadcaster;
	
	IBOutlet UISwitch * broadcastSwitch;
	IBOutlet UISwitch * gyroSwitch;
	
	IBOutlet UIImageView * robotStatusImage;
	IBOutlet UIImageView * serverStatusImage;
	IBOutlet UILabel * serverPingLabel;
	IBOutlet UILabel * robotPingLabel;
	
	CMMotionManager * motionManager;
	
	CMAttitude *refAttitude;
	
	NSTimer * gyroTimer;
	
	NSArray * soundsArray;
	
	NSTimer * runTimer;
	
	
	UIImageView * imageView;
	
	
	UIImageView * markerImageView;
	IBOutlet UISwitch * markerSwitch;
	
	
}

//@property (nonatomic, assign) ServoTestViewController * parentVc;
@property (nonatomic, assign) UIImageView * imageView;


-(IBAction) markerSwitched;

-(IBAction) setReferenceAttitude;

-(IBAction) stopMotors;

-(IBAction) gyroSwitched;

-(IBAction) talkDown;
-(IBAction) talkUp;

-(IBAction) closeView;

-(IBAction) animalTouched;
-(IBAction) botTouched;
-(IBAction) horseTouched;
-(IBAction) catTouched;
-(IBAction) randomSoundTouched;


-(void) receivedDataFromRobot:(NSData*)dat;


@end
