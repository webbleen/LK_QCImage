//
//  ImageHelper
//  CustomPhoto
//
//  Created by zhao jun on 15/11/10.
//  Copyright © 2015年 李文斌. All rights reserved.
//

#import "ImageHelper.h"
#import "Utils.h"
#import "TXYBase.h"
#import "AuthenticationMgr.h"
#import "QCImageViewController.h"

static NSString* g_gameObject;

void QCSendMessage2Unity(NSString* func, NSString* msg)
{
    NSLog(@"obj:%@,func:%@,msg:%@", g_gameObject, func, msg);
    //UnitySendMessage([g_gameObject UTF8String], [func UTF8String], [msg UTF8String]);
}

@interface ImageHelper () <QCImageDelegate>


@end

@implementation ImageHelper

@synthesize mFileId;

+ (ImageHelper *)shareInstance
{
    static ImageHelper *g_instance = nil;
    if (g_instance == nil) {
        g_instance = [[ImageHelper alloc] init];
    }
    
    return  g_instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.uploadManager = [[TXYUploadManager alloc] initWithPersistenceId:@"PersitenceId"];
    }
    return self;
}

//#pragma makr 获取当前的UiewController
- (UIViewController*)getCurrentVC
{
    UIViewController *currentVC = nil;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        currentVC = nextResponder;
    }
    else {
        currentVC = window.rootViewController;
    }
    
    return  currentVC;
}

#pragma mark -- QCloud初始化
- (void)QCloudInit:(NSString *)gameObj
{
    //	APP注册，在使用其他接口之前必须先调用此方法进行用户信息初始化
    g_gameObject = gameObj;
    [[AuthenticationMgr shareInstance] registerAuthentication];
}

#pragma mark -- 使用相机
- (void)useCamera:(NSString *)fileId
{
    mFileId = fileId;
    
    // TODO:打开相机
    [[QCImageViewController shareInstance] useCameraWithDelegate:self];
}

#pragma mark -- 使用相册
- (void)usePhoto:(NSString *)fileId
{
    mFileId = fileId;
    
    // TODO:打开相册
    [[QCImageViewController shareInstance] usePhotoWithDelegate:self];
}




#pragma didSelectImage
-(void)didSelectImage:(UIImage *)image
{
    [_imageView setImage:image];
    //[self performSelector:@selector(saveImage:)  withObject:image afterDelay:0.5];
}

- (void)saveImage:(UIImage *)image
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *headImgPath = [NSString stringWithFormat:@"%@/Data/HeadImg",documentsDirectory];
    //[FileUtils addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:headImgPath]];// 设置不上传icloude标志，很重要，不设审核不过;
    
    NSString *imageFilePath = [NSString stringWithFormat:@"%@/%@.jpg",headImgPath, mFileId];
    NSLog(@"imageFile->>%@",imageFilePath);
    BOOL success = [fileManager fileExistsAtPath:imageFilePath];
    
    NSError *error;
    if(success) {
        success = [fileManager removeItemAtPath:imageFilePath error:&error];
    }
    
    //UIImage *smallImage = [self thumbnailWithImageWithoutScale:image size:CGSizeMake(240, 240)];
    // 布局调整;
    UIImage *adjustedImage = [self subImageRect:image];
    // 设置缩略图
    UIImage *smallImage=[self scaleFromImage:adjustedImage toSize:CGSizeMake(256.0f, 256.0f)];
    // 写入文件
    if (CheckPath(imageFilePath)) {
        [UIImageJPEGRepresentation(smallImage, 1.0f) writeToFile:imageFilePath atomically:YES];
    }
    //读取图片文件
    //UIImage *selfPhoto = [UIImage imageWithContentsOfFile:imageFilePath];
    //self.image.image = selfPhoto;
    
    // 选择并上传照片；
    [self selectImage:imageFilePath];
}

-(void)didSelectImageWithData:(NSData *)imageData
{
    
}


/**
 *  改变图像的尺寸，方便上传服务器
 *
 *  @param image 原始图像
 *  @param size  尺寸
 *
 *  @return 修改后的图像
 */
- (UIImage *) scaleFromImage: (UIImage *) image toSize: (CGSize) size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//图片裁剪
-(UIImage *)subImageRect:(UIImage *) image {
    
    if ([image size].height < [image size].width) {
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(([image size].width-[image size].height)/2, 0, [image size].height, [image size].height));
        UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        return croppedImage;
    }
    else
    {
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, ([image size].height-[image size].width)/2, [image size].width, [image size].width));
        UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        return croppedImage;
    }
}

#pragma mark -- 上传图片
- (void)selectImage:(NSString*)filePath
{
    NSLog(@"=========================================开始上传=========================================");
    if (!isFileExist(filePath)) {
        NSLog(@"上传失败！原因：保存图片错误。filePath:%@", filePath);
        QCSendMessage2Unity(@"onSelectPhotoFinish", @"");
        return;
    }
    
    NSString *fullName = [filePath lastPathComponent];
    if (fullName == nil) {
        NSLog(@"上传失败！原因：文件路径格式有误。filePath:%@", filePath);
        QCSendMessage2Unity(@"onSelectPhotoFinish", @"");
        return;
    }
    
    // 先检测是否已经存在图片
    [self checkImageExist:filePath];
}


#pragma mark -- 检测头像是否存在
-(BOOL)checkImageExist:(NSString *)ImagePath
{
    NSLog(@"****************************************开始查询*************************************");
    
    NSString *fullName = [ImagePath lastPathComponent];
    NSString *fileName = [[fullName componentsSeparatedByString:@"."] objectAtIndex:0];
    
    __block BOOL isExist = YES;
    
    __strong NSString *fileId = fileName;
    __strong NSString *imagePath = ImagePath;
    
    if (fileName == nil || [@"" isEqualToString:fileName]) {
        NSLog(@"FileId 传入有误");
        QCSendMessage2Unity(@"onSelectPhotoFinish", @"");
        return NO;
    }
    
    TXYFileStatCommand *statCommand = [[TXYFileStatCommand alloc] initWithFileId:fileName bucket:SPACE_NAME fileType:TXYFileTypePhoto];
    
    if(statCommand == nil){
        NSLog(@"查询头像失败, TXYFileStatCommand is nil, fileId = %@, ImagePath = %@", fileId, imagePath);
        QCSendMessage2Unity(@"onSelectPhotoFinish", @"");
        return NO;
    }
    
    [self.uploadManager sendCommand:statCommand sign:nil complete:^(TXYTaskRsp *resp) {
        
        if (resp.retCode >= 0)
        {
            TXYFileStatCommandRsp *statResp = (TXYFileStatCommandRsp *)resp;
            NSLog(@"%@",  [NSString stringWithFormat:@"%@",statResp.fileInfo.extendInfo]);
            NSLog(@"查询成功!，code:%d desc:%@", resp.retCode, resp.descMsg);
            [self deleteAndUpdate:imagePath];
            isExist = YES;
        }
        else
        {
            NSLog(@"查询失败，code:%d desc:%@", resp.retCode, resp.descMsg);
            [self uploadImage2QCloud:imagePath];
            isExist = NO;
        }
    }];
    
    return isExist;
}

- (void)uploadImage2QCloud:(NSString*)filePath
{
    NSString *fullName = [filePath lastPathComponent];
    NSString *fileName = [[fullName componentsSeparatedByString:@"."] objectAtIndex:0];
    // 上传图片;
    TXYPhotoUploadTask *uploadPhotoTask = [[TXYPhotoUploadTask alloc]initWithPath:filePath expiredDate:0 msgContext:nil bucket:SPACE_NAME fileId:fileName];
    if (uploadPhotoTask == nil) {
        NSLog(@"上传失败！原因:uploadPhotoTask is nil.");
        QCSendMessage2Unity(@"onSelectPhotoFinish", @"");
        return;
    }
    
    [self.uploadManager upload:uploadPhotoTask
                          sign:nil
                      complete:^(TXYTaskRsp *resp, NSDictionary *context) {
                          TXYPhotoUploadTaskRsp *photoResp = (TXYPhotoUploadTaskRsp *)resp;
                          //得到图片上传成功后的回包信息
                          NSString *picUrl = @"";
                          if (photoResp.photoURL && ![@"" isEqualToString:photoResp.photoURL]) {
                              picUrl = photoResp.photoURL;
                              NSLog(@"上传成功!,图片URL:%@", photoResp.photoURL);
                          }else{
                              NSLog(@"上传失败!，code:%d desc:%@", resp.retCode, resp.descMsg);
                          }
                          
                          QCSendMessage2Unity(@"onSelectPhotoFinish", picUrl);
                      }
                      progress:^(int64_t totalSize, int64_t sendSize, NSDictionary *context) {
                      }
                   stateChange:^(TXYUploadTaskState state, NSDictionary *context) {
                       switch (state) {
                           case TXYUploadTaskStateWait:
                               NSLog(@"任务等待中");
                               break;
                           case TXYUploadTaskStateConnecting:
                               NSLog(@"任务连接中");
                               break;
                           case TXYUploadTaskStateFail:
                               NSLog(@"任务失败");
                               break;
                           case TXYUploadTaskStateSuccess:
                               NSLog(@"任务成功");
                               break;
                           default:
                               break;
                       }
                   }];
}

-(void)deleteAndUpdate:(NSString *)ImagePath
{
    //    NSLog(@"****************************************开始删除*************************************");
    
    if (ImagePath == nil || [@"" isEqualToString:ImagePath]) {
        NSLog(@"路径传入有误");
        QCSendMessage2Unity(@"onSelectPhotoFinish", @"");
        return;
    }
    
    NSString *fileIdTemp = [ImagePath lastPathComponent];
    if (fileIdTemp == nil) {
        NSLog(@"deleteAndUpdate::传入路径格式有误, ImagePath = %@", ImagePath);
        QCSendMessage2Unity(@"onSelectPhotoFinish", @"");
        return;
    }
    
    NSString *fileName = [[fileIdTemp componentsSeparatedByString:@"."] objectAtIndex:0];
    
    NSString *signStr = [[AuthenticationMgr shareInstance]getOneTimeSignature:fileName];
    
    if (signStr == nil || [@"" isEqualToString:signStr]) {
        NSLog(@"获取一次性签名失败");
        QCSendMessage2Unity(@"onSelectPhotoFinish", @"");
        return;
    }
    
    TXYFileDeleteCommand * fileDeleteCommand = [[TXYFileDeleteCommand alloc] initWithFileId:fileName bucket:SPACE_NAME fileType:TXYFileTypePhoto];
    [self.uploadManager sendCommand: fileDeleteCommand
                               sign:signStr
                           complete:^(TXYTaskRsp *resp) {
                               if (resp.retCode >= 0 ){
                                   [self uploadImage2QCloud:ImagePath];
                                   //成功
                               } else {
                                   NSLog(@"删除图像失败");
                                   QCSendMessage2Unity(@"onSelectPhotoFinish", @"");
                                   //失败
                               }
                           }];
    
}

-(void)deleteImage:(NSString *)fileId
{
    //     NSLog(@"****************************************开始删除*************************************");
    if (fileId == nil) {
        NSLog(@"删除头像失败,fileId is nil");
        QCSendMessage2Unity(@"onSelectPhotoFinish", @"");
        return;
    }
    NSString *signStr = [[AuthenticationMgr shareInstance]getOneTimeSignature:fileId];
    
    if (signStr == nil || [@"" isEqualToString:signStr]) {
        NSLog(@"获取一次性签名失败");
        QCSendMessage2Unity(@"onSelectPhotoFinish", @"");
        return;
    }
    
    TXYFileDeleteCommand * fileDeleteCommand = [[TXYFileDeleteCommand alloc] initWithFileId:fileId bucket:SPACE_NAME fileType:TXYFileTypePhoto];
    [self.uploadManager sendCommand: fileDeleteCommand
                               sign:signStr
                           complete:^(TXYTaskRsp *resp) {
                               if (resp.retCode >= 0 ){
                                   NSLog(@"删除头像成功");
                                   QCSendMessage2Unity(@"onDeletePhotoFinish", @"success");//成功
                               } else {
                                   NSLog(@"删除头像失败");
                                   QCSendMessage2Unity(@"onDeletePhotoFinish", @"fail");//失败
                               }
                           }];
}

@end
