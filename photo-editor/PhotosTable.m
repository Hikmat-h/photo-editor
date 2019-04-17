//
//  PhotosTable.m
//  photo-editor
//
//  Created by Hikmat Habibullaev on 4/17/19.
//  Copyright © 2019 Hikmat Habibullaev. All rights reserved.
//

#import "PhotosTable.h"
#import "Timer.h"
#import "PhotoCell.h"
@interface PhotosTable ()

@end

@implementation PhotosTable

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.resultArray = [NSMutableArray array];
    self.activeTimerIndexArray = [NSMutableArray array];
    [self.tableView registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"photoCell"];
}

-(void)setTimerForLastIndex{
    float rand = 5 + arc4random_uniform(26); // 5 and 30 secs
    Timer *timerInfo = [[Timer alloc] init];
    timerInfo.time = 0.0;
    timerInfo.totalTime = rand/50;   // real_time=100*totalTime*0.5
    timerInfo.forIndex = [NSIndexPath indexPathForRow:self.resultArray.count-1 inSection:0];
    [self.activeTimerIndexArray addObject:timerInfo.forIndex];
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(updateTimer:) userInfo:timerInfo repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void) updateTimer:(NSTimer *)timer
{
    Timer *timerInfo = timer.userInfo;
    NSIndexPath *index = timerInfo.forIndex;
    PhotoCell *cell = [self.tableView cellForRowAtIndexPath:index];
    if(timerInfo.time >= timerInfo.totalTime)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIProgressView *prg = [cell viewWithTag:11];
            [prg removeFromSuperview];
            [cell.resultImageV setHidden:NO];
        });
        [timer invalidate];
        //remove no longer active timer index
        [self.activeTimerIndexArray removeObject:timerInfo.forIndex];
        [self.tableView reloadData];
        [self.tableView
         scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.resultArray.count-1
                                                   inSection:0]
         atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else
    {
        timerInfo.time += 0.01;
        float progress = timerInfo.time/timerInfo.totalTime;
        dispatch_async(dispatch_get_main_queue(), ^{
            UIProgressView *prg = [cell viewWithTag:11];
            prg.progress = progress;
        });
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell"];
    
    PhotoCell *photoCell = (PhotoCell *)cell;
    //if there is active timer
    if([self.activeTimerIndexArray containsObject:indexPath]){
        [photoCell.resultImageV setHidden:YES];
        
        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        progressView.frame = CGRectMake(photoCell.resultImageV.frame.origin.x, 25, photoCell.resultImageV.frame.size.width, photoCell.resultImageV.frame.size.height);
        progressView.backgroundColor = [UIColor darkGrayColor];
        [progressView setTag:11];
        [photoCell.contentView addSubview:progressView];
    }
    UIImage *img = (UIImage *)[self.resultArray objectAtIndex:indexPath.row];
    photoCell.resultImageV.image = img;
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIImage *img = [self.resultArray objectAtIndex:indexPath.row];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"choose actioin" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act){
        [self.delegate imageSaved:img];
    }];
    UIAlertAction *edit = [UIAlertAction actionWithTitle:@"edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act){
        [self.delegate imageEdited:img];
    }];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act){
        [self.resultArray removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:save];
    [alert addAction:edit];
    [alert addAction:delete];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(double)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.activeTimerIndexArray containsObject:indexPath])
        return 50;
    else
        return 250;
}

@end
