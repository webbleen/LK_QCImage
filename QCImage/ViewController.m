//
//  ViewController.m
//  QCImage
//
//  Created by linekong on 25/09/2017.
//  Copyright © 2017 Webb. All rights reserved.
//

#import "ViewController.h"
#import "ImageHelper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIColor *flatGreenColor = [UIColor colorWithRed:46/255.0f green:204/255.0f blue:113/255.0f alpha:1.0f];
    UIColor *flatRedColor = [UIColor colorWithRed:231/255.0f green:76/255.0f blue:60/255.0f alpha:1.0f];
    UIColor *flatBlueColor = [UIColor colorWithRed:52/255.0f green:152/255.0f blue:219/255.0f alpha:1.0f];
    UIColor *flatPurpleColor = [UIColor colorWithRed:155.0f/255.0f green:89.0f/255.0f blue:182.0f/255.0f alpha:1.0];
    UIColor *flatOrangeColor = [UIColor colorWithRed:230.0f/255.0f green:126.0f/255.0f blue:34.0f/255.0f alpha:1.0];
    
    NSArray *btns = @[self.btnUseCamera,self.btnUsePhoto,self.btnDeleteImage];
    NSArray *colors = @[flatGreenColor,flatBlueColor,flatPurpleColor,flatOrangeColor,flatRedColor];
    NSArray *titles = @[@"使用相机", @"使用相册",@"删除图片"];
    
    for (int i = 0 ;i<btns.count; i++) {
        int j = i<colors.count?i:i%colors.count;
        JTImageButton *btn = [btns objectAtIndex:i];
        UIColor *color = [colors objectAtIndex:j];
        [btn createTitle:[titles objectAtIndex:i] withIcon:nil font:[UIFont systemFontOfSize:21.0] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
        btn.titleColor = color;
        btn.iconColor = color;
        btn.padding = JTImageButtonPaddingSmall;
        btn.borderColor = color;
        btn.iconSide = JTImageButtonIconSideRight;
        btn.touchEffectEnabled = true;
    }
    
//    [[ImageHelper shareInstance] QCloudInit:@"gameObject"];
    [[ImageHelper shareInstance] setImageView:_imageView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Action

- (IBAction)useCamera:(id)sender {
    [[ImageHelper shareInstance] useCamera:@"sszj_123456_4375686"];
}

- (IBAction)usePhoto:(id)sender {
    [[ImageHelper shareInstance] usePhoto:@"sszj_123456_4375686"];
}

- (IBAction)deleteImage:(id)sender {
    
}

@end
