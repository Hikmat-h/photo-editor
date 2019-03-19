//
//  PhotoCell.m
//  photo-editor
//
//  Created by Hikmat Habibullaev on 3/14/19.
//  Copyright © 2019 Hikmat Habibullaev. All rights reserved.
//

#import "PhotoCell.h"

@implementation PhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.progPerct.text = @"0%";
    self.progressView.progress = 0;
//    self.resultImageV.hidden = YES;
    float rand = 5 + arc4random_uniform(26);
    self.time = 0;
    self.totalTime = rand/30;
    //self.timer=[NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    //self.timer=[NSTimer timerWithTimeInterval:0.3f target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
        //[[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) updateTimer
{
    if(self.time >= self.totalTime)
    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.resultImageV.hidden = NO;
//            [self.progressView setHidden:YES];
//            self.progPerct.hidden = YES;
//        });
        self.resultImageV.hidden = NO;
        [self.progressView setHidden:YES];
        self.progPerct.hidden = YES;
        [self.timer invalidate];
    }
    else
    {
        self.time += 0.01;
        self.progress = self.time/self.totalTime;
        self.progressView.progress = self.progress;
        self.progPerct.text = [NSString stringWithFormat:@"%0.0f%%", self.progress*100];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.progressView.progress = self.progress;
//            self.progPerct.text = [NSString stringWithFormat:@"%0.0f%%", self.progress*100];
//        });
    }
}
@end
