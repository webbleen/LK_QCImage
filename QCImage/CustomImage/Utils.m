//
//  Utils.m
//  QCImage
//
//  Created by zhao jun on 15/11/10.
//  Copyright © 2015年 李文斌. All rights reserved.
//

#import "Utils.h"
#import "ImageHelper.h"

NSString* GetConfigWithKey(NSString* key)
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"upload" ofType:@"cfg"];
    NSString* pathString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray* array = [pathString componentsSeparatedByString:@"\n"];
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < array.count; i++) {
        [dic setObject:[[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1] forKey:[[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:0]];
    }
    
    
    NSString* value = [dic objectForKey:key];
    
    if (value) {
        return value;
    }
    else
    {
        return nil;
    }
}

BOOL isFileExist(NSString* filePath)
{
    if (filePath == nil || [@"" isEqualToString:filePath]) {
        return NO;
    }
    
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
        if(!isDir){
            return YES;
        }
    }
    return NO;
}

BOOL CheckPath(NSString *filePath)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    
    NSString *filePathRoot = [filePath stringByDeletingLastPathComponent];
    //NSLog(@"CheckPath:\n%@\n%@",filePath,filePathRoot);
    
    NSError *fwError = nil;
    
    BOOL isDir;
    
    if ([fileManager fileExistsAtPath:filePathRoot isDirectory:&isDir]) {
        if(!isDir){
            [fileManager createDirectoryAtPath:filePathRoot withIntermediateDirectories:YES attributes:nil error:&fwError];
        }
    }
    else{
        [fileManager createDirectoryAtPath:filePathRoot withIntermediateDirectories:YES attributes:nil error:&fwError];
    }
    
    if(fwError != nil){
        NSString *errInfo = [NSString stringWithFormat:@"CheckPath Failed [%@] [%@]",filePath,fwError];
        NSLog(@"%@", errInfo);
        return FALSE;
    }
    
    return TRUE;
}


#if defined(__cplusplus)
extern "C" {
#endif

    NSString* QCreateString(const char* str){
        if (str)
            return [NSString stringWithUTF8String:str];
        else
            return [NSString stringWithUTF8String:""];
    }
    
    void QCloudInit(const char * objName)
    {
        [[ImageHelper shareInstance] QCloudInit:QCreateString(objName)];
    }
    
    void StartUploadHeadImage(bool bParam, const char* fileId)
    {
        if (bParam) {
            // 使用相机
            [[ImageHelper shareInstance] useCamera:QCreateString(fileId)];
        }
        else
        {
            // 使用相册
            [[ImageHelper shareInstance] usePhoto:QCreateString(fileId)];
        }
    }
    
    void DeleteHeadImage(const char* fileId)
    {
        [[ImageHelper shareInstance]  deleteImage:QCreateString(fileId)];
    }
    
    
#if defined(__cplusplus)
}
#endif

