//
//  SampleBufferHolder.h
//  ntpA
//
//  Created by Chris Laan on 8/15/11.
//  Copyright 2011 Ramsay Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SampleBufferHolder : NSObject {
	
	NSData * bufferData;
	int width;
	int height;
	int bytesPerRow;
	
	NSTimeInterval timeMismatch;
	
}

@property (nonatomic, retain) NSData * bufferData;
@property (nonatomic, readwrite) int width;
@property (nonatomic, readwrite) int height;
@property (nonatomic, readwrite) int bytesPerRow;
@property (nonatomic, readwrite) NSTimeInterval timeMismatch;

+(SampleBufferHolder*) sampleHolderFromCMBuffer:(CMSampleBufferRef)cmRef;

@end
