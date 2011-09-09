//
//  AudioOutputUnit.m
//  MantuPlay
//
//  Created by Markus Sintonen on 7.11.2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AudioOutputUnit.h"
#import "AudioEngineHelpers.h"

@implementation AudioOutputUnit

@synthesize audioFormat, delegate , audioUnit, allowInput;

-(id)initWithDelegate:(id<AudioOutputUnitDelegate>)del {
	
	if ((self = [super init]) != nil) {
		
		self.delegate = del;
		
		//[self setupAudioOutputUnit];
		//[self setupAudioOutputUnitWithInput];
		[self setupAudioOutputUnitWithVoice];
		
		
	}
	
	return self;
}

static OSStatus audioOutputCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, 
								 UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
	if(inBusNumber != 0) return noErr;
	/*
	if(ioData->mNumberBuffers != 1) {
		NSLog(@"Unexpected condition: mNumberBuffers != 1");
		exit(-1);
	}*/
	
	
	
	AudioOutputUnit *audioOutputUnit = (AudioOutputUnit*)inRefCon;
	id<AudioOutputUnitDelegate> delegate = audioOutputUnit.delegate;
	
	if ( audioOutputUnit.allowInput ) {
		OSStatus err = AudioUnitRender(audioOutputUnit.audioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
	}
	
	MySampleType *frameBuffer = ((MySampleType*)ioData->mBuffers[0].mData);

	if ( ioData->mNumberBuffers == 2 ) {
		MySampleType *frameBuffer2 = ((MySampleType*)ioData->mBuffers[1].mData);
		[delegate audioOutputUnit:audioOutputUnit fillFrameBufferL:frameBuffer fillFrameBufferR:frameBuffer2 withNumberOfFrames:inNumberFrames];
	} else {
		[delegate audioOutputUnit:audioOutputUnit fillFrameBuffer:frameBuffer withNumberOfFrames:inNumberFrames];	
	}
	//[delegate audioOutputUnit:audioOutputUnit fillFrameBuffer:frameBuffer withNumberOfFrames:inNumberFrames];
	//[delegate audioOutputUnit:audioOutputUnit fillFrameBuffer:frameBuffer2 withNumberOfFrames:inNumberFrames];
	
    return noErr;
}



-(void) setupAudioOutputUnitWithVoice {
	
	allowInput = YES;
	
	// Describe audio component
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output;
	//desc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
	desc.componentSubType = kAudioUnitSubType_RemoteIO;
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	// Get component
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	
	// Get audio units
	OSStatus status = AudioComponentInstanceNew(inputComponent, &audioUnit);
	ERRCHECK(status);
	
	
	/*
	UInt32 inQuality = 127;
	OSStatus result = AudioUnitSetProperty(audioUnit, kAUVoiceIOProperty_VoiceProcessingQuality, kAudioUnitScope_Global, 1, &inQuality, sizeof(inQuality));
    if (result) NSLog(@"Error setting voice unit quality: %ld\n", result);
    //return result;
	
	ERRCHECK(result);
	*/
	
	UInt32 flag = 1;
	// Enable IO for playback
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_EnableIO, 
								  //kAudioUnitScope_Output,  // for output
								  kAudioUnitScope_Input, 
								  1, // 0 for output, 1 for input
								  &flag, 
								  sizeof(flag));
	ERRCHECK(status);
	
	
	
	[self setAudioFormat];
	
	
	//Apply format
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Input, 
								  0, 
								  &audioFormat, 
								  sizeof(audioFormat));
	ERRCHECK(status);
	
	//Apply format
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Output, 
								  1, 
								  &audioFormat, 
								  sizeof(audioFormat));
	ERRCHECK(status);
	
	
	
	
	// Set up the playback  callback
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = audioOutputCallback;
	callbackStruct.inputProcRefCon = self;
	
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_SetRenderCallback, 
								  //kAudioUnitScope_Global, 
								  kAudioUnitScope_Input,
								  // 1,
								  0,
								  &callbackStruct, 
								  sizeof(callbackStruct));
	ERRCHECK(status);
	
	// Initialise
	status = AudioUnitInitialize(audioUnit);
	ERRCHECK(status);
	
}

-(void) setupAudioOutputUnitWithInput {
	
	allowInput = YES;
	
	// Describe audio component
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output;
	desc.componentSubType = kAudioUnitSubType_RemoteIO;
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	// Get component
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	
	// Get audio units
	OSStatus status = AudioComponentInstanceNew(inputComponent, &audioUnit);
	ERRCHECK(status);
	
	UInt32 flag = 1;
	// Enable IO for playback
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_EnableIO, 
								  //kAudioUnitScope_Output,  // for output
								  kAudioUnitScope_Input, 
								  1, // 0 for output, 1 for input
								  &flag, 
								  sizeof(flag));
	ERRCHECK(status);
	
	
	[self setAudioFormat];
	
	
	//Apply format
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Input, 
								  0, 
								  &audioFormat, 
								  sizeof(audioFormat));
	ERRCHECK(status);
	
	//Apply format
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Output, 
								  1, 
								  &audioFormat, 
								  sizeof(audioFormat));
	ERRCHECK(status);
	
	
	
	// Set up the playback  callback
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = audioOutputCallback;
	callbackStruct.inputProcRefCon = self;
	
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_SetRenderCallback, 
								  //kAudioUnitScope_Global, 
								  kAudioUnitScope_Input,
								  // 1,
								  0,
								  &callbackStruct, 
								  sizeof(callbackStruct));
	ERRCHECK(status);
	
	// Initialise
	status = AudioUnitInitialize(audioUnit);
	ERRCHECK(status);
	
}

-(void) setAudioFormat {
	
	int nChannels = 2;
	BOOL interleaved = NO;
	
	if ( 0 ) { // the default ... 
	
		nChannels = 2;
		interleaved = NO;
	
		audioFormat.mFormatID = kAudioFormatLinearPCM;
		//mFormatFlags = kAudioFormatFlagsCanonical | (kAudioUnitSampleFractionBits << kLinearPCMFormatFlagsSampleFractionShift);
		//-audioFormat.mFormatFlags = kAudioFormatFlagsCanonical;
		audioFormat.mFormatFlags      =  kAudioFormatFlagIsNonInterleaved | kAudioFormatFlagIsSignedInteger;
		audioFormat.mChannelsPerFrame = nChannels;
		audioFormat.mFramesPerPacket = 1;
		audioFormat.mBitsPerChannel = 8 * sizeof(AudioUnitSampleType);
	
		
	} else if ( 0 ) {
		
		nChannels = 2;
		interleaved = NO;
		
		audioFormat.mFormatID = kAudioFormatLinearPCM;
		audioFormat.mFormatFlags = kAudioFormatFlagsCanonical | (kAudioUnitSampleFractionBits << kLinearPCMFormatFlagsSampleFractionShift);
		//-audioFormat.mFormatFlags = kAudioFormatFlagsCanonical;
		//audioFormat.mFormatFlags      =  kAudioFormatFlagIsNonInterleaved | kAudioFormatFlagIsSignedInteger;
		
		audioFormat.mChannelsPerFrame = nChannels;
		audioFormat.mFramesPerPacket = 1;
		audioFormat.mBitsPerChannel = 8 * sizeof(AudioUnitSampleType);
		
	} else if ( 0 ) {
		
		nChannels = 1;
		interleaved = NO;
		
		audioFormat.mFormatID = kAudioFormatLinearPCM;
		//audioFormat.mFormatFlags = kAudioFormatFlagsCanonical | (kAudioUnitSampleFractionBits << kLinearPCMFormatFlagsSampleFractionShift);
		//-audioFormat.mFormatFlags = kAudioFormatFlagsCanonical;
		audioFormat.mFormatFlags      =  kAudioFormatFlagIsNonInterleaved | kAudioFormatFlagIsSignedInteger;
		
		audioFormat.mChannelsPerFrame = nChannels;
		audioFormat.mFramesPerPacket = 1;
		audioFormat.mBitsPerChannel = 8;// * sizeof(AudioUnitSampleType);
		
	}
	
	
	if (interleaved)
		audioFormat.mBytesPerPacket = audioFormat.mBytesPerFrame = nChannels * sizeof(AudioUnitSampleType);
	else {
		audioFormat.mBytesPerPacket = audioFormat.mBytesPerFrame = sizeof(AudioUnitSampleType);
		audioFormat.mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
	}
	

	
	////// override...........
	
	
	
	
	
	
	nChannels = 1;
	interleaved = NO;
	audioFormat.mSampleRate = 11025.0;
	audioFormat.mFormatID = kAudioFormatLinearPCM;
	//audioFormat.mFormatFlags = kAudioFormatFlagsCanonical | (kAudioUnitSampleFractionBits << kLinearPCMFormatFlagsSampleFractionShift);
	//-audioFormat.mFormatFlags = kAudioFormatFlagsCanonical;
	audioFormat.mFormatFlags      =  kAudioFormatFlagIsNonInterleaved;// | kAudioFormatFlagIsSignedInteger;
	
	audioFormat.mChannelsPerFrame = nChannels;
	audioFormat.mFramesPerPacket = 1;
	audioFormat.mBitsPerChannel = 8;// * sizeof(AudioUnitSampleType);
	audioFormat.mBytesPerPacket = audioFormat.mBytesPerFrame = 1;
	//audioFormat.mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
	
	
	
}


#pragma mark -


-(void) setupAudioSession {
	
	NSLog(@"SETUP ENGINE--");
	
	AudioSessionInitialize(NULL, NULL, NULL, NULL);
	
	//UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	//AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	
	//float aBufferLength = 0.05; // In seconds
	
	//float aBufferLength = 0.005; // In seconds // 256
	//float aBufferLength = 0.01; // In seconds  // 512
	//float aBufferLength = (1.0/12.0); // In seconds  // 1024
	//float aBufferLength = 0.1; // In seconds  // 1024
	float aBufferLength = 0.185759637188209;
	
	AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(aBufferLength), &aBufferLength);
	
	
	
	[self overrideSpeaker];
	
	//[self performSelector:@selector(overrideSpeaker) withObject:nil afterDelay:0.2];
	
	AudioSessionSetActive(YES);
	
}

-(void) overrideSpeaker {
	
	// send audio out of the bottom speaker.
	UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;  // 1
	
	AudioSessionSetProperty (
							 kAudioSessionProperty_OverrideAudioRoute,                         // 2
							 sizeof (audioRouteOverride),                                      // 3
							 &audioRouteOverride                                               // 4
							 );
	
}

#pragma mark -

-(void)setupAudioOutputUnit {
	
	allowInput = NO;
	
	// Describe audio component
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output;
	desc.componentSubType = kAudioUnitSubType_RemoteIO;
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	// Get component
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	
	// Get audio units
	OSStatus status = AudioComponentInstanceNew(inputComponent, &audioUnit);
	ERRCHECK(status);
	
	UInt32 flag = 1;
	// Enable IO for playback
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_EnableIO, 
								  kAudioUnitScope_Output,  // for output
								  //kAudioUnitScope_Input, 
								  0, // 0 for output, 1 for input
								  &flag, 
								  sizeof(flag));
	ERRCHECK(status);
	
	//UInt32 one = 1;
	//AudioUnitSetProperty(inRemoteIOUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &one, sizeof(one));
	//AudioUnitSetProperty(inRemoteIOUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &inRenderProc, sizeof(inRenderProc));
	
	
	/*
	// Enable IO for playback
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_StartTimestampsAtZero, 
								  kAudioUnitScope_Output, 
								  0,
								  &flag, 
								  sizeof(flag));
	ERRCHECK(status);
	*/
	
	// Describe format
	audioFormat.mSampleRate			= 44100.00;
	audioFormat.mFormatID			= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked | kAudioFormatFlagsNativeEndian;
	audioFormat.mFramesPerPacket	= 1;
	audioFormat.mChannelsPerFrame	= 2;
	audioFormat.mBitsPerChannel		= 16;
	audioFormat.mBytesPerPacket		= 4;
	audioFormat.mBytesPerFrame		= 4;
	
	/*
	int nChannels = 2;
	
	audioFormat.mFormatID = kAudioFormatLinearPCM;
#if CA_PREFER_FIXED_POINT
	audioFormat.mFormatFlags = kAudioFormatFlagsCanonical | (kAudioUnitSampleFractionBits << kLinearPCMFormatFlagsSampleFractionShift);
#else
	audioFormat.mFormatFlags = kAudioFormatFlagsCanonical;
#endif
	audioFormat.mChannelsPerFrame = nChannels;
	audioFormat.mFramesPerPacket = 1;
	audioFormat.mBitsPerChannel = 8 * sizeof(AudioUnitSampleType);
	
	if ( NO ) // interleaved
		audioFormat.mBytesPerPacket = audioFormat.mBytesPerFrame = nChannels * sizeof(AudioUnitSampleType);
	else {
		audioFormat.mBytesPerPacket = audioFormat.mBytesPerFrame = sizeof(AudioUnitSampleType);
		audioFormat.mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
	}
	*/
	
	
	//Apply format
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Input, 
								  0, 
								  &audioFormat, 
								  sizeof(audioFormat));
	ERRCHECK(status);

	
	
	
	// Set up the playback  callback
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = audioOutputCallback;
	callbackStruct.inputProcRefCon = self;
	
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_SetRenderCallback, 
								  kAudioUnitScope_Global, 
								  //kAudioUnitScope_Input,
								  1,
								  //0,
								  &callbackStruct, 
								  sizeof(callbackStruct));
	ERRCHECK(status);
	
	// Initialise
	status = AudioUnitInitialize(audioUnit);
	ERRCHECK(status);
}

-(void)start {
	
	[self setupAudioSession];
	
	OSStatus result = AudioOutputUnitStart(audioUnit);
	ERRCHECK(result);
	
}
-(void)stop {
	OSStatus result = AudioOutputUnitStop(audioUnit);
	ERRCHECK(result);
}

-(void)unloadAudioOutputUnit {
	OSStatus status = AudioComponentInstanceDispose(audioUnit);
	ERRCHECK(status);
}

- (void)dealloc {
	[self unloadAudioOutputUnit];
    [super dealloc];
}

@end
