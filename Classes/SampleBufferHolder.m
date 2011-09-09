//
//  SampleBufferHolder.m
//  ntpA
//
//  Created by Chris Laan on 8/15/11.
//  Copyright 2011 Ramsay Consulting. All rights reserved.
//

#import "SampleBufferHolder.h"


@implementation SampleBufferHolder

@synthesize bytesPerRow, height, width, bufferData, timeMismatch;

- (void) dealloc
{
	[bufferData release];
	bufferData = nil;
	
	[super dealloc];
}


+(SampleBufferHolder*) sampleHolderFromCMBuffer:(CMSampleBufferRef)cmRef {
	
	SampleBufferHolder * holder = [[[SampleBufferHolder alloc] init] autorelease];
	
	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(cmRef); 
    
	CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer 
	
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image 
    holder.bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    holder.width = CVPixelBufferGetWidth(imageBuffer); 
    holder.height = CVPixelBufferGetHeight(imageBuffer); 
	holder.bufferData = [NSData dataWithBytes:baseAddress length:(holder.bytesPerRow*holder.height)];
	
	CVPixelBufferUnlockBaseAddress(imageBuffer,0); 
	
	return holder;
	
}


@end
