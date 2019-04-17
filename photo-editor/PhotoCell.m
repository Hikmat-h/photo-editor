//
//  PhotoCell.m
//  photo-editor
//
//  Created by Hikmat Habibullaev on 4/17/19.
//  Copyright © 2019 Hikmat Habibullaev. All rights reserved.
//

#import "PhotoCell.h"

@implementation PhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse{
    [super prepareForReuse];
    UIProgressView *prg = [self viewWithTag:11];
    [prg removeFromSuperview];
    [self.resultImageV setHidden:NO];
}
@end
