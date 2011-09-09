//
//  AACAudioTranscoder.h
//  iBotApp
//
//  Created by Chris Laan on 9/8/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

// this uses the audioconverter in a basic way
// to convert a known few packets from/to compressed aac 
// it also has the streaming part built in so it packs the data into a little chunk with a header of
// how many audio packets it contains, and the descriptions packed after that.

#import <Foundation/Foundation.h>
#import "AudioOutputUnit.h"

#define RAW_BUFFER_SIZE 1024*6
#define COMPRESSED_BUFFER_SIZE 1024*4

#define NUM_FRAMES_PER_PACKET 512
#define SAMPLE_RATE 16000.0

//#define NUM_PACKETS

//typedef UInt8 MySampleType;

typedef struct AudioConverterSettings {
	
	AudioConverterRef audioEncoder;
	AudioConverterRef audioDecoder;
	
	AudioStreamBasicDescription inputFormat;
	AudioStreamBasicDescription outputFormat;
	
	AudioStreamPacketDescription * encodedPacketDescriptions;
	
	MySampleType * rawSampleBuffer;
	int rawSampleBufferSize;
	
	uint8_t * compressedBuffer;
	int compressedBufferSize;
	
	int outputBufferByteSize;
	int numPacketsInCompressedBuffer;
	
	
} AudioConverterSettings;



@interface AACAudioTranscoder : NSObject {
	
	AudioConverterRef audioEncoder;
	AudioConverterRef audioDecoder;
	
	AudioConverterSettings converterSettings;
	
	uint8_t compressedBuffer[COMPRESSED_BUFFER_SIZE];
	int compressedBufferSize;
	
	//MySampleType inBuffer[COMPRESSED_BUFFER_SIZE];
	
	
	AudioStreamPacketDescription encodedPacketDescriptions[20];
	
	
}

-(void) encodeSamples:(MySampleType*)_samples numSamples:(int)_num intoBuffer:(uint8_t*)buffer returnSize:(int*)_numBytes;

-(void) decodeBuffer:(uint8_t*)buffer withSize:(int)numBytes intoSampleBuffer:(MySampleType*) _samples returnSamples:(int*)numSamples;




@end







