/*
 *  AudioEngineHelpers.h
 *  MantuPlay
 *
 *  Created by Markus Sintonen on 7.11.2009.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

static void ERRCHECK(OSStatus result) {
	
    if (result != noErr) {
		
        //NSLog(@"AudioEngine error! (%i)", (int)result);
		NSLog(@"AudioEngine error! (%i)", result);
		
        exit(-1);
		
    }
	
}

static void CalculateBytesForTime (AudioStreamBasicDescription &inDesc, UInt32 inMaxPacketSize, Float64 inSeconds, UInt32 *outBufferSize, UInt32 *outNumPackets) {
	static const unsigned int maxBufferSize = 0x80000;   // limit size to 64K
	static const unsigned int minBufferSize = 0x4000;    // limit size to 16K
	
	if (inDesc.mFramesPerPacket) {
		Float64 numPacketsForTime = inDesc.mSampleRate / inDesc.mFramesPerPacket * inSeconds;
		*outBufferSize = numPacketsForTime * inMaxPacketSize;
	} else {
		*outBufferSize = maxBufferSize > inMaxPacketSize ? maxBufferSize : inMaxPacketSize;
	}
	
	if (*outBufferSize > maxBufferSize && *outBufferSize > inMaxPacketSize) {
		*outBufferSize = maxBufferSize;
	} else {
		if (*outBufferSize < minBufferSize) {
			*outBufferSize = minBufferSize;
        }
	}
    
	*outNumPackets = *outBufferSize / inMaxPacketSize;
}