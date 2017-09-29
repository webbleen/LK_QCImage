//
//  AuthenticationMgr.m
//  CustomPhoto
//
//  Created by zhao jun on 15/11/9.
//  Copyright © 2015年 李文斌. All rights reserved.
//

#import "AuthenticationMgr.h"
#import "TXYUploadManager.h"
#import "TXYDownloader.h"

#import "Utils.h"

#define monthInSeconds(x) (x * 30 * 24* 60 * 60)

@implementation AuthenticationMgr


+ (AuthenticationMgr *)shareInstance
{
    static AuthenticationMgr *g_instance = nil;
    static  dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        g_instance = [[AuthenticationMgr alloc] init];
    });
    return g_instance;
}

- (id)init
{
    if (self = [super init])
    {
        //业务Id，用户需要向QCloud申请
        self.appId = APP_ID;
        //用户Id，用户自己根据需要选填
        self.userId = @"0";
        //
        self.bucket = SPACE_NAME;
    }
    return self;
}


- (void)registerAuthentication
{
    [self signatureWithURL:SIGN_URL]; //此URL是我们demo的服务器的地址这个地方需要替换成使用者的服务器地址
}

-(void)UploadManagerInit:(NSString *)signStr
{
    NSLog(@"TXYUploadManager初始化");
    
    if (signStr == nil) {
        NSLog(@"获取签名为空, 初始化失败");
        return;
    }
    [TXYUploadManager authorize:APP_ID userId:@"0" sign:signStr];
    NSLog(@"TXYUploadManager初始化已执行");
}

#pragma mark -- 向业务后台拉取签名
- (void)signatureWithURL:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        NSLog(@"获取签名地址错误");
        return;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:10];
    
    if (request == nil) {
        NSLog(@"signatureWithURL::NSMutableURLRequest is nil,url = %@", url);
        return;
    }
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (conn == nil) {
        NSLog(@"signatureWithURL::NSURLConnection is nil,url = %@", url);
        return;
    }
    
    [conn start];
}

- (NSString *)getOneTimeSignature:(NSString *)operURL
{
    NSString *img = SIGN_URL;
    NSString *imgUrl = [NSString stringWithFormat:@"%@?type=copy&fileid=%@",img,operURL];// 需要单词签名的接口如，删除，复制等，请求的网络的接口需要用户自定义
    
    NSURL *url = [NSURL URLWithString:imgUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 10;
    
    NSHTTPURLResponse *httpResponse = nil;
    NSError *connectionError = nil;
    NSData *signData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&connectionError];
    
    if(signData == nil){
        NSLog(@"获取一次性签名数据失败, connectionError = %@", connectionError);
        return nil;
    }
    
    NSString *signature = nil;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:signData options:kNilOptions error:nil];
    if (responseDic == nil) {
        NSLog(@"获取一次性签名失败,内容为空");
        return nil;
    }
    signature = [responseDic objectForKey:@"sign"] ;
    
    return signature;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"接收到服务器的响应");
    //初始化数据
    if (self.receiveData != nil) {
        self.receiveData = nil;
    }
    
    self.receiveData = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receiveData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *signature = nil;
    NSDictionary *signDic = [NSJSONSerialization JSONObjectWithData:self.receiveData options:kNilOptions error:nil];
    if(signDic == nil)
    {
        NSLog(@"获取签名失败,内容为空");
        return;
    }
    signature = [signDic objectForKey:@"sign"] ;
    [self UploadManagerInit:signature];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"获取永久签名失败, error = %@", error);
}


- (NSString *)encodeURL:(NSString *)url
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[url UTF8String];
    long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
@end
