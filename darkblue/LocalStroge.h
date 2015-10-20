//
//  LocalStroge.h
//  ECIGARFAN
//
//  Created by renchunyu on 14-5-16.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+Encryption.h"
#import "EcigarfanModel.h"
#define F_USER_INFORMATION @"user_information"              //用户信息
@interface LocalStroge : NSObject

//创建带NSMutableArray目录
-(void) buildFileForKey:(NSString*)str witharray:(NSMutableArray*)array filePath:(NSSearchPathDirectory)folder;
+ (LocalStroge *)sharedInstance; //初始化
@property(nonatomic, strong) NSMutableDictionary *allInfo;  //所有数据
@property(nonatomic, strong) NSMutableArray *dateArr;   //存储蓝牙发来的时间

- (void)setInfo:(id)object forKey:(NSString *)key;//修改属性信息
- (void)loadCacheAllInfo;//载入所有数据
- (void)addAllInfo:(NSMutableDictionary *)object;//添加所有信息到本地
- (void)deleteAllInfo;//删除所有信息
- (NSInteger)dataSorting;//数据排序
@end

