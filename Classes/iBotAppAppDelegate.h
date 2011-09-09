//
//  iBotAppAppDelegate.h
//  iBotApp
//
//  Created by Chris Laan on 9/2/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iBotAppViewController;

@interface iBotAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    iBotAppViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iBotAppViewController *viewController;

@end

