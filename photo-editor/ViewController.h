//
//  ViewController.h
//  photo-editor
//
//  Created by Hikmat Habibullaev on 3/11/19.
//  Copyright © 2019 Hikmat Habibullaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIView *chooseView;
@property (weak, nonatomic) IBOutlet UIButton *rotateBtn;
@property (weak, nonatomic) IBOutlet UIButton *blackEffectBtn;
@property (weak, nonatomic) IBOutlet UIButton *mirrorBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *chosenImageV;
- (IBAction)onChooseBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;
- (IBAction)onRotate:(id)sender;
- (IBAction)onBlackEffect:(id)sender;
- (IBAction)onMirror:(id)sender;

@end

