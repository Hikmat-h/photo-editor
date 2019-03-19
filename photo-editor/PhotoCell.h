//
//  PhotoCell.h
//  photo-editor
//
//  Created by Hikmat Habibullaev on 3/14/19.
//  Copyright © 2019 Hikmat Habibullaev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *resultImageV;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progPerct;
@property NSTimer *timer;
@property float time;
@property float totalTime;
@property float progress;
@end

NS_ASSUME_NONNULL_END
