//
//  AudioOscillator.m
//  ntpA
//
//  Created by Chris Laan on 8/13/11.
//  Copyright 2011 Ramsay Consulting. All rights reserved.
//

#import "AudioOscillator.h"


@implementation AudioOscillator

@synthesize frequency, active, maxAmplitude;

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		currentVal = 0.0 + 2*M_PI*((float)(rand()%100))/100.0;
		increment = 0.0;
		
		amplitude = 0.0;
		desiredAmplitude = 0.0;
		maxAmplitude = 2147483647;
		
		/*
		if ( sizeof(MySampleType) == 1 ) {
			maxAmplitude = 255;
		} else if ( sizeof(MySampleType) == 2 ) {
			
		} else if ( sizeof(MySampleType) == 4 ) {
			
		}*/
		
	}
	return self;
}


-(void) setFrequency:(float) freq {
	
	frequency = freq;
	increment = (2*M_PI / 11025.0) * frequency;
	
	//desiredIncrement = (2*M_PI / 44100.0) * frequency;
	//if ( increment == 0.0 ) increment = desiredIncrement;
	
}

-(void) setActive:(BOOL)act {
	
	//2147483647
	desiredAmplitude = (act) ? (maxAmplitude) : (0.0);
	active = act;
	
}	

-(void) renderFrames8:(UInt8*)frameBuffer numFrames:(int)numFrames {
	
	double sinV;
	UInt8 val = 0;
	//INT32_MAX 
	
	
	
	for (int i=0; i < numFrames; i++)
	{
		
		//amplitude = amplitude - (amplitude - desiredAmplitude)*0.1;
		
		//increment = increment - (increment - desiredIncrement)*0.005;
		
		//sinV = amplitude * sinl(currentVal);
		sinV = 128 + 127 * sin(currentVal);
		val = round(sinV);
		
		frameBuffer[i] = val;
		//frameBuffer[i] = (rand() % 250);
		
		currentVal += increment;
		
	}

	
}

-(void) renderFrames:(SInt32*)frameBuffer numFrames:(int)numFrames {
	
	double sinV;
	SInt32 val = 0;
	//INT32_MAX 
	
	
	
	for (int i=0; i < numFrames; i++)
	{
		
		//amplitude = amplitude - (amplitude - desiredAmplitude)*0.1;
		
		//increment = increment - (increment - desiredIncrement)*0.005;
		
		//sinV = amplitude * sinl(currentVal);
		sinV = 2147440000.0 * sin(currentVal);
		val = round(sinV);
		
		frameBuffer[i] = val;
		
		currentVal += increment;
	
	}
	
	
	// if ( increment > M_PI*2 ) increment = 0.0;
	
	
}

+(AudioOscillator*) oscillatorWithFrequency:(float)freq {
	AudioOscillator * osc = [[[AudioOscillator alloc] init] autorelease];
	osc.frequency = freq;
	osc.active = NO;
	return osc;
}


@end
