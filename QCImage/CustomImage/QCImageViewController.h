//
//  QCImageViewController.h
//  Unity-iPhone
//
//  Created by linekong on 04/01/2017.
//
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
