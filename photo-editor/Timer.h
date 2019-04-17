//
//  Timer.h
//  photo-editor
//
//  Created by Hikmat Habibullaev on 4/17/19.
//  Copyright © 2019 Hikmat Habibullaev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Timer : NSObject
@property float time;
@property float totalTime;
@property (strong, nonatomic) NSIndexPath *forIndex;
@end

NS_ASSUME_NONNULL_END
