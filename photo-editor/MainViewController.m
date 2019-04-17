//
//  MainViewController.m
//  photo-editor
//
//  Created by Hikmat Habibullaev on 3/11/19.
//  Copyright © 2019 Hikmat Habibullaev. All rights reserved.
//

#import "MainViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import "Timer.h"
#import "PhotoEditor.h"
#import "PhotosTable.h"
@interface MainViewController ()
{
    PhotosTable *photos;
}
@property (strong) UIImagePickerController *imagePicker;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.imagePicker.allowsEditing = YES;
    self.imagePicker.mediaTypes = @[(NSString*)kUTTypePNG, (NSString*)kUTTypeJPEG, (NSString*)kUTTypeImage];
    [self.chooseBtn setTitle:@"Choose photo" forState:UIControlStateNormal];
    self.rotateBtn.layer.cornerRadius=4;
    self.blackEffectBtn.layer.cornerRadius=4;
    self.mirrorBtn.layer.cornerRadius=4;
    self.downloadProgress.hidden = YES;
    self.downloadPerct.hidden = YES;
    
    photos = [[PhotosTable alloc] initWithNibName:@"PhotosTable" bundle:nil];
    photos.delegate = self;
    CGRect tableFrame = CGRectMake(0, 0, self.forTable.frame.size.width, self.forTable.frame.size.height);
    [photos.view setFrame:tableFrame];
    [self addChildViewController:photos];
    [photos didMoveToParentViewController:self];
    photos.tableView.rowHeight = 250;
    [self.forTable addSubview:photos.view];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidEnterBackground:)
     name:UIApplicationDidEnterBackgroundNotification
     object:[UIApplication sharedApplication]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int count = (int)[defaults integerForKey:@"arrayCount"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(int i=0; i<count; i++)
        {
            NSString *filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"image%d", i]];
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            UIImage *image = [UIImage imageWithData:data];
            if(image!=nil)
                [self->photos.resultArray addObject:image];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->photos.tableView reloadData];
        });
    });
}

- (IBAction)onChooseBtn:(id)sender {
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"Choose the source" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act){
        [self openCamera];
    }];
    UIAlertAction *action2=[UIAlertAction actionWithTitle:@"Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act){
        [self openLibrary];
    }];
    UIAlertAction *action3=[UIAlertAction actionWithTitle:@"URL" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act){
        [self openURL];
    }];
    UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *act){
        if(self.chosenImageV.image==nil)
            [self.chooseBtn setTitle:@"Choose photo" forState:UIControlStateNormal];
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    [self.chooseBtn setTitle:@"" forState:UIControlStateNormal];
}

-(void)openCamera{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        self.imagePicker.cameraDevice=UIImagePickerControllerCameraDeviceRear;
        self.imagePicker.showsCameraControls = YES;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
}

-(void)openLibrary{
    self.imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void)openURL{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter photo URL" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *urlField) {
        urlField.keyboardType=UIKeyboardTypeURL;
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act) {
        self.chosenImageV.hidden = YES;
        self.downloadProgress.progress = 0;
        self.downloadPerct.text = @"0%";
        [self.downloadProgress setHidden:NO];
        self.downloadPerct.hidden = NO;
        NSURLSessionConfiguration *sessionconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionconfig delegate:self delegateQueue:nil];
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:[alert.textFields firstObject].text]];
        [downloadTask resume];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *act){
        if(self.chosenImageV.image==nil)
            [self.chooseBtn setTitle:@"Choose photo" forState:UIControlStateNormal];
    }];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    PhotoEditor *edit = [[PhotoEditor alloc] init];
    self.chosenImageV.image = [edit makeSquareImg:img];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)onRotate:(id)sender {
    if(self.chosenImageV.image)
    {
        PhotoEditor *edit = [[PhotoEditor alloc] init];
        UIImage *img = [edit rotateRight:self.chosenImageV.image];
        [photos.resultArray addObject:img];
        [photos setTimerForLastIndex];
        [photos.tableView reloadData];
        [photos.tableView
         scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:photos.resultArray.count-1
                                                   inSection:0]
         atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (IBAction)onBlackEffect:(id)sender {
    if(self.chosenImageV.image)
    {
        PhotoEditor *edit = [[PhotoEditor alloc] init];
        UIImage *img = [edit blackMonoEffect:self.chosenImageV.image];
        //if image was mirrored
        if(self.chosenImageV.image.imageOrientation==UIImageOrientationUpMirrored)
        {
            img = [edit mirror:img];
        }
        [photos.resultArray addObject:img];
        [photos setTimerForLastIndex];
        [photos.tableView reloadData];
        [photos.tableView
         scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:photos.resultArray.count-1
                                                   inSection:0]
         atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (IBAction)onMirror:(id)sender {
    if(self.chosenImageV.image)
    {
        PhotoEditor *edit = [[PhotoEditor alloc] init];
        UIImage *flippedImg = [edit mirror:self.chosenImageV.image];
        [photos.resultArray addObject:flippedImg];
        [photos setTimerForLastIndex];
        [photos.tableView reloadData];
        [photos.tableView
         scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:photos.resultArray.count-1
                                                   inSection:0]
         atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

-(void)applicationDidEnterBackground:(NSNotification *)notify{
    //delete old images beginning from new image last index+1
    //other images will be overwritten
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int oldImagesCount = (int)[defaults integerForKey:@"arrayCount"];
    [defaults setInteger:[photos.resultArray count] forKey:@"arrayCount"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        for (int i=(int)self->photos.resultArray.count; i<oldImagesCount; i++)
        {
            NSString *filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"image%d", i]];
            BOOL success = [fileManager removeItemAtPath:filePath error:&error];
            if(success)
            NSLog(@"--> file is deleted--->%@",filePath);
        }
        for (int i=0; i<self->photos.resultArray.count; i++)
        {
            UIImage *image = [self->photos.resultArray objectAtIndex:i];
            NSData *JPEGdata = UIImageJPEGRepresentation(image, 0.7);
            NSString *filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"image%d", i]];
            [JPEGdata writeToFile:filePath atomically:YES];
        }
    });
}

-(void)imageEdited:(UIImage *)image{
    [self.chooseBtn setTitle:@"" forState:UIControlStateNormal];
    self.chosenImageV.image=image;
}

-(void)imageSaved:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

#pragma mark - session
- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        [self.downloadProgress setHidden:YES];
//        self.downloadPerct.hidden = YES;
        UIImage *image = [UIImage imageWithData:data];
        self.chosenImageV.hidden = NO;
        if(image==nil)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"url does not contain photo" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            PhotoEditor *edit = [[PhotoEditor alloc] init];
            [self.chosenImageV setImage:[edit makeSquareImg:image]];
            [self imageSaved:image];
        }
        
    });
}

-(void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.downloadProgress setProgress:progress];
        self.downloadPerct.text=[NSString stringWithFormat:@"%0.0f%%", progress*100];
        
    });
}

-(void) URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chosenImageV.hidden = NO;
        [self.downloadProgress setHidden:YES];
        self.downloadPerct.hidden = YES;
    });
    NSLog(@"error is--%@", error);
}

-(void) URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chosenImageV.hidden = NO;
        [self.downloadProgress setHidden:YES];
        self.downloadPerct.hidden = YES;
    });
    NSLog(@"error is--%@", error);
}
@end

