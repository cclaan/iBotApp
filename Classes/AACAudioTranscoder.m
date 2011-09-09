//
//  AACAudioTranscoder.m
//  iBotApp
//
//  Created by Chris Laan on 9/8/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "AACAudioTranscoder.h"

static OSStatus EncoderInputDataProc (
									  AudioConverterRef             inAudioConverter,
									  UInt32                        *ioNumberDataPackets,
									  AudioBufferList               *ioData,
									  AudioStreamPacketDescription  **outDataPacketDescription,
									  void                          *inUserData
									  ) 
{
	
	AudioConverterSettings *settings = (AudioConverterSettings *)inUserData;
	
	UInt32 numPacketsNeeded = (*ioNumberDataPackets);
	
	NSLog(@"Encoder needs %u frames" , numPacketsNeeded  );
	
	ioData->mNumberBuffers = 1;
	ioData->mBuffers[0].mData           = settings->rawSampleBuffer;
	ioData->mBuffers[0].mDataByteSize   = numPacketsNeeded * sizeof(MySampleType);
	ioData->mBuffers[0].mNumberChannels = 1;
	
	//settings->encodeBufferPointer += (numPacketsNeeded);
	
	return noErr;	
	
}


static OSStatus DecoderInputDataProc (
									  AudioConverterRef             inAudioConverter,
									  UInt32                        *ioNumberDataPackets,
									  AudioBufferList               *ioData,
									  AudioStreamPacketDescription  **outDataPacketDescription,
									  void                          *inUserData
									  ) 
{
	
	AudioConverterSettings *settings = (AudioConverterSettings *)inUserData;
	
	UInt32 numPacketsNeeded = (*ioNumberDataPackets);
	
	//NSLog(@"Decoder needs %i packets " , numPacketsNeeded );
	
	
	//if ( outDataPacketDescription != NULL ) {
		//NSLog(@"expecting packet decsriptions ! ");
		//outDataPacketDescription = NULL;
	//}
	
	
	*outDataPacketDescription = settings->encodedPacketDescriptions;
	
	
	ioData->mNumberBuffers = 1;
	ioData->mBuffers[0].mData           = settings->compressedBuffer;
	ioData->mBuffers[0].mDataByteSize   = settings->compressedBufferSize;
	ioData->mBuffers[0].mNumberChannels = 1;
	
	
	*ioNumberDataPackets = settings->numPacketsInCompressedBuffer;
	
	//NSLog(@".. but i returned %i packets instead" , settings->numPacketsInCompressedBuffer );
	
	return noErr;	
	
}





@interface AACAudioTranscoder()

-(void) createConverters;
-(void) errCheck:(OSStatus)err;

@end




@implementation AACAudioTranscoder

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		[self createConverters];
		
	}
	return self;
}



-(void) encodeSamples:(MySampleType*)_samples numSamples:(int)_num intoBuffer:(uint8_t*)outBuffer returnSize:(int*)_numBytes {

	int numPackets = _num / NUM_FRAMES_PER_PACKET;
	int inputBufferSize = *_numBytes;
	
	converterSettings.rawSampleBuffer = _samples;
	
	//NSLog(@"Attempting to encode %i samples into %i packets " , _num , numPackets );
	
	/////////////
	
	// On input, must point to a block of memory capable of holding the number
	// of packet descriptions specified in the ioOutputDataPacketSize parameter.
	//AudioStreamPacketDescription encodedPacketDescription[5];
	bzero(&encodedPacketDescriptions, sizeof(AudioStreamPacketDescription)*20);
	
	// On input, the size of the output buffer (in the outOutputData parameter), expressed in number packets in the audio converter’s output format. 
	// On output, the number of packets of converted data that were written to the output buffer.
	UInt32 numPacketsToEncode = numPackets;
	
	bzero(outBuffer, inputBufferSize );
	bzero(compressedBuffer, inputBufferSize );
	
	// actual data storage for encoded data
	AudioBufferList outputBuffers;
    outputBuffers.mNumberBuffers              = 1;
    outputBuffers.mBuffers[0].mNumberChannels = 1;
    outputBuffers.mBuffers[0].mDataByteSize   = inputBufferSize;
    outputBuffers.mBuffers[0].mData           = compressedBuffer;
	
	
	AudioConverterFillComplexBuffer(converterSettings.audioEncoder,
									EncoderInputDataProc,
									&converterSettings,
									&numPacketsToEncode,
									&outputBuffers,
									encodedPacketDescriptions);
	
	
	//-NSLog(@"encoded %u packets , bytes: %i " , numPacketsToEncode , outputBuffers.mBuffers[0].mDataByteSize );
	
	/*
	for (int i = 0; i < outputBuffers.mBuffers[0].mDataByteSize; i++) {
		printf("%i " , compressedBuffer[i] );
	}
	
	printf("\n");
	
	for (int i = 0; i < numPacketsToEncode; i++) {
		
		NSLog(@"Packet Bytes: %i , offset: %i , frames: %i ", encodedPacketDescriptions[i].mDataByteSize, encodedPacketDescriptions[i].mStartOffset , encodedPacketDescriptions[i].mVariableFramesInPacket  );
		
	}
	*/
	
	
	int totalPackageSize = 1 + (numPacketsToEncode*sizeof(AudioStreamPacketDescription)) + outputBuffers.mBuffers[0].mDataByteSize;
	
	outBuffer[0] = numPacketsToEncode;
	memcpy(outBuffer+1, encodedPacketDescriptions , numPacketsToEncode*sizeof(AudioStreamPacketDescription) );
	memcpy(outBuffer+1+numPacketsToEncode*sizeof(AudioStreamPacketDescription) , compressedBuffer, outputBuffers.mBuffers[0].mDataByteSize);
	
	*_numBytes = totalPackageSize;
	
	//converterSettings.outputBufferByteSize = outputBuffers.mBuffers[0].mDataByteSize;
	//converterSettings.numPacketsInOutputBuffer = ioOutputDataPacketSize;
	
	
}

-(void) decodeBuffer:(uint8_t*)buffer withSize:(int)numBytes intoSampleBuffer:(MySampleType*) _samples returnSamples:(int*)numSamples {
	
	int numPackets = buffer[0];
	int outputBufferSize = *numSamples;
	
	AudioStreamPacketDescription descs[10];
	memcpy(descs , buffer+1 , sizeof(AudioStreamPacketDescription)*numPackets );
	
	int dataSize = numBytes - 1 - sizeof(AudioStreamPacketDescription)*numPackets;
	
	memcpy(compressedBuffer , buffer+1+sizeof(AudioStreamPacketDescription)*numPackets, dataSize );
	
	converterSettings.compressedBuffer = compressedBuffer;
	converterSettings.compressedBufferSize = dataSize;
	converterSettings.numPacketsInCompressedBuffer = numPackets;
	
	converterSettings.encodedPacketDescriptions = descs;
	
	/////
	
	UInt32 numFramesToDecode = NUM_FRAMES_PER_PACKET * numPackets;
	
	bzero(_samples, numFramesToDecode );
	
	// actual data storage for decoded data
	AudioBufferList decodedBuffers;
    decodedBuffers.mNumberBuffers              = 1;
    decodedBuffers.mBuffers[0].mNumberChannels = 1;
    decodedBuffers.mBuffers[0].mDataByteSize   = numFramesToDecode;
    decodedBuffers.mBuffers[0].mData           = _samples;
	
	AudioConverterFillComplexBuffer(converterSettings.audioDecoder, 
									DecoderInputDataProc,
									&converterSettings, 
									&numFramesToDecode, 
									&decodedBuffers, 
									NULL); // no packet desc for output pcm
	
	
	NSLog(@"decoded %u packets , bytes: %i " , numFramesToDecode , decodedBuffers.mBuffers[0].mDataByteSize );
	
	*numSamples = numFramesToDecode;
	
	
}


#pragma mark -
#pragma mark Create Converters 


-(void) createConverters {
	
	int nChannels = 1;
	
	AudioStreamBasicDescription inputFormat;
	inputFormat.mSampleRate = SAMPLE_RATE;
	inputFormat.mFormatID = kAudioFormatLinearPCM;
	inputFormat.mFormatFlags =  kAudioFormatFlagIsNonInterleaved;// | kAudioFormatFlagIsSignedInteger;
	inputFormat.mChannelsPerFrame = nChannels;
	inputFormat.mFramesPerPacket = 1;
	inputFormat.mBitsPerChannel = 8 * sizeof(MySampleType);
	inputFormat.mBytesPerPacket = inputFormat.mBytesPerFrame = sizeof(MySampleType);
	//audioFormat.mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
	
	converterSettings.inputFormat = inputFormat;
	
	//////////////////
	
	NSLog(@"** creating encoder!! sample rate: %f" , converterSettings.inputFormat.mSampleRate );
	
	AudioStreamBasicDescription outputFormat;
	outputFormat.mSampleRate       = SAMPLE_RATE;
	outputFormat.mChannelsPerFrame = 1;
	outputFormat.mBitsPerChannel   = 0;
	outputFormat.mBytesPerPacket   = 0;
	outputFormat.mFramesPerPacket  = 512;
	outputFormat.mBytesPerFrame    = 0;
	outputFormat.mFormatID         = kAudioFormatMPEG4AAC_LD;
	//outputFormat.mFormatID         = kAudioFormatAppleIMA4;
	//outputFormat.mFormatID         = kAudioFormatAMR;
	//outputFormat.mFormatID         = kAudioFormatiLBC;  // no
	outputFormat.mFormatFlags      = 0;
	
	converterSettings.outputFormat = outputFormat;
	
	OSStatus err = AudioConverterNew(&converterSettings.inputFormat, &converterSettings.outputFormat, &audioEncoder);
	
	
	UInt32 tmp, tmpsiz = sizeof( tmp );
	
    // set encoder quality to maximum
    tmp = kAudioConverterQuality_Low;
    AudioConverterSetProperty( audioEncoder, kAudioConverterCodecQuality,
                              sizeof( tmp ), &tmp );
	
	
	
    // set bitrate
    tmp = 25600 / 2;
    AudioConverterSetProperty( audioEncoder, kAudioConverterEncodeBitRate,
                              sizeof( tmp ), &tmp );
	
	
	
	AudioStreamBasicDescription outputFormat2;
	// get real output
    tmpsiz = sizeof( outputFormat2 );
    AudioConverterGetProperty( audioEncoder,
                              kAudioConverterCurrentOutputStreamDescription,
                              &tmpsiz, &outputFormat2 );
	
	
	NSLog(@"output format frames per packet: %i " , outputFormat2.mBytesPerPacket, outputFormat2.mFramesPerPacket  );
	
	converterSettings.outputFormat = outputFormat;
	
	converterSettings.audioEncoder = audioEncoder;
	
	if ( err != noErr ) {
		[self errCheck:err];
	}
	
	
	////// decoder
	
	NSLog(@"** creating decoder!!");
	
	err = AudioConverterNew(&converterSettings.outputFormat, &converterSettings.inputFormat, &audioDecoder);
	converterSettings.audioDecoder = audioDecoder;
	
	if ( err != noErr ) {
		[self errCheck:err];
	}
	
	
	
	
	
}




-(void) errCheck:(OSStatus)err {
	
	switch(err) {
		case kAudioConverterErr_FormatNotSupported:
			NSLog(@"kAudioConverterErr_FormatNotSupported");
			break;
		case kAudioConverterErr_OperationNotSupported:
			NSLog(@"kAudioConverterErr_OperationNotSupported");
			
			break;
		case kAudioConverterErr_PropertyNotSupported:
			NSLog(@"kAudioConverterErr_PropertyNotSupported");
			
			break;
		case kAudioConverterErr_InvalidInputSize:
			NSLog(@"kAudioConverterErr_InvalidInputSize");
			
			break;
		case kAudioConverterErr_InvalidOutputSize:
			NSLog(@"kAudioConverterErr_InvalidOutputSize");
			
			break;
		case kAudioConverterErr_UnspecifiedError:
			NSLog(@"kAudioConverterErr_UnspecifiedError");
			
			break;
		case kAudioConverterErr_BadPropertySizeError:
			NSLog(@"kAudioConverterErr_BadPropertySizeError");
			
			break;
		case kAudioConverterErr_RequiresPacketDescriptionsError:
			NSLog(@"kAudioConverterErr_RequiresPacketDescriptionsError");
			
			break;
		case kAudioConverterErr_InputSampleRateOutOfRange:
			NSLog(@"kAudioConverterErr_InputSampleRateOutOfRange");
			
			break;
		case kAudioConverterErr_OutputSampleRateOutOfRange:
			NSLog(@"kAudioConverterErr_OutputSampleRateOutOfRange");
			
			break;
	}
	
}







@end














