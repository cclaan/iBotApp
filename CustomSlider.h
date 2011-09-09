//
//  CustomSlider.h
//  RealDJ
//
//  Created by Chris Laan on 8/25/10.
//  Copyright 2010 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum AutoSlideType {
	AUTO_SLIDE_NONE,
	AUTO_SLIDE_LEFT,
	AUTO_SLIDE_RIGHT,
	AUTO_SLIDE_CENTER
} AutoSlideType;

@interface CustomSlider : UIControl {
	
	UIView * trackHead;
	float value;
	
	float minimumValue;
	float maximumValue;
	
	CGPoint startPoint;
	CGPoint lastPoint;
	
	BOOL isDragging;
	
	int trackHeadHeight;
	int trackHeadWidth;
	int touchOffset;
	
	BOOL isAutoSliding;
	AutoSlideType autoSlideType;
	NSTimer * slideTimer;
	
	float centerValue;
	BOOL supportsDoubleClickToCenter;
	BOOL supportsHoldToSlide;
	
	BOOL supportsHoldToNudge;
	
	BOOL supportsTapIncrement;
	float autoSlideDuration;
	
	UIImageView * thumbImageView;
	
	int _width;
	int _height;
	
	int moveCount;
	
	float tapIncrement;
	
}

@property (nonatomic ,assign) UIView * trackHead;

@property float tapIncrement;

@property BOOL supportsHoldToSlide;
@property BOOL supportsTapIncrement;
@property BOOL supportsDoubleClickToCenter;
@property float autoSlideDuration;

@property float centerValue;


@property float minimumValue;
@property float maximumValue;

@property float value;
@property int trackHeadWidth;

@property BOOL isDragging;

@end
