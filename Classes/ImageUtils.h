

#import <UIKit/UIKit.h>

@interface UIImage (UIImageUtils)
- (UIImage*)scaleAndRotateImage:(float)maxResolution;
- (UIImage*)scaleAndRotateImageThreaded:(float)maxResolution;
- (UIImage*)scaleAndRotateImageThreaded:(float)maxResolution withDesiredOrientation:(UIImageOrientation) desiredOrientation;
- (void) logDescription;

- (UIImage*)scaleAndRotateImageToSize:(CGSize)desiredSize;
- (UIImage*)scaleAndRotateImageToSize:(CGSize)desiredSize withDesiredOrientation:(UIImageOrientation) desiredOrientation;

@end


