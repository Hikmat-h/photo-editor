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
    self.imagePicker.delegate=self;
    self.imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.imagePicker.mediaTypes = @[(NSString*)kUTTypePNG, (NSString*)kUTTypeJPEG, (NSString*)kUTTypeImage];
    self.squareSize = self.chosenImageV.frame.size.width;  // = height
    [self.chooseBtn setTitle:@"Choose photo" forState:UIControlStateNormal];
    self.resultArray = [NSMutableArray array];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 250;
}


- (IBAction)onChooseBtn:(id)sender {
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    [self.chooseBtn setTitle:@"" forState:UIControlStateNormal];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    NSURL *imageURL = [info objectForKey:UIImagePickerControllerImageURL];
    NSData *imgData=[NSData dataWithContentsOfURL:imageURL];
    UIImage *img=[UIImage imageWithData:imgData];
    
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
    self.chosenImageV.image = [self croppIngimageByImageName:img toRect:cropRect];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
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
- (IBAction)onRotate:(id)sender {
}

- (IBAction)onBlackEffect:(id)sender {
    CIContext *imageContext=[CIContext contextWithOptions:nil];
    CIImage *selected = [[CIImage alloc] initWithImage:self.chosenImageV.image];
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectMono" keysAndValues:kCIInputImageKey, selected, nil];
    CIImage *result = [filter valueForKey:@"outputImage"];
    CGImageRef cgImageRef = [imageContext createCGImage:result fromRect:[result extent]];
    UIImage *img = [UIImage imageWithCGImage:cgImageRef];
    [self.resultArray addObject:img];
    [self.tableView reloadData];
}

- (IBAction)onMirror:(id)sender {
    UIImage *flippedImage=[UIImage imageWithCGImage:self.chosenImageV.image.CGImage scale:self.chosenImageV.image.scale orientation:UIImageOrientationUpMirrored];
    [self.resultArray addObject:flippedImage];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    return self.resultArray.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell"];
    
    PhotoCell *photoCell=(PhotoCell *)cell;
    UIImage *img=(UIImage *)[self.resultArray objectAtIndex:indexPath.row];
    photoCell.resultImageV.image=img;
    return cell;
}

//-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    VideoCell *vid=[tableView cellForRowAtIndexPath:indexPath];
//    [vid.playerView setHidden:NO];
//    [self.currentVid stopVideo];
//    self.currentVid=vid.playerView;
//    Video *video = [_ytVideos objectAtIndex:indexPath.row];
//    NSDictionary *playerVars = @{
//                                 @"playsinline" : @0,
//                                 @"autoplay" : @1,
//                                 @"rel" : @0
//                                 };
//
//    [vid.playerView loadWithVideoId:video.videoID playerVars:playerVars];
//}
@end
