//
//  PhotoEditor.h
//  photo-editor
//
//  Created by Hikmat Habibullaev on 4/17/19.
//  Copyright © 2019 Hikmat Habibullaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface PhotoEditor : NSObject
-(UIImage* )makeSquareImg: (UIImage *) img;
- (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect;
-(UIImage*)rotateRight:(UIImage *)img;
-(UIImage*)blackMonoEffect: (UIImage*)img;
-(UIImage*)mirror:(UIImage*)img;
@end

NS_ASSUME_NONNULL_END
