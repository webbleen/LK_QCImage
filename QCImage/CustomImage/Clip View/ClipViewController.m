//
//  ClipViewController.m
//  Camera
//
//  Created by wzh on 2017/6/6.
//  Copyright © 2017年 wzh. All rights reserved.
//

#import "ClipViewController.h"
#import "TKImageView.h"
#define SelfWidth [UIScreen mainScreen].bounds.size.width
#define SelfHeight  [UIScreen mainScreen].bounds.size.height
@interface ClipViewController ()
{
    //Size of the UI elements variables
    CGSize sideBarSize;
    CGSize itemButtonSize;
}

@property (nonatomic, assign) BOOL isClip;

@property (nonatomic, strong) TKImageView *tkImageView;
@property (nonatomic, strong) UIView *sideBar;


@end

@implementation ClipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createdTkImageView];
    
    [self createdTool];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createdTkImageView
{
    //_tkImageView = [[TKImageView alloc] initWithFrame:CGRectMake(0, 0, SelfWidth, SelfHeight - 120)];
    _tkImageView = [[TKImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_tkImageView];
    //需要进行裁剪的图片对象
    _tkImageView.toCropImage = _image;
    //是否显示中间线
    _tkImageView.showMidLines = YES;
    //是否需要支持缩放裁剪
    _tkImageView.needScaleCrop = YES;
    //是否显示九宫格交叉线
    _tkImageView.showCrossLines = YES;
    _tkImageView.cornerBorderInImage = NO;
    _tkImageView.cropAreaCornerWidth = 20;
    _tkImageView.cropAreaCornerHeight = 20;
    _tkImageView.minSpace = 30;
    _tkImageView.cropAreaCornerLineColor = [UIColor whiteColor];
    _tkImageView.cropAreaBorderLineColor = [UIColor whiteColor];
    _tkImageView.cropAreaCornerLineWidth = 6;
    _tkImageView.cropAreaBorderLineWidth = 1;
    _tkImageView.cropAreaMidLineWidth = 20;
    _tkImageView.cropAreaMidLineHeight = 6;
    _tkImageView.cropAreaMidLineColor = [UIColor whiteColor];
    _tkImageView.cropAreaCrossLineColor = [UIColor whiteColor];
    _tkImageView.cropAreaCrossLineWidth = 0.5;
    _tkImageView.initialScaleFactor = 1.0f;
    _tkImageView.cropAspectRatio = 1;
    _tkImageView.maskColor = [UIColor colorWithWhite:0.5 alpha:0.8];
    
    self.isClip = NO;
}

- (void)createdTool
{
    //Define adaptable sizing variables for UI elements to the right device family (iPhone or iPad)
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        //Declare the sizing of the UI elements for iPad
        sideBarSize = CGSizeMake(self.view.frame.size.width*0.2, self.view.frame.size.height);
        itemButtonSize = CGSizeMake(self.view.frame.size.height * 0.1, self.view.frame.size.height * 0.1);
    } else
    {
        //Declare the sizing of the UI elements for iPhone
        sideBarSize = CGSizeMake(self.view.frame.size.width*0.15, self.view.frame.size.height);
        itemButtonSize = CGSizeMake(self.view.frame.size.height * 0.21, self.view.frame.size.height * 0.21);
    }
    _sideBar = [[UIView alloc] init];
    if (_sideBar) {
        _sideBar.frame = (CGRect){0, 0, sideBarSize};
        _sideBar.center = CGPointMake(self.view.frame.size.width-(sideBarSize.width/2), self.view.frame.size.height/2);
        _sideBar.backgroundColor = [UIColor colorWithRed: 0.176 green: 0.478 blue: 0.529 alpha: 0.64];
        [self.view addSubview:_sideBar];
    }
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = (CGRect){0,0, itemButtonSize};
    sureBtn.center = CGPointMake(self.view.frame.size.width-sideBarSize.width/2, self.view.frame.size.height*(1.0/6.0f));
    [sureBtn setImage:[UIImage imageNamed:@"surePhoto"] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sure) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sureBtn];
    
    UIButton *clipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clipBtn.frame = (CGRect){0,0, itemButtonSize};
    clipBtn.center = CGPointMake(self.view.frame.size.width-sideBarSize.width/2, self.view.frame.size.height*(3.0/6.0f));
    [clipBtn setImage:[UIImage imageNamed:@"clipPhoto"] forState:UIControlStateNormal];
    [clipBtn setImage:[UIImage imageNamed:@"backPhoto"] forState:UIControlStateSelected];
    [clipBtn addTarget:self action:@selector(clip:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clipBtn];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBtn.frame = (CGRect){0,0, itemButtonSize};
    cancleBtn.center = CGPointMake(self.view.frame.size.width-sideBarSize.width/2, self.view.frame.size.height*(5.0/6.0f));
    if (_isTakePhoto == YES)
    {
        [cancleBtn setImage:[UIImage imageNamed:@"cancleCamera"] forState:UIControlStateNormal];
    }
    else
    {
        [cancleBtn setImage:[UIImage imageNamed:@"canclePhoto"] forState:UIControlStateNormal];
    }
    
    [cancleBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancleBtn];
}

- (void)back{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)clip:(UIButton *)btn{
    
    btn.selected = !btn.selected;
    
    self.isClip = btn.selected;
    
    if (btn.selected == YES) {
        _tkImageView.toCropImage = [_tkImageView currentCroppedImage];
    }else{
        
        _tkImageView.toCropImage = _image;
    
    }
}

- (void)sure{
    
    if (self.isTakePhoto) {
        //只要是拍照，先将原图存储到相册
        UIImageWriteToSavedPhotosAlbum(self.image, self, nil, nil);
    }
    
    //裁剪
    UIImage *image = [_tkImageView currentCroppedImage];
    if (self.isClip == YES) {
        
        //将裁剪后的图片存储到相册
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
        
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(clipPhoto:)]) {
        [self.delegate clipPhoto:image];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.picker dismissViewControllerAnimated:YES completion:nil];
    [self.controller dismissViewControllerAnimated:YES completion:nil];
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

@end
