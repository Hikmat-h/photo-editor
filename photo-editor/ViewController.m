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
@property float squareSize;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.imagePicker.allowsEditing = YES;
    self.imagePicker.mediaTypes = @[(NSString*)kUTTypePNG, (NSString*)kUTTypeJPEG, (NSString*)kUTTypeImage];
    self.squareSize = self.chosenImageV.frame.size.width;  // = height
    [self.chooseBtn setTitle:@"Choose photo" forState:UIControlStateNormal];
    self.resultArray = [NSMutableArray array];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 250;
    self.rotateBtn.layer.cornerRadius=4;
    self.blackEffectBtn.layer.cornerRadius=4;
    self.mirrorBtn.layer.cornerRadius=4;
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
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    //    __block UIImage *image;
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //       NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    //        if (data==nil)
    //        {
    //            return;
    //        }
    //        image = [UIImage imageWithData:data];
    //    });
    //    return image;
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
    CGSize imageSize=CGSizeMake(0, 0);
    // make the smaller part equal to square size and change the greater part in the same ratio for cropping
    if(img.size.width<=img.size.height)
    {
        imageSize.width = self.squareSize;
        imageSize.height = img.size.height*self.squareSize/img.size.width; //in the same ratio
    }
    else
    {
        imageSize.width = img.size.width*self.squareSize/img.size.height;
        imageSize.height = self.squareSize;
    }
    img=[self imageWithImage:img convertToSize:imageSize];
    CGRect cropRect = CGRectMake(fabs(self.squareSize-img.size.width)/2, fabs(self.squareSize-img.size.height)/2, self.squareSize, self.squareSize);
    return [self croppIngimageByImageName:img toRect:cropRect];
}

- (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    return cropped;
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)onRotate:(id)sender {
    if(self.chosenImageV.image)
    {
        UIImage *img = [self rotateRight:self.chosenImageV.image];
        [self.resultArray addObject:img];
        [self.tableView reloadData];
    }
}

- (IBAction)onBlackEffect:(id)sender {
    if(self.chosenImageV.image)
    {
        UIImage *img = [self blackMonoEffect:self.chosenImageV.image];
        [self.resultArray addObject:img];
        [self.tableView reloadData];
    }
}

- (IBAction)onMirror:(id)sender {
    if(self.chosenImageV.image)
    {
        UIImage *flippedImg = [self mirror:self.chosenImageV.image];
        [self.resultArray addObject:flippedImg];
        [self.tableView reloadData];
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

//------tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    return self.resultArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell"];
    
    PhotoCell *photoCell = (PhotoCell *)cell;
    UIImage *img = (UIImage *)[self.resultArray objectAtIndex:indexPath.row];
    photoCell.resultImageV.image = img;
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    PhotoCell *photo=[tableView cellForRowAtIndexPath:indexPath];
    UIImage *img = [self.resultArray objectAtIndex:indexPath.row];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"choose actioin" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act){
        [self saveImage:img];
    }];
    UIAlertAction *edit = [UIAlertAction actionWithTitle:@"edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act){
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

//- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
//    <#code#>
//}
//
//- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
//    <#code#>
//}
//
//- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
//    <#code#>
//}
//
//- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
//    <#code#>
//}
//
//- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
//    <#code#>
//}
//
//- (void)setNeedsFocusUpdate {
//    <#code#>
//}
//
//- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
//    <#code#>
//}
//
//- (void)updateFocusIfNeeded {
//    <#code#>
//}

@end

