//
//  BotBrainController.h
//  iBotApp
//
//  Created by Chris Laan on 9/2/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VideoBroadcaster.h"
#import "WalkieTalkie.h"

@interface BotBrainController : UIViewController <RobotSubscriber> {
	
	IBOutlet UIImageView * cableStatusImage;
	IBOutlet UIImageView * remoteStatusImage;
	
	IBOutlet UIImageView * serverStatusImage;
	IBOutlet UILabel * serverPingLabel;
	
	IBOutlet UIImageView * remoteVideoImageView;
	
	VideoBroadcaster * videoBroadcaster;
	WalkieTalkie * walkieTalkie;
	
}

-(IBAction) setMotors;
-(IBAction) stopMotors;

-(IBAction) startVideo;

@end
