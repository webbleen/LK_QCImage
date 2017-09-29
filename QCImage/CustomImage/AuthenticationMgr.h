//
//  AuthenticationMgr.h
//  CustomPhoto
//
//  Created by zhao jun on 15/11/9.
//  Copyright © 2015年 李文斌. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthenticationMgr : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *bucket;
@property (nonatomic, strong) NSString *signature;
@property (nonatomic, retain) NSMutableData *receiveData;

+ (AuthenticationMgr *)shareInstance;

/*** 注册上传下载的鉴权信息 ***/
- (void)registerAuthentication;

/** 为了保证数据的安全，每一次文件删除，复制这些操作，业务需要向后台申请一个一次性的签名 */
- (NSString *)getOneTimeSignature:(NSString *)operURL;

@end
