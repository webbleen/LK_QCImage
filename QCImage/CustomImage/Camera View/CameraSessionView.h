//
//  CACameraSessionDelegate.h
//
//  Created by Christopher Cohen & Gabriel Alvarado on 1/23/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

#import <UIKit/UIKit.h>

///Protocol Definition
@protocol CACameraSessionDelegate <NSObject>

@optional - (void)didCaptureImage:(UIImage *)image;
@optional - (void)didCaptureImageWithData:(NSData *)imageData;

@end

@interface CameraSessionView : UIView

//Delegate Property
@property (nonatomic, weak) id <CACameraSessionDelegate> delegate;

//API Functions
- (void)setSideBarColor:(UIColor *)sideBarColor;
- (void)hideFlashButton;
- (void)hideCameraToggleButton;

@end
