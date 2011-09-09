//
//  WalkieTalkie.m
//  iBotApp
//
//  Created by Chris Laan on 9/6/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "WalkieTalkie.h"


@interface WalkieTalkie()

-(OSStatus) encodeSamples:(MySampleType *)srcSamples withSize:(size_t)numSamples toDest:(uint8_t*) dstBuffer gotSize:(UInt32*) numEncoded;

@end


@implementation WalkieTalkie

@synthesize isListening, isTalking, delegate;

-(void) start {
	
	outputUnit = [[AudioOutputUnit alloc] initWithDelegate:self];
	
	mainOscillator = [[AudioOscillator oscillatorWithFrequency:6000.0] retain];
	//mainOscillator.maxAmplitude = 0.9;
	mainOscillator.active = YES;
	
	//[outputUnit setupAudioOutputUnitWithInput];
	[outputUnit start];
	
	//[self createConverters];
	
	audioTranscoder = [[AACAudioTranscoder alloc] init];
	
	/*
	MySampleType testBuffer[1024];
	MySampleType testBuffer2[1025];
	
	uint8_t testCompressedBuffer[512];
	bzero(testCompressedBuffer, 512);
	
	float cntr = 0.0;
	for (int i = 0; i < 1024; i++) {
		testBuffer[i] = 128 + 100*sin(cntr);
		cntr+= 0.15;
	}
	
	int size = 512;
	
	[audioTranscoder encodeSamples:testBuffer numSamples:1024 intoBuffer:testCompressedBuffer returnSize:&size];
	
	int numPackets = testCompressedBuffer[0];
	NSLog(@"new output size: %i , num packets: %i " , size , testCompressedBuffer[0] );
	
	AudioStreamPacketDescription descs[10];
	memcpy(descs , testCompressedBuffer+1 , sizeof(AudioStreamPacketDescription)*numPackets );
	
	NSLog(@"first packet size: %i " , descs[0].mDataByteSize );
	
	int size2 = 1025;
	[audioTranscoder decodeBuffer:testCompressedBuffer withSize:size intoSampleBuffer:testBuffer2 returnSamples:&size2];
	
	NSLog(@"decoded %i raw samples, first sample: %i " , size2, testBuffer2[0] );
	
	exit(0);
	*/
	
	
}

-(void) stop {
	
}

-(void) startTalking {
	
}

/*
-(void) receivedDataFromNetwork:(NSData*)data withCode:(NSValue*)_code {
	
	
	@synchronized (self) {
		// copy into output buffer
	}
	
}
*/

-(void) soundDataReceived:(uint8_t*)bytes withSize:(int)_numBytes {
	
	
	
	@synchronized (self) {
		
		int size2 = ACTUAL_BUFFER_SIZE+1;
		[audioTranscoder decodeBuffer:bytes withSize:_numBytes intoSampleBuffer:outBuffer returnSamples:&size2];
	
		int numSamples = size2 / sizeof(MySampleType);
		
		//NSLog(@"decoded %i raw bytes, first sample: %i " , numSamples, outBuffer[0] );
		
		outBufferWritePointer = numSamples;
		outBufferReadPointer = 0;
		
	}
	
	
}

-(void) outputSoundData:(MySampleType*)samples numFrames:(int)_num {
	
	// decode this data into outBuffer
	
	
	@synchronized (self) {
	
		
		// int decodedSamples = 0;
		// [self decodeSamples:samples numSamples:samples intoBuffer:outBuffer];
		
		// copy into output buffer
		memcpy(outBuffer , samples , _num * sizeof(MySampleType) );
		outBufferWritePointer = _num;
		outBufferReadPointer = 0;
		
	}
	
	
}

-(void)audioOutputUnit:(id)audioOutputUnit fillFrameBuffer:(MySampleType*)frameBuffer withNumberOfFrames:(UInt32)numberOfFrames {
	
	//NSLog(@"sizeof: %i , %i , %u " , sizeof(MySampleType),  numberOfFrames  , frameBuffer[100] );
	
	//[mainOscillator renderFrames8:frameBuffer numFrames:numberOfFrames];
	
	
	if ( delegate ) {
		
		memcpy(inBuffer+inBufferPointer, frameBuffer, numberOfFrames*sizeof(MySampleType));
		inBufferPointer += numberOfFrames;
		
		if ( inBufferPointer >= SEND_BUFFER_SIZE ) {
			
			// encode samples and push to delegate...
			// [self encodeSamples:inBuffer intoBuffer
			
			static int cnt = 0;
			cnt++;
			if ( cnt > 10 ) {
				
				int size = 2048;
				static uint8_t testCompressedBuffer[2048];
				bzero(testCompressedBuffer, size);
				
				[audioTranscoder encodeSamples:inBuffer numSamples:inBufferPointer intoBuffer:testCompressedBuffer returnSize:&size];
			
				//NSLog(@"Encoded data with output size: %i , num packets: %i " , size , testCompressedBuffer[0] );
				
				[delegate walkieTalkieHasDataToSend:testCompressedBuffer numBytes:size];
				
			}
			
			
			//if ( self.isTalking ) {
			//	[delegate walkieTalkieHasDataToSend:inBuffer numFrames:inBufferPointer];
			//}
			
			inBufferPointer = 0;
		}
		
	}
	
	if ( outBufferWritePointer > 0 ) {
		
		@synchronized (self) {
			
			int numToCopy = fmin(numberOfFrames, (outBufferWritePointer-outBufferReadPointer));
			//memcpy(frameBuffer , outBuffer , numToCopy);
			//outBufferPointer = 0;
			
			for (int i = 0; i < numToCopy; i++) {
				
				float v = outBuffer[outBufferReadPointer+i];
				v *= 1.5;
				frameBuffer[i] = (int)fmin(255, v);
				
				
			}
			outBufferReadPointer += numToCopy;
			
			if ( outBufferReadPointer >= outBufferWritePointer ) outBufferReadPointer = 0;
			
		}
		
	} else {
		memset(frameBuffer, 0 , sizeof(MySampleType)*numberOfFrames);
	}
	
	
}

/*
-(void) outputSoundData:(MySampleType*)samples numFrames:(int)_num {
	
	@synchronized (self) {
		
		// copy into output buffer
		memcpy(outBuffer , samples , _num * sizeof(MySampleType) );
		outBufferPointer = _num;
		
	}
	
	
}

-(void)audioOutputUnit:(id)audioOutputUnit fillFrameBuffer:(MySampleType*)frameBuffer withNumberOfFrames:(UInt32)numberOfFrames {
	
	//NSLog(@"sizeof: %i , %i , %u " , sizeof(MySampleType),  numberOfFrames  , frameBuffer[100] );
	
	//[mainOscillator renderFrames8:frameBuffer numFrames:numberOfFrames];
	
	
	if ( delegate ) {
	
		memcpy(inBuffer, frameBuffer, numberOfFrames*sizeof(MySampleType));
		inBufferPointer = numberOfFrames;
		[delegate walkieTalkieHasDataToSend:inBuffer numFrames:numberOfFrames];
		
	}
	
	if ( outBufferPointer > 0 ) {
		
		@synchronized (self) {
			
			int numToCopy = fmin(numberOfFrames, outBufferPointer);
			//memcpy(frameBuffer , outBuffer , numToCopy);
			//outBufferPointer = 0;
			
			for (int i = 0; i < numToCopy; i++) {
				
				float v = outBuffer[i];
				v *= 1.5;
				frameBuffer[i] = (int)fmin(255, v);
				
			}
			
		}
		
	} else {
		memset(frameBuffer, 0 , sizeof(MySampleType)*numberOfFrames);
	}
	
	
}
*/


/*
-(void)audioOutputUnit:(id)audioOutputUnit fillFrameBufferL:(MySampleType*)frameBuffer fillFrameBufferR:(MySampleType*)frameBuffer2 withNumberOfFrames:(UInt32)numberOfFrames {
	
	//SInt32 * micInput = frameBuffer;
	
	SInt32 *data_ptr_dst = frameBuffer;
	SInt32 *data_ptr_dst2 = frameBuffer2;
	
	memset(data_ptr_dst,0,numberOfFrames*sizeof(MySampleType));
	
	[mainOscillator renderFrames:frameBuffer numFrames:numberOfFrames];
	//[mainOscillator renderFrames8 :frameBuffer numFrames:numberOfFrames];
	
	memcpy(data_ptr_dst2, data_ptr_dst, numberOfFrames*sizeof(MySampleType) );
	
	
}
*/


@end






