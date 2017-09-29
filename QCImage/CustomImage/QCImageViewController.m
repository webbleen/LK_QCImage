//
//  QCImageViewController.h
//  QCImage
//
//  Created by wzh on 2017/9/26.
//  Copyright © 2017年 李文斌. All rights reserved.
//

#import "QCImageViewController.h"
#import "CameraSessionView.h"
#import "ClipViewController.h"

#import <AVFoundation/AVFoundation.h>

#define QC_SCREEN_SIZE CGSizeMake([[UIScreen mainScreen] bounds].size.width > [[UIScreen mainScreen] bounds].size.height?[[UIScreen mainScreen] bounds].size.height:[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width < [[UIScreen mainScreen] bounds].size.height?[[UIScreen mainScreen] bounds].size.height:[[UIScreen mainScreen] bounds].size.width)

@interface QCImageViewController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CACameraSessionDelegate, ClipPhotoDelegate>

@property (nonatomic, strong) CameraSessionView *cameraView;
@property (nonatomic, strong) UIImagePickerController *imgPicker;
@property (nonatomic, assign) BOOL isTakePhoto;
@property (nonatomic)BOOL canCa;

@end

@implementation QCImageViewController

+ (QCImageViewController *)shareInstance
{
    static QCImageViewController *g_instance = nil;
    if (g_instance == nil) {
        g_instance = [[QCImageViewController alloc] init];
    }
    
    return  g_instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = CGRectMake(0, 0, QC_SCREEN_SIZE.height, QC_SCREEN_SIZE.width);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)useCameraWithDelegate:(id<QCImageDelegate>)delegate
{
    self.delegate = delegate;
    self.isTakePhoto = YES;
    
    //Set white status bar
    [self setNeedsStatusBarAppearanceUpdate];
    
    //Instantiate the camera view & assign its frame
    _cameraView = [[CameraSessionView alloc] initWithFrame:self.view.frame];
    //Set the camera view's delegate and add it as a subview
    _cameraView.delegate = self;
    
    //Apply animation effect to present the camera view
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.6];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[_cameraView layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    
    if ([self appRootViewController].presentedViewController == nil) {
        [[self appRootViewController].view addSubview:_cameraView];
    }
}

- (void)usePhotoWithDelegate:(id<QCImageDelegate>)delegate
{
    self.delegate = delegate;
    self.isTakePhoto = NO;
    
    // 打开相册
    [self openImagePickerControllerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)openImagePickerControllerWithType:(UIImagePickerControllerSourceType)type
{
    // 设备不可用  直接返回
    if (![UIImagePickerController isSourceTypeAvailable:type]) return;
    
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.sourceType = type;
    _imgPicker.delegate = self;
    _imgPicker.allowsEditing = NO;
    
    //Apply animation effect to present the imagepicker view
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.6];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[_imgPicker.view layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    
    if ([self appRootViewController].presentedViewController == nil) {
        [[self appRootViewController].view addSubview:_imgPicker.view];
    }
}

#pragma mark -- CACameraSessionDelegate
- (void)didCaptureImage:(UIImage *)image
{
    NSLog(@"CAPTURED IMAGE");
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//    [self.cameraView removeFromSuperview];
//
//    if (self.delegate)
//    {
//        if ([self.delegate respondsToSelector:@selector(didSelectImage:)])
//        {
//            [self.delegate didSelectImage:image];
//        }
//    }
}

#pragma mark -- CACameraSessionDelegate
-(void)didCaptureImageWithData:(NSData *)imageData
{
    NSLog(@"CAPTURED IMAGE DATA");
//    UIImage *image = [[UIImage alloc] initWithData:imageData];
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    //[self.cameraView removeFromSuperview];
    
    [self jumpImageView:imageData];
}

#pragma mark - UINavigationControllerDelegate, UIImagePickerControllerDelegate
// 选择照片之后
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self cropImage:image];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self removeSubView];
}

- (void)cropImage: (UIImage *)image
{
    ClipViewController *viewController = [[ClipViewController alloc] init];
    viewController.image = image;
    viewController.picker = _imgPicker;
    viewController.controller = self;
    viewController.delegate = self;
    viewController.isTakePhoto = NO;
    
    if ([self appRootViewController].presentedViewController == nil) {
        [[self appRootViewController] presentViewController:viewController animated:NO completion:nil];
    }
}

#pragma mark -- ClipPhotoDelegate
- (void)clipPhoto:(UIImage *)image
{
    [self removeSubView];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectImageWithData:)])
    {
        [self.delegate didSelectImage:image];
    }
}

//拍照之后调到相片裁剪页面
-(void)jumpImageView:(NSData*)data{
    ClipViewController *viewController = [[ClipViewController alloc] init];
    UIImage *image = [UIImage imageWithData:data];
    viewController.image = image;
    viewController.picker = _imgPicker;
    viewController.controller = self;
    viewController.delegate = self;
    viewController.isTakePhoto = YES;
    
    if ([self appRootViewController].presentedViewController == nil) {
        [[self appRootViewController] presentViewController:viewController animated:NO completion:nil];
    }
}

- (void)removeSubView
{
    if (_isTakePhoto == YES)
    {
        [self.cameraView removeFromSuperview];
    }
    else
    {
        [self.imgPicker.view removeFromSuperview];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    //Show error alert if image could not be saved
    if (error) [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}

- (UIViewController *)appRootViewController
{
    UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    return topVC;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    return YES;
}


@end
