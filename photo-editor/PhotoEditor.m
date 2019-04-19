//
//  PhotoEditor.m
//  photo-editor
//
//  Created by Hikmat Habibullaev on 4/17/19.
//  Copyright © 2019 Hikmat Habibullaev. All rights reserved.
//

#import "PhotoEditor.h"
#import <CoreImage/CoreImage.h>

@implementation PhotoEditor

-(UIImage* )makeSquareImg: (UIImage *) img{
    CGRect cropRect;
    //square crop image with respect to the smallest size
    if(img.size.width<=img.size.height)
    {
        cropRect = CGRectMake(0, (img.size.height-img.size.width)/2, img.size.width, img.size.width);
    }
    else
    {
        cropRect = CGRectMake((img.size.width-img.size.height)/2, 0, img.size.height, img.size.height);
    }
    return [self croppIngimageByImageName:img toRect:cropRect];
}

- (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}

static inline double radians (double degrees)
{
    return degrees * M_PI/180;
    
}

-(UIImage*)rotateRight:(UIImage *)img {
    UIGraphicsBeginImageContext(img.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM( context, 0.5f * img.size.width, 0.5f * img.size.height );
    CGContextRotateCTM (context, radians(90));
    [img drawInRect:(CGRect){ { -img.size.width * 0.5f, -img.size.height * 0.5f }, img.size } ] ;
    UIImage *rotatedImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rotatedImg;
}

-(UIImage*)blackMonoEffect: (UIImage*)img {
    CIContext *imageContext = [CIContext contextWithOptions:nil];
    CIImage *selected = [[CIImage alloc] initWithImage:img];
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectMono" keysAndValues:kCIInputImageKey, selected, nil];
    CIImage *result = [filter valueForKey:@"outputImage"];
    CGImageRef cgImageRef = [imageContext createCGImage:result fromRect:[result extent]];
    UIImage *resultImg = [UIImage imageWithCGImage:cgImageRef];
    return resultImg;
}

-(UIImage*)mirror:(UIImage*)img {
    UIImage *flippedImage;
    if (img.imageOrientation!=UIImageOrientationUpMirrored)
    {
        flippedImage = [UIImage imageWithCGImage:img.CGImage scale:img.scale orientation:UIImageOrientationUpMirrored];
    }
    else
    {
        flippedImage = [UIImage imageWithCGImage:img.CGImage scale:img.scale orientation:UIImageOrientationUp];
    }
    return flippedImage;
}
@end
