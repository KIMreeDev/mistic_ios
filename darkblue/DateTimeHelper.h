//
//  DateTimeHelper.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-4-18.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateTimeHelper : NSObject
+ (NSString *)formatStringWithDate:(NSDate *)date;
+ (NSString *)stringWithDate:(NSDate *)date format:(NSString *)format;
+ (NSInteger)daysFromDate:(NSDate *) startDate toDate:(NSDate *) endDate;
+ (float)secondsFromDateToNow:(NSString *) startDate;
+ (float)secondsFrom:(NSDate *)oldDate toNow:(NSDate *)nowDate;
+ (NSDate *)getLocalDateFormateUTCDate:(NSDate *)date;//把标准时间转换成正常时间
+ (NSInteger)getsFromDateString:(NSString *)dateStr Flag:(NSString *)flag Format:(NSString *)format;
//把标准时间转换成正常时间

//创建日历，获取小时、分钟、秒
+ (BOOL)getHoursMinutesSeconds;
//字符串转换指定格式的字符串日期
+ (NSString *)dateFromStr:(NSString *)dateStr oldFormat:(NSString *)oldFormat newFormat:(NSString *)newFormat;
//由字符串HH:mm:ss转换为日期，并获取秒
+ (NSTimeInterval)secondsFromDate:(NSString *) startDate toDate:(NSString *) endDate;

//根据十六进制数据判断是否现在的时间
+ (BOOL)isNowTheTimeFrom16Sys:(NSString *)strData;
//获取当前系统的时间戳
+ (long long int)getTimeSp;
//10进制转16进制
+ (NSString *)ToHex:(long long int)tmpid;
//发送数据时,16进制数－>Byte数组->NSData,加上校验码部分
+ (NSData *)stringToByte:(NSString*)string;
//字符串反转
+ (NSMutableString *)stringByReversed:(NSString *)str;
+ (NSMutableString *)sumByReversed:(NSString *)str;
//提取电压
+ (NSArray *)subStringWith16Sys:(NSString *)str;
+ (NSMutableString *)sumByReversed2:(NSString *)str;
//是否空载
+ (BOOL)isNoLoad:(NSString *)str;
+ (NSString*)getPreferredLanguage;
@end
