//
//  PhotosTable.h
//  photo-editor
//
//  Created by Hikmat Habibullaev on 4/17/19.
//  Copyright © 2019 Hikmat Habibullaev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol PhotosTableDelegate <NSObject>
-(void)imageEdited: (UIImage *)image;
-(void)imageSaved: (UIImage *)image;
@end

@interface PhotosTable : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *resultArray;
@property (strong, nonatomic) NSMutableArray *activeTimerIndexArray;
-(void)setTimerForLastIndex;
-(void) updateTimer:(NSTimer *)timer;
@property (weak, nonatomic) id <PhotosTableDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
