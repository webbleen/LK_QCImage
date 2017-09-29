//
//  Utils.h
//  CustomPhoto
//
//  Created by zhao jun on 15/11/10.
//  Copyright © 2015年 李文斌. All rights reserved.
//

#ifndef CustomHeadImage_Utils_h
#define CustomHeadImage_Utils_h

#import <Foundation/Foundation.h>

#define APP_ID GetConfigWithKey(@"app_id")
#define SIGN_URL GetConfigWithKey(@"sign_url")
#define SPACE_NAME GetConfigWithKey(@"space_name")

NSString* GetConfigWithKey(NSString* key);
BOOL isFileExist(NSString *filePath);
BOOL CheckPath(NSString *filePath);

#endif /* Utils_h */
