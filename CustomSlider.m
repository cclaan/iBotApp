//
//  CustomSlider.m
//  RealDJ
//
//  Created by Chris Laan on 8/25/10.
//  Copyright 2010 Laan Labs. All rights reserved.
//

#import "CustomSlider.h"
#import <QuartzCore/QuartzCore.h>

#ifndef CLAMP
#define CLAMP(min,x,max) (x < min ? min : (x > max ? max : x))
#endif

@interface CustomSlider()

-(void) tweenSliderValue;
-(void) beginAutoSlide;

@end


@implementation CustomSlider

@synthesize value;
@synthesize trackHeadWidth;
@synthesize minimumValue;
@synthesize maximumValue;
@synthesize centerValue;
@synthesize supportsDoubleClickToCenter;
@synthesize supportsHoldToSlide;
@synthesize isDragging;
@synthesize trackHead;

@synthesize autoSlideDuration;

@synthesize supportsTapIncrement, tapIncrement;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
		self.multipleTouchEnabled = YES;
		trackHead.multipleTouchEnabled = YES;
		
		self.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0.5 alpha:0.2];
		//self.backgroundColor = [UIColor clearColor];
		
		trackHeadWidth = 45;
		_width = self.frame.size.width;
		_height = self.frame.size.height;
		trackHeadHeight = _height;
		
		trackHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, trackHeadWidth, trackHeadHeight-4)];
		trackHead.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.2];
		//trackHead.backgroundColor = [UIColor clearColor];
		[self addSubview:trackHead];
		
		UITapGestureRecognizer* t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
		t.numberOfTapsRequired = 2;
		[trackHead addGestureRecognizer:t];
		
		supportsTapIncrement = NO;
		
		/*UIImage * thumbImage = [UIImage imageNamed:@"crossfade_thumb.png"];
		//trackHead.layer.contents = thumbImage.CGImage;
		
		thumbImageView = [[UIImageView alloc] initWithImage:thumbImage];
		thumbImageView.userInteractionEnabled = NO;
		thumbImageView.contentMode = UIViewContentModeCenter;
		*/
		
		//[trackHead addSubview:thumbImageView];
		
		minimumValue = 0.0;
		maximumValue = 1.0;
		
		centerValue = 0.5;
		
		supportsDoubleClickToCenter = YES;
		supportsHoldToSlide = YES;
		autoSlideDuration = 1.5;
		
		tapIncrement = 0.01;
		
		slideTimer = nil;
		
		
		
    }
    return self;
}

-(void) layoutSubviews {
	
	[super layoutSubviews];
	
	
	//trackHeadWidth = 50;
	
	//float xVal = value*(self.frame.size.width - trackHeadWidth);
	
	//float xVal = ((value - minimumValue) / (maximumValue-minimumValue))*(_width - trackHeadWidth);
	float border = 0;
	
	float xVal = (border + trackHeadWidth/2.0) + ((value - minimumValue) / (maximumValue-minimumValue))*(_width - (trackHeadWidth+border*2));
	
	//float val = minimumValue + (maximumValue-minimumValue)*(xVal/(_width - trackHeadWidth));
	
	trackHead.frame = CGRectMake(0, 0, trackHeadWidth, trackHeadHeight-4 );
	
	trackHead.center = CGPointMake(xVal, _height/2.0);
	//trackHead.frame = CGRectMake(xVal, 0, trackHeadWidth, trackHeadHeight );
	//thumbImageView.frame = trackHead.bounds;
	
	
}

-(void) setTrackHeadWidth:(int) tw {
	
	trackHeadWidth = tw;
	[self layoutSubviews];
	
}



-(void) setValue:(float) v {
	
	value = v;
	[self layoutSubviews];
	
}

-(void) beginAutoSlide {
	
	if ( !supportsHoldToSlide ) return;
	
	//NSLog(@"begin autoslide");
	
	[self stopAutoSliding];
	
	//slideTimer = [NSTimer timerWithTimeInterval:(1.0/30.0) target:self selector:@selector(tweenSliderValue) userInfo:nil repeats:YES];
	slideTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/30.) target:self selector:@selector(tweenSliderValue) userInfo:nil repeats:YES];
	
	isAutoSliding = YES;
	
	if ( startPoint.x <= _width/2.0 ) {
		autoSlideType = AUTO_SLIDE_LEFT;
	} else {
		autoSlideType = AUTO_SLIDE_RIGHT;
	}
				
}

-(void) beginAutoSlideToCenter {
	
	if ( !supportsDoubleClickToCenter ) return;
	
	//NSLog(@"begin autoslide center");
	
	[self stopAutoSliding];
	
	slideTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/30.) target:self selector:@selector(tweenSliderValue) userInfo:nil repeats:YES];
	
	isAutoSliding = YES;
	
	autoSlideType = AUTO_SLIDE_CENTER;
	
}

-(void) tweenSliderValue {
	
	//NSLog(@"tween");
	
	float inc = (1.0/30.0) / autoSlideDuration;
	
	if ( autoSlideType == AUTO_SLIDE_LEFT ) {
		// left
		
		value = value - inc;
		
	} else if ( autoSlideType == AUTO_SLIDE_RIGHT ) {
		// right
		
		value = value + inc;
		
		
	} else if ( autoSlideType == AUTO_SLIDE_CENTER ) {
		
		if ( value < centerValue ) {
			value = value + inc;
		} else if ( value > centerValue ) {
			value = value - inc;		
		}
		
		if ( fabs(value - centerValue) < 0.02 ) {
			
			value = centerValue;
			
			[self stopAutoSliding];
			
		}
		
	}
	
	if ( (value >= maximumValue) || (value <= minimumValue) ) {
		
		//CLAMP(0.0, value , 1.0 );
		if ( value >= maximumValue ) value = maximumValue;
		if ( value <= minimumValue ) value = minimumValue;
		
		[self stopAutoSliding];
		
	}
	
	[self layoutSubviews];
	
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	
	
}

-(void) stopAutoSliding {
	
	if ( slideTimer ) {
		[slideTimer invalidate];
		slideTimer=nil;
	}
	
	isAutoSliding = NO;
	
}

-(void) didDoubleTap:(UITapGestureRecognizer*)g { 
	
	if ( g.state == UIGestureRecognizerStateEnded ) {
		
		[self beginAutoSlideToCenter];
			
	}
	
	
}


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	
	
	//[super touchesBegan:touches withEvent:event];

	//UITouch * touch = [[event allTouches] anyObject];	
	
	UITouch * touch = [touches anyObject];	
	
	startPoint = [touch locationInView:self];
	
	moveCount = 0;
	
	if ( [trackHead pointInside:[touch locationInView:trackHead] withEvent:event] ) {
		
		
		if ( isAutoSliding ) {
			
			[self stopAutoSliding];
			
		}
		
		isDragging = YES;
		
		touchOffset = startPoint.x - trackHead.frame.origin.x;
		
	} else {
		
		// maybe starting a hold down
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginAutoSlide) object:nil];
		[self performSelector:@selector(beginAutoSlide) withObject:nil afterDelay:0.6];
		
		
	}
	
}


- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	
	//[super touchesMoved:touches withEvent:event];
	
	UITouch * touch = [touches anyObject];	
	
	if ( isDragging ) {
		
		
		//UITouch * touch = [[event allTouches] anyObject];	
		//UITouch * touch = [touches anyObject];	
		
		CGPoint p = [touch locationInView:self];
		
		float xVal = p.x - touchOffset;
		
		//float val = xVal/(self.frame.size.width - trackHeadWidth);
		
		//float _minimumValue = minimumValue - 1.2;
		//float _maximumValue = maximumValue + 1.2; 
		
		float val = minimumValue + (maximumValue-minimumValue)*(xVal/(_width - trackHeadWidth));
		
		val = CLAMP(minimumValue , val , maximumValue );
		
		
		
		if ( val != value ) {
			value = val;
			[self sendActionsForControlEvents:UIControlEventValueChanged];
			
		}
		
		[self layoutSubviews];
		
	} else if ( ![self pointInside:[touch locationInView:self] withEvent:event] ) {
		
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginAutoSlide) object:nil];
		
	} else {
		
		moveCount ++;
		
		if ( moveCount > 12 ) {
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginAutoSlide) object:nil];
		}
		
	}
	
	
}


- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	
	moveCount = 0;
	
	//[super touchesEnded:touches withEvent:event];
	
	if ( isDragging ) isDragging = NO;
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginAutoSlide) object:nil];
	
	/*
	if ( isAutoSliding ) {
		
		if ( slideTimer ) {
			[slideTimer invalidate];
			slideTimer=nil;
		}
		
		isAutoSliding = NO;
		
	}*/
	
	//UITouch * t = [[event allTouches] anyObject];
	UITouch * t = [touches anyObject];
	
	/*
	if ( t.tapCount == 2 ) {
		
		
		if ( [trackHead pointInside:[t locationInView:trackHead] withEvent:event] ) {
			

			[self beginAutoSlideToCenter];
			
		} else {
			
			// why would you do this... 
			// were 2 taps being reported often ?
			
			// if touch isnt in trackhead, increment value tiny amount
			
			if ( startPoint.x <= trackHead.center.x ) {
				
				value = value - tapIncrement;
				
			} else {
				
				value = value + tapIncrement;
				
			}
			
			if ( value >= maximumValue ) value = maximumValue;
			if ( value <= minimumValue ) value = minimumValue;
			
			[self layoutSubviews];
			[self sendActionsForControlEvents:UIControlEventValueChanged];
			
			
		}
		
		
	} else 
	*/
	if ( supportsTapIncrement ) /*if ( t.tapCount == 1 )*/ {
	
		if ( ![trackHead pointInside:[t locationInView:trackHead] withEvent:event] ) {
			
			// if touch isnt in trackhead, increment value tiny amount
			
			if ( startPoint.x <= trackHead.center.x ) {
				
				value = value - tapIncrement;
				
			} else {
				
				value = value + tapIncrement;
				
			}
			
			if ( value >= maximumValue ) value = maximumValue;
			if ( value <= minimumValue ) value = minimumValue;
	
			[self layoutSubviews];
			[self sendActionsForControlEvents:UIControlEventValueChanged];
			
		}
	}
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
	
	//[super touchesEnded:touches withEvent:event];
	
	if ( isDragging ) isDragging = NO;
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginAutoSlide) object:nil];
	
	/*
	if ( isAutoSliding ) {
		
		if ( slideTimer ) {
			[slideTimer invalidate];
			slideTimer=nil;
		}
		
		isAutoSliding = NO;
		
	}
	*/
	
}

- (void)dealloc {
    [super dealloc];
}


@end
