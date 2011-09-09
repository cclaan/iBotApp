

#import "ImageUtils.h"


@implementation UIImage(UIImageUtils)

- (void) logDescription {
	
	int bitsPerPixel = CGImageGetBitsPerPixel(self.CGImage);
	int bytesPerRow = CGImageGetBytesPerRow(self.CGImage);
	int bitsPerComponent = CGImageGetBitsPerComponent(self.CGImage);
	
	NSLog(@"Bits Per Pixel: %i " , bitsPerPixel);
	NSLog(@"Bytes Per Row: %i " , bytesPerRow);
	NSLog(@"Bits Per Component: %i " , bitsPerComponent);
	
	const CGFloat * dec = CGImageGetDecode(self.CGImage);
	NSLog(@"Decode: %3.0f" , dec);
	
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
	NSLog(@"Alpha Info:");
	
	switch (alphaInfo) {
		case kCGImageAlphaNone:
			NSLog(@"kCGImageAlphaNone");
			break;
		case kCGImageAlphaPremultipliedLast:
			NSLog(@"kCGImageAlphaPremultipliedLast");
			break;
		case kCGImageAlphaPremultipliedFirst:
			NSLog(@"kCGImageAlphaPremultipliedFirst");
			break;
		case kCGImageAlphaLast:
			NSLog(@"kCGImageAlphaLast");
			break;
		case kCGImageAlphaFirst:
			NSLog(@"kCGImageAlphaFirst");
			break;
		case kCGImageAlphaNoneSkipLast:
			NSLog(@"kCGImageAlphaNoneSkipLast");
			break;
		case kCGImageAlphaNoneSkipFirst:
			NSLog(@"kCGImageAlphaNoneSkipFirst");
			break;
		default:
			break;
	}
	
	
	CGColorSpaceRef cspace = CGImageGetColorSpace(self.CGImage);
	CGBitmapInfo bInfo = CGImageGetBitmapInfo(self.CGImage);
	/*
	switch (bInfo&kCGBitmapAlphaInfoMask) {
		case kCGImageAlphaFirst:
			NSLog(@"kCGBitmapAlphaInfoMask");
			break;
		case kCGImageAlphaLast:
			NSLog(@"kCGImageAlphaLast");
			break;
		case kCGImageAlphaNoneSkipFirst:
			NSLog(@"kCGImageAlphaNoneSkipFirst");
			break;
		case kCGImageAlphaNoneSkipLast:
			NSLog(@"kCGImageAlphaNoneSkipLast");
			break;
		case kCGImageAlphaNone:
			NSLog(@"kCGImageAlphaNone");
			break;
		case kCGImageAlphaPremultipliedLast:
			NSLog(@"kCGImageAlphaPremultipliedLast");
			break;
		case kCGImageAlphaPremultipliedFirst:
			NSLog(@"kCGImageAlphaPremultipliedFirst");
			break;
		case kCGImageAlphaOnly:
			NSLog(@"kCGImageAlphaOnly");
			break;
		default:
			break;
	}
	*/
	//NSLog(@"Bitmap Info: %i " , bInfo);
	
	if ( bInfo &  kCGBitmapFloatComponents ) {
		NSLog(@"Has kCGBitmapFloatComponents");
	}
	
	switch (bInfo&kCGBitmapByteOrderMask) {
		case kCGBitmapByteOrderMask:
			NSLog(@"kCGBitmapByteOrderMask");
			break;
		case kCGBitmapByteOrder16Little:
			NSLog(@"kCGBitmapByteOrder16Little");
			break;
		case kCGBitmapByteOrder32Little:
			NSLog(@"kCGBitmapByteOrder32Little");
			break;
		case kCGBitmapByteOrder16Big:
			NSLog(@"kCGBitmapByteOrder16Big");
			break;
		case kCGBitmapByteOrder32Big:
			NSLog(@"kCGBitmapByteOrder32Big");
			break;
		case kCGBitmapByteOrderDefault:
			NSLog(@"kCGBitmapByteOrderDefault");
			break;
		default:
			break;
	}
	
	
	
	
}

- (UIImage*) scaleAndRotateImage:(float)maxRelosution
{
    CGImageRef imgRef = self.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > maxRelosution || height > maxRelosution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = maxRelosution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = maxRelosution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = self.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}


- (UIImage*)scaleAndRotateImageToSize:(CGSize)desiredSize {
	[self scaleAndRotateImageToSize:desiredSize withDesiredOrientation:-1];
}

- (UIImage*)scaleAndRotateImageToSize:(CGSize)desiredSize withDesiredOrientation:(UIImageOrientation) desiredOrientation {
	
	//maxResolution = roundf(maxResolution);
	
	CGImageRef imgRef = self.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
	//NSLog(@"CGWidth: %f , w: %f " , width , height );
	
    CGAffineTransform transform = CGAffineTransformIdentity;
	
    CGRect bounds = CGRectMake(0, 0, desiredSize.width, desiredSize.height);
	
	float wRatio = desiredSize.width / width;
	float hRatio = desiredSize.height / height;
	CGFloat scaleRatio = 1.0;
	
	if ( wRatio > hRatio ) {
		scaleRatio = wRatio;
	} else if ( hRatio >= wRatio ) {
		scaleRatio = hRatio;
	}
	
	if ( fabs(scaleRatio-1.0) < 0.01 ) scaleRatio = 1.0;
	
	//NSLog(@"Ratio: %f New Width: %f , w: %f " , scaleRatio, bounds.size.width,bounds.size.height );
	
	// doesnt seem to scale the image... and orientation was wrong, but probably just need to pass the opposite one..
	//UIImage * img = [UIImage imageWithCGImage:self.CGImage scale:scaleRatio orientation:desiredOrientation];
	//return img;
	
    //CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
	
    UIImageOrientation orient = self.imageOrientation;
	
	if (desiredOrientation != -1) {
		orient = desiredOrientation;
	}
	//self.imageOrientation = UIImageOrientationUp;
	
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
	
	bounds.size.width = roundf(bounds.size.width);
    bounds.size.height = roundf(bounds.size.height);
	
	//NSLog(@"Ratio: %f New Width: %f , w: %f " , scaleRatio, bounds.size.width,bounds.size.height );
	
	if ( (scaleRatio == 1) && CGAffineTransformIsIdentity(transform) ) {
		
		
		NSLog(@"didnt have to do anything");
		// have to do this to get rid of the orientation info, otherwise it saves all skewed
		return [UIImage imageWithCGImage:self.CGImage];
	}
	

	int bitsPerPixel = CGImageGetBitsPerPixel(imgRef);
	int bytesPerRow = bitsPerPixel/8*bounds.size.width;
	int bitsPerComponent = CGImageGetBitsPerComponent(imgRef);
	
	// this has worked for full 1600x1200 etc...
	CGContextRef bitmap = CGBitmapContextCreate(NULL, bounds.size.width, bounds.size.height, bitsPerComponent, bytesPerRow, CGImageGetColorSpace(imgRef), CGImageGetBitmapInfo(imgRef) );
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(bitmap, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(bitmap, -height, 0);
		CGContextTranslateCTM(bitmap, 0, width);
    }
    else {
        CGContextScaleCTM(bitmap, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(bitmap, 0, -height);
		CGContextTranslateCTM(bitmap, 0, height);
    }
	
	CGContextScaleCTM(bitmap, 1, -1);
    CGContextConcatCTM(bitmap, transform);	
	CGContextDrawImage(bitmap, CGRectMake(0,0,width,height), imgRef);
	
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage* imageCopy = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	
	CGImageRelease(ref);

    return imageCopy;
}






- (UIImage*)scaleAndRotateImageThreaded:(float)maxResolution {
	[self scaleAndRotateImageThreaded:maxResolution withDesiredOrientation:-1];
}

- (UIImage*)scaleAndRotateImageThreaded:(float)maxResolution withDesiredOrientation:(UIImageOrientation) desiredOrientation {
	
//- (UIImage*)scaleAndRotateImageThreaded:(float)maxResolution {
   
	maxResolution = roundf(maxResolution);
	
	CGImageRef imgRef = self.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
	
    CGRect bounds = CGRectMake(0, 0, width, height);
    
	if (width > maxResolution || height > maxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = maxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = maxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
	
    UIImageOrientation orient = self.imageOrientation;
	
	if (desiredOrientation != -1) {
		orient = desiredOrientation;
	}
	//self.imageOrientation = UIImageOrientationUp;
	
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
	
	bounds.size.width = roundf(bounds.size.width);
    bounds.size.height = roundf(bounds.size.height);
	
	if ( (scaleRatio == 1) && CGAffineTransformIsIdentity(transform) ) {
		NSLog(@"didnt have to do anything");
		return self;
	}
	
	/*
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
	
	*/
	
	/// WHY THE FUCK IS THIS UPSIDE DOWN ???? !
	

	//CGContextRef bitmap = CGBitmapContextCreate(NULL, bounds.size.width, bounds.size.height,
	//											CGImageGetBitsPerComponent(imgRef), CGImageGetBitsPerComponent(imgRef)*bounds.size.width, CGImageGetColorSpace(imgRef),
	//											CGImageGetBitmapInfo(imgRef));
	
	
	//CGContextRef bitmap = CGBitmapContextCreate(NULL, bounds.size.width, bounds.size.height, 4, 4*bounds.size.width, CGImageGetColorSpace(imgRef), CGImageGetBitmapInfo(imgRef));
	
	// works... CGContextRef bitmap = CGBitmapContextCreate(NULL, bounds.size.width, bounds.size.height, 8, 4*bounds.size.width, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast );
	int bitsPerPixel = CGImageGetBitsPerPixel(imgRef);
	//int oldBytesPerRow = CGImageGetBytesPerRow(imgRef);
	int bytesPerRow = bitsPerPixel/8*bounds.size.width;
	int bitsPerComponent = CGImageGetBitsPerComponent(imgRef);
	
	// this has worked for full 1600x1200 etc...
	CGContextRef bitmap = CGBitmapContextCreate(NULL, bounds.size.width, bounds.size.height, bitsPerComponent, bytesPerRow, CGImageGetColorSpace(imgRef), CGImageGetBitmapInfo(imgRef) );
	
	//CGBitmapContextCreate(<#void * data#>, <#size_t width#>, <#size_t height#>, <#size_t bitsPerComponent#>, <#size_t bytesPerRow#>, <#CGColorSpaceRef colorspace#>, <#CGBitmapInfo bitmapInfo#>)
	// CGColorSpaceCreateDeviceRGB()
	// kCGImageAlphaPremultipliedLast
	
	// for some reason its flipping the image?
	
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(bitmap, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(bitmap, -height, 0);
		CGContextTranslateCTM(bitmap, 0, width);
    }
    else {
        CGContextScaleCTM(bitmap, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(bitmap, 0, -height);
		CGContextTranslateCTM(bitmap, 0, height);
    }
    
	
	
	CGContextScaleCTM(bitmap, 1, -1);
	
    CGContextConcatCTM(bitmap, transform);
	
	CGContextDrawImage(bitmap, CGRectMake(0,0,width,height), imgRef);
	
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage* imageCopy = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	
	CGImageRelease(ref);
	
	
    
    return imageCopy;
}




@end
