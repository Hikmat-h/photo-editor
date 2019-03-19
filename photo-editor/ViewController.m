//
//  ViewController.m
//  photo-editor
//
//  Created by Hikmat Habibullaev on 3/11/19.
//  Copyright © 2019 Hikmat Habibullaev. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <CoreImage/CoreImage.h>
#import "PhotoCell.h"

@interface ViewController ()
@property (strong) UIImagePickerController *imagePicker;
@property (strong, nonatomic) NSMutableArray *resultArray;
//@property (strong, nonatomic) NSMutableArray *timerArray;
//@property float time;
//@property float totalTime;
//@property float progress;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.imagePicker.allowsEditing = YES;
    self.imagePicker.mediaTypes = @[(NSString*)kUTTypePNG, (NSString*)kUTTypeJPEG, (NSString*)kUTTypeImage];
    [self.chooseBtn setTitle:@"Choose photo" forState:UIControlStateNormal];
    self.resultArray = [NSMutableArray array];
//    self.timerArray = [NSMutableArray array];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 250;
    self.rotateBtn.layer.cornerRadius=4;
    self.blackEffectBtn.layer.cornerRadius=4;
    self.mirrorBtn.layer.cornerRadius=4;
    self.downloadProgress.hidden = YES;
    self.downloadPerct.hidden = YES;
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
            NSLog(@"image %d has orientation ---%ld", i, (long)image.imageOrientation);
            [self.resultArray addObject:image];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
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
        self.downloadProgress.progress=0;
        self.downloadPerct.text=@"0%";
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
    UIImage *img;
    if(picker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary)
    {
        img = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    else if (picker.sourceType==UIImagePickerControllerSourceTypeCamera)
    {
        img = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    self.chosenImageV.image = [self makeSquareImg:img];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

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

- (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    return cropped;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)onRotate:(id)sender {
    if(self.chosenImageV.image)
    {
        UIImage *img = [self rotateRight:self.chosenImageV.image];
        [self.resultArray addObject:img];
//        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-self.tableView.frame.size.height) animated:YES];
        [self.tableView reloadData];
        [self.tableView
         scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.resultArray.count-1
                                                   inSection:0]
         atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (IBAction)onBlackEffect:(id)sender {
    if(self.chosenImageV.image)
    {
        UIImage *img = [self blackMonoEffect:self.chosenImageV.image];
        //if image was mirrored
        if(self.chosenImageV.image.imageOrientation==UIImageOrientationUpMirrored)
        {
            img = [self mirror:img];
        }
        [self.resultArray addObject:img];
        [self.tableView reloadData];
        [self.tableView
         scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.resultArray.count-1
                                                   inSection:0]
         atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (IBAction)onMirror:(id)sender {
    if(self.chosenImageV.image)
    {
        UIImage *flippedImg = [self mirror:self.chosenImageV.image];
        [self.resultArray addObject:flippedImg];
        [self.tableView reloadData];
        [self.tableView
         scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.resultArray.count-1
                                                   inSection:0]
         atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
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
    [defaults setInteger:[self.resultArray count] forKey:@"arrayCount"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        for (int i=(int)self.resultArray.count; i<oldImagesCount; i++)
        {
            NSString *filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"image%d", i]];
            BOOL success = [fileManager removeItemAtPath:filePath error:&error];
            if(success)
            NSLog(@"--> file is deleted--->%@",filePath);
        }
        for (int i=0; i<self.resultArray.count; i++)
        {
            UIImage *image = [self.resultArray objectAtIndex:i];
            NSData *JPEGdata = UIImageJPEGRepresentation(image, 0.7);
            NSString *filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"image%d", i]];
            [JPEGdata writeToFile:filePath atomically:YES];
        }
    });
}

//-(void) updateTimer:(NSTimer *)timer
//{
//    if(self.time >= self.totalTime)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.resultImageV.hidden = NO;
//            [self.progressView setHidden:YES];
//            self.progPerct.hidden = YES;
//        });
//        [timer invalidate];
//    }
//    else
//    {
//        self.time += 0.01;
//        self.progress = self.time/self.totalTime;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.progressView.progress = self.progress;
//            self.progPerct.text = [NSString stringWithFormat:@"%0.0f%%", self.progress*100];
//        });
//    }
//}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    return self.resultArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell"];
    
    PhotoCell *photoCell = (PhotoCell *)cell;
//    float rand = arc4random_uniform(6);
//    self.time=0.0;
//    self.totalTime = rand/30;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSTimer *timer=[NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
//        [self.timerArray addObject:timer];
//    });
    UIImage *img = (UIImage *)[self.resultArray objectAtIndex:indexPath.row];
    photoCell.resultImageV.image = img;
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIImage *img = [self.resultArray objectAtIndex:indexPath.row];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"choose actioin" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act){
        [self saveImage:img];
    }];
    UIAlertAction *edit = [UIAlertAction actionWithTitle:@"edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act){
        [self.chooseBtn setTitle:@"" forState:UIControlStateNormal];
        self.chosenImageV.image=img;
    }];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act){
        [self.resultArray removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:save];
    [alert addAction:edit];
    [alert addAction:delete];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) saveImage: (UIImage *)img {
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
}

#pragma mark - session
- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        [self.downloadProgress setHidden:YES];
//        self.downloadPerct.hidden = YES;
        UIImage *image = [UIImage imageWithData:data];
        if(image==nil)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"url does not contain photo" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            [self.chosenImageV setImage:[self makeSquareImg:image]];
            [self saveImage:image];
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
        [self.downloadProgress setHidden:YES];
        self.downloadPerct.hidden = YES;
    });
    NSLog(@"error is--%@", error);
}
-(void) URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.downloadProgress setHidden:YES];
      self.downloadPerct.hidden = YES;
    });
    NSLog(@"error is--%@", error);
}
@end

