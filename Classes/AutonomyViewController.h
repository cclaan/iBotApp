//
//  AutonomyViewController.h
//  iBotApp
//
//  Created by Chris Laan on 9/8/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AutonomyViewController : UIViewController {
	
	NSTimer * runTimer;
	IBOutlet UIImageView * cableStatusImage;
	IBOutlet UILabel * label;
	
	float dR, dL;
	
	
	
}

@end
