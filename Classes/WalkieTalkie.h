//
//  WalkieTalkie.h
//  iBotApp
//
//  Created by Chris Laan on 9/6/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioOutputUnit.h"
#import "AudioOscillator.h"
#import "RobotObject.h"
#import "AACAudioTranscoder.h"

//#import "AudioEngineHelpers.h"

//#define SEND_BUFFER_SIZE 3000
#define SEND_BUFFER_SIZE 4096
#define ACTUAL_BUFFER_SIZE 4096 + 1024


@protocol WalkieTalkieDelegate

//-(void) walkieTalkieHasDataToSend:(MySampleType*)data;
//-(void) walkieTalkieHasDataToSend:(MySampleType*)_samples numFrames:(int)_numFrames;
-(void) walkieTalkieHasDataToSend:(uint8_t*)_bytes numBytes:(int)_numBytes;

@end


@interface WalkieTalkie : NSObject <RobotSubscriber> {

	AudioOutputUnit * outputUnit;
	AudioOscillator * mainOscillator;
	
	AACAudioTranscoder * audioTranscoder;
	
	
	BOOL isTalking;
	
	MySampleType outBuffer[ACTUAL_BUFFER_SIZE];
	MySampleType inBuffer[ACTUAL_BUFFER_SIZE];
	//uint8_t encodedBuffer[ACTUAL_BUFFER_SIZE];
	
	int outBufferWritePointer;
	int outBufferReadPointer;
	
	int inBufferPointer;
	
	id delegate;

@public
	
	//AudioConverterSettings converterSettings;
	//AudioConverterRef audioEncoder;
	//AudioConverterRef audioDecoder;
	
}

-(void) start;

-(void) stop;

-(void) startTalking;

-(void) outputSoundData:(MySampleType*)samples numFrames:(int)_num;
-(void) soundDataReceived:(uint8_t*)bytes withSize:(int)_numBytes;

@property (readwrite) BOOL isTalking;
@property (readwrite) BOOL isListening;

@property (nonatomic, assign) id <WalkieTalkieDelegate> delegate;

@end
