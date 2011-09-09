//
//  AudioOscillator.h
//  ntpA
//
//  Created by Chris Laan on 8/13/11.
//  Copyright 2011 Ramsay Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AudioOscillator : NSObject {
	
	float frequency;
	BOOL active;
	
	double currentVal;
	
	float tween;
	
	double increment;
	double desiredIncrement;
	
	double amplitude;
	
	double desiredAmplitude;
	
	double maxAmplitude;
	
}

@property (nonatomic,readwrite) float frequency;
@property (nonatomic,readwrite) double maxAmplitude;
@property (nonatomic,readwrite) BOOL active;

-(void) renderFrames:(SInt32*)frameBuffer numFrames:(int)numFrames;
-(void) renderFrames8:(UInt8*)frameBuffer numFrames:(int)numFrames;

+(AudioOscillator*) oscillatorWithFrequency:(float)freq;

@end
