//
//  ClipViewController.h
//  QCImage
//
//  Created by wzh on 2017/9/26.
//  Copyright © 2017年 李文斌. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClipPhotoDelegate <NSObject>

- (void)clipPhoto:(UIImage *)image;

@end

@interface ClipViewController : UIViewController
@property (strong, nonatomic) UIImage *image;

@property (nonatomic, strong) UIImagePickerController *picker;

@property (nonatomic, strong) UIViewController *controller;

@property (nonatomic, weak) id<ClipPhotoDelegate> delegate;

@property (nonatomic, assign) BOOL isTakePhoto;
@end
