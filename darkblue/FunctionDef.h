//
//  FunctionDef.h
//  darkblue
//
//  Created by renchunyu on 14-7-3.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#ifndef Mistic_FunctionDef_h
#define Mistic_FunctionDef_h

#define IS_INCH4 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IOS7 [[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0
#define S_APPDELEGATE ((AppDelegate *) [[UIApplication sharedApplication] delegate])
#define kScreen_Height   ([UIScreen mainScreen].bounds.size.height)
#define kScreen_Width    ([UIScreen mainScreen].bounds.size.width)
#define K_END   @"end"
//UserDefaults
#define S_USER_DEFAULTS [NSUserDefaults standardUserDefaults]
//Store all_Smoking
#define S_ALL_SMOKING [[LocalStroge sharedInstance].allInfo objectForKey:F_ALL_SMOKING]
//颜色
#define F_COLOR_RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define F_COLOR_RGB(r,g,b) F_COLOR_RGBA(r,g,b,1.0)

//文件路径
#define F_PATH_IN_DOCUMENTS(path) [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",path]]
#define F_PATH_IN_BUNDLE(name,type) [[NSBundle mainBundle] pathForResource:name ofType:type]

//图片
#define F_IMG(name) [UIImage imageNamed:name]

//JSON
#define F_JSON_REPLACE_NULL(x)        [[x stringByReplacingOccurrencesOfString : @":null" withString : @":\"\""] stringByReplacingOccurrencesOfString : @":NaN" withString : @":\"0\""]
#endif
