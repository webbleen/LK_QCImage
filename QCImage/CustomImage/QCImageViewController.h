//
//  QCImageViewController.h
//  QCImage
//
//  Created by wzh on 2017/9/26.
//  Copyright © 2017年 李文斌. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

@protocol QCImageDelegate <NSObject>

/**
 *  选择完Image回调
 *
 *  @param image 图片对象
 */
- (void) didSelectImage:(UIImage*)image;
- (void) didSelectImageWithData:(NSData*)imageData;

@end

@interface QCImageViewController : UIViewController

@property (weak, nonatomic) id<QCImageDelegate> delegate;

+ (QCImageViewController *)shareInstance;

- (void)useCameraWithDelegate:(id<QCImageDelegate>)delegate;
- (void)usePhotoWithDelegate:(id<QCImageDelegate>)delegate;

@end
