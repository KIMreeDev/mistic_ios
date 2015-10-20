//
//  DateTimeHelper.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-4-18.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "DateTimeHelper.h"

@implementation DateTimeHelper
//（获得时间的长短）
+ (NSString *)formatStringWithDate:(NSDate *)date {
//    NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
//    [NSTimeZone setDefaultTimeZone:timeZone];
  NSString *result;
  NSTimeInterval interval = -[date timeIntervalSinceNow];
  if (interval<0 || !date) {
    result = @"just";//不同国家，不同时区，会造成本地时间比较为负，则为刚刚
  }else if (interval<60) {
    result =NSLocalizedString(@"just", nil);
  }else if (interval/60<60) {
    //小于60分钟
    result = [NSString stringWithFormat:NSLocalizedString(@"%d minutes ago", nil),(NSInteger)interval/60];
  }else if(interval/60/60<24){
    //小于24小时
    result = [NSString stringWithFormat:NSLocalizedString(@"%d hours ago", nil),(NSInteger)interval/60/60];
  }else{
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      result = [formatter stringFromDate:date];
  }
  
  return result;
}

//设置日期的格式
+ (NSString *)stringWithDate:(NSDate *)date format:(NSString *)format
{
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:format];
//  NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
//    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
//    [formatter setTimeZone:timeZone];
  return [formatter stringFromDate:date];
}

//中间持续天数
+ (NSInteger)daysFromDate:(NSDate *) startDate toDate:(NSDate *) endDate {
  NSTimeInterval start = [startDate timeIntervalSince1970];
  NSTimeInterval over = [endDate timeIntervalSince1970];
  NSInteger days = ceil((over - start)/(24*60*60));
  return days;
}

//中间持续秒数
+ (float)secondsFromDateToNow:(NSString *)startDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *oldDate= [formatter dateFromString:startDate];
    NSTimeInterval durationTime = [oldDate timeIntervalSinceNow];
    return fabs(durationTime);
}

+ (float)secondsFrom:(NSDate *)oldDate toNow:(NSDate *)nowDate
{
    NSTimeInterval durationTime = [oldDate timeIntervalSinceDate:nowDate];
    return fabs(durationTime);
}

//从字符串中，获取年、月、日、小时、分钟、秒
+(NSInteger)getsFromDateString:(NSString *)dateStr Flag:(NSString *)flag Format:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //将字符串转为日期格式
    [dateFormatter setDateFormat:format];
    NSDate *date =[dateFormatter dateFromString:dateStr];
    //创建日历，获取年、月、日、小时、分钟、秒
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    
    if ([flag isEqual:@"year"]) {
        return [dateComponent year];
    }
    else if ([flag isEqual:@"month"]) {
        return [dateComponent month];
    }
    else if ([flag isEqual:@"day"])
    {
        return [dateComponent day];
    }
    else if ([flag isEqual:@"hour"])
    {
        return [dateComponent hour];;
    }
    else if ([flag isEqual:@"minute"])
    {
        return [dateComponent minute];//分
    }
    else
    {
        return [dateComponent second];//秒
    }
}

//获取小时、分钟、秒(00:00:01时触发)
+ (BOOL)getHoursMinutesSeconds
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:[NSDate date]];
    return  ([dateComponent hour]==0)&&
            ([dateComponent minute]==0)&&
            ([dateComponent second]==1) ;
}

//由字符串HH:mm:ss转换为日期，并获取秒 
+ (NSTimeInterval)secondsFromDate:(NSString *) startDate toDate:(NSString *) endDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *startD = [formatter dateFromString:startDate];
    NSDate *endD = [formatter dateFromString:endDate];
    return [endD timeIntervalSinceDate:startD];
}

//原字符串日期转换指定格式的字符串日期
+ (NSString *)dateFromStr:(NSString *)dateStr oldFormat:(NSString *)oldFormat newFormat:(NSString *)newFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //将字符串转为指定格式
    [dateFormatter setDateFormat:oldFormat];
    NSDate *date =[dateFormatter dateFromString:dateStr];
    [dateFormatter setDateFormat:newFormat];
    return [dateFormatter stringFromDate:date];
}

//判断两个日期是否是同一时间
+(BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    return [comp1 day]  == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year] &&
    [comp1 hour] == [comp2 hour] &&
    [comp1 minute] == [comp2 minute] &&
    [comp1 second] == [comp2 second]
    ;
}

//根据十六进制数据判断两个日期是否同一时间（精确到时分秒）
+ (BOOL)isNowTheTimeFrom16Sys:(NSString *)strData
{
    if ([[LocalStroge sharedInstance].dateArr count] == 2) {
        [[LocalStroge sharedInstance].dateArr removeAllObjects];
    }
    //传进来的时间(转化成整型10进制)
    unsigned long long nowTime = 0.0;
    NSScanner* scan = [NSScanner scannerWithString:strData];
    [scan scanHexLongLong:&nowTime];
    
    //计算出传进来的准确日期(单位：100毫秒),判断是否为今天
    NSDate *resultDate = [NSDate dateWithTimeIntervalSince1970:(double)nowTime/10];
    //存储蓝牙发来的数据
    if ([[LocalStroge sharedInstance].dateArr count] < 2) {
        [[LocalStroge sharedInstance].dateArr addObject:resultDate];
    }
    return YES;
}

//获取当前系统的时间戳
+(long long int)getTimeSp
{
    long long time;
    NSDate *fromdate=[NSDate date];
    time=(long long int)[fromdate timeIntervalSince1970]*10;//单位100毫秒
    return time;
}

//10进制转16进制(共10位，不够补位)
+(NSString *)ToHex:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;  
        }
    }
    NSMutableString *mutString = [DateTimeHelper stringByReversed:str];
    [mutString insertString:@"D300" atIndex:0];
    [mutString appendString:@"000000000000000000"];

    NSInteger sum = 0;
    for (int i = 0; i < mutString.length; i ++) {
        if ((i+1)%2 == 0) {
            NSScanner* scan = [NSScanner scannerWithString:[mutString substringWithRange:NSMakeRange(i-1,2)]];
            unsigned int n = 0;
            [scan scanHexInt:&n];
            sum += n;
        }
    }
    NSString *str2 = [self str16ToStr:sum];
    NSMutableString *sumStr = [DateTimeHelper sumByReversed:str2];
    [mutString replaceCharactersInRange:NSMakeRange(28,4) withString:sumStr];
//    mutString = [NSMutableString stringWithString:@"d300000000060000000000000000d900"] ;
    return mutString;

}
//重复上面的函数
+ (NSString *)str16ToStr:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str = @"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    return str;
}
//发送数据时,16进制数－>Byte数组->NSData,加上校验码部分
+(NSData *)stringToByte:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

+ (NSString*)getPreferredLanguage

{
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    
    NSLog(@"当前语言:%@", preferredLang);
    
    return preferredLang;
    
}

//反转16进制字符串（10位）
+ (NSMutableString *)stringByReversed:(NSString *)str
{
    NSMutableString *resultStr = [[NSMutableString alloc]init];
    NSMutableString *reversedStr = [NSMutableString stringWithString:str];
    //补位(10位)
    if (str.length < 10) {
        for (NSInteger i = 0; i < 10-str.length; i ++) {
            [reversedStr insertString:@"0" atIndex:0];
        }
    }
    else{
        [reversedStr setString:[str substringWithRange:NSMakeRange(0, 10)]];
    }
    //反转
    for (NSInteger i = 0; i < reversedStr.length; i++) {
        if ((i+1)%2 == 0) {
            [resultStr insertString:[reversedStr substringWithRange:NSMakeRange(i-1, 2)] atIndex:0];
        }
    }
    return resultStr;
}
//反转16进制的和（4位）
+ (NSMutableString *)sumByReversed:(NSString *)str
{
    NSMutableString *resultStr = [[NSMutableString alloc]init];
    NSMutableString *reversedStr = [NSMutableString stringWithString:str];
    if (str.length < 4) {
        for (NSInteger i = 0; i < 4-str.length; i ++) {
            [reversedStr insertString:@"0" atIndex:0];
        }
    }
    else{
        [reversedStr setString:[str substringWithRange:NSMakeRange(0, 4)]];
    }
    //反转
    for (NSInteger i = 0; i <= reversedStr.length; i++) {
        if ((i+1)%2 == 0) {
            [resultStr insertString:[reversedStr substringWithRange:NSMakeRange(i-1, 2)] atIndex:0];
        }
    }
    return resultStr;
}

+ (NSMutableString *)sumByReversed2:(NSString *)str
{
    NSMutableString *resultStr = [[NSMutableString alloc]init];
    //反转
    for (NSInteger i = 0; i <= str.length; i++) {
        if ((i+1)%2 == 0) {
            [resultStr insertString:[str substringWithRange:NSMakeRange(i-1, 2)] atIndex:0];
        }
    }
    return resultStr;
}

//电池杆电压（V1）蓝牙模块电压（V2）电池杆电流（C）
+ (NSArray *)subStringWith16Sys:(NSString *)str
{
    unsigned long long v1 = 0.0;
    unsigned long long v2 = 0.0;
    unsigned long long cc = 0.0;
    unsigned long long z1 = 0.0;
    NSScanner* scan = [NSScanner scannerWithString:(NSString *)[self sumByReversed:[str substringWithRange:NSMakeRange(14, 4)]]];
    [scan scanHexLongLong:&v1];
    
    scan = nil;
    scan = [NSScanner scannerWithString:(NSString *)[self sumByReversed:[str substringWithRange:NSMakeRange(18, 4)]]];
    [scan scanHexLongLong:&v2];
    
    scan = nil;
    scan = [NSScanner scannerWithString:(NSString *)[self sumByReversed:[str substringWithRange:NSMakeRange(22, 4)]]];
    [scan scanHexLongLong:&cc];
    
    scan = nil;
    scan = [NSScanner scannerWithString:(NSString *)[self sumByReversed2:[str substringWithRange:NSMakeRange(26, 2)]]];
    [scan scanHexLongLong:&z1];
    
    return [NSArray arrayWithObjects:@(v1), @(v2), @(cc), @(z1), nil];
}

//判断是否空载
+ (BOOL)isNoLoad:(NSString *)str
{
    unsigned long long noload = 0.0;
    NSScanner* scan = [NSScanner scannerWithString:(NSString *)[self sumByReversed:[str substringWithRange:NSMakeRange(22, 4)]]];
    [scan scanHexLongLong:&noload];
    float ee = noload*1.2*1000/(2*1024*22);  //电池杆电流
//    NSLog(@"现在的电池杆电流为：%f, 是否空载：%i", ee, ee<0.5);
    return ee<0.5;
}

//把标准时间转换成正常时间
+ (NSDate *)getLocalDateFormateUTCDate:(NSDate *)date
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date];
    return destinationDateNow;
}

@end












