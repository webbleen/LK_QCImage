#ifndef CustomHeadImage_ImageHelper_h
#define CustomHeadImage_ImageHelper_h


//
//  ImageHelper
//  CustomPhoto
//
//  Created by zhao jun on 15/11/10.
//  Copyright © 2015年 李文斌. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TXYUploadManager.h"


#define DECLARE_WEAK_SELF __typeof(&*self) __weak weakSelf = self
#define DECLARE_STRONG_SELF __typeof(&*self) __strong strongSelf = weakSelf

@interface ImageHelper : NSObject

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, retain) NSString *mFileId;
//图片上传和操作的UploadManager
@property (nonatomic, strong)   TXYUploadManager *uploadManager;

+ (ImageHelper *)shareInstance;

- (void)QCloudInit:(NSString*)gameObj;

- (void)useCamera:(NSString *)fileId;

- (void)usePhoto:(NSString *)fileId;

-(void)deleteImage:(NSString *)fileId;

- (void)selectImage:(NSString*)filePath;


@end

#endif
