//////////////////////////////////////////////////////////////////
//
//  UIImage+BaseImage.m
//
//  Created by Dalton Cherry on 5/28/13.
//  Copyright (c) 2013 basement Krew. All rights reserved.
//
//////////////////////////////////////////////////////////////////

#import "UIImage+BaseImage.h"
#import "CircleView.h"
#import "RoundRectView.h"
#import <QuartzCore/QuartzCore.h>
//#import "UIImage+ImageEffects.h"

//////////////////////////////////////////////////////////////////
@implementation UIWindow (BaseImage)

+(UIImage*)capture
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, 0.0); //self.opaque
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

@implementation UIView (BaseImage)

//////////////////////////////////////////////////////////////////
-(UIImage*)capture
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0); //self.opaque
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
//////////////////////////////////////////////////////////////////
-(UIImage*)capture:(CGRect)rect
{
    UIImage* img = [self capture];
    return [img cropImage:rect];
}
//////////////////////////////////////////////////////////////////
/*-(UIImage*)captureBlur:(CGRect)rect
{
    CGFloat scale = 0.5;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0f && [UIScreen mainScreen].scale == 1.0f)
        scale = 1;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
//////////////////////////////////////////////////////////////////
-(void)blurView
{
    CGRect frame = [self convertRect:self.bounds toView:self.superview];
    UIImage* img = [[self.superview captureBlur:frame] applyLightEffect];
    self.backgroundColor = [UIColor colorWithPatternImage:img];
}*/
//////////////////////////////////////////////////////////////////

@end
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
@implementation UIImage (BaseImage)

//////////////////////////////////////////////////////////////////
-(UIImage*)cropImage:(CGRect)rect
{
    //I might add/modify to do this....
    /*CGSize size = [self size];
    CGFloat wscale = size.width/rect.size.width;
    CGFloat width = rect.size.width*wscale;
    
    CGFloat hscale = size.height/rect.size.height;
    CGFloat height = rect.size.height*hscale;
    
    CGRect cropRect = CGRectMake(rect.origin.y*wscale, rect.origin.x*wscale,
                                 width, height);*/
    
    CGRect cropRect = CGRectMake(rect.origin.x*self.scale, rect.origin.y*self.scale, rect.size.width*self.scale, rect.size.height*self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], cropRect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return img;
}
//////////////////////////////////////////////////////////////////
//round rect images.
//////////////////////////////////////////////////////////////////
+(UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius
{
    RoundRectView* view = [RoundRectView roundRectWithColor:color rounding:cornerRadius];
    view.frame = CGRectMake(0, 0, size.width, size.height);
    return [[view capture] resizableImageWithCapInsets:UIEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)];
}
//////////////////////////////////////////////////////////////////
+(UIImage*)imageWithColors:(NSArray*)colors ranges:(CGFloat*)ranges size:(CGSize)size cornerRadius:(CGFloat)cornerRadius
{
    RoundRectView* view = [RoundRectView roundRectWithColors:colors ranges:ranges rounding:cornerRadius];
    view.frame = CGRectMake(0, 0, size.width, size.height);
    return [[view capture] resizableImageWithCapInsets:UIEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)];
}
//////////////////////////////////////////////////////////////////
+(UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size
{
    RoundRectView* view = [RoundRectView roundRectWithColor:color rounding:0];
    view.frame = CGRectMake(0, 0, size.width, size.height);
    return [view capture];
}
//////////////////////////////////////////////////////////////////
+(UIImage*)imageWithColors:(NSArray*)colors ranges:(CGFloat*)ranges size:(CGSize)size
{
    RoundRectView* view = [RoundRectView roundRectWithColors:colors ranges:ranges rounding:0];
    view.frame = CGRectMake(0, 0, size.width, size.height);
    return [view capture];
}
//////////////////////////////////////////////////////////////////
//circle images. 
//////////////////////////////////////////////////////////////////
+(UIImage*)circleImageWithColor:(UIColor*)color size:(CGSize)size
{
    CircleView* view = [CircleView circleWithColor:color];
    view.frame = CGRectMake(0, 0, size.width, size.height);
    return [view capture];
}
//////////////////////////////////////////////////////////////////
+(UIImage*)circleImageWithColors:(NSArray*)colors ranges:(CGFloat*)ranges size:(CGSize)size
{
    CircleView* view = [CircleView circleWithColors:colors ranges:ranges];
    view.frame = CGRectMake(0, 0, size.width, size.height);
    return [view capture];
}
//////////////////////////////////////////////////////////////////
-(UIImage*)imageWithOverlayColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    
    [self drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
//////////////////////////////////////////////////////////////////
+(UIImage*)imageWithBorder:(UIColor*)color bodyColor:(UIColor*)bodyColor width:(float)width cornerRadius:(CGFloat)cornerRadius
{
    int edge = cornerRadius*2 + 1;
    RoundRectView* view = [RoundRectView roundRectWithColor:bodyColor rounding:cornerRadius];
    view.frame = CGRectMake(0, 0, 15, 15);
    view.borderColor = color;
    view.borderWidth = width;
    return [[view capture] resizableImageWithCapInsets:UIEdgeInsetsMake(edge, edge, edge, edge)];;
}

//////////////////////////////////////////////////////////////////
- (UIImage*)fixOrientation
{    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
//////////////////////////////////////////////////////////////////

@end
