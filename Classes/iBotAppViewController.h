//
//  iBotAppViewController.h
//  iBotApp
//
//  Created by Chris Laan on 9/2/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BotBrainController.h"
#import "RemoteBotController.h"

@interface iBotAppViewController : UIViewController {

}

-(IBAction) showRemoteBrainController;
-(IBAction) showBotBrainController;
-(IBAction) showAutoBrainController;

@end

