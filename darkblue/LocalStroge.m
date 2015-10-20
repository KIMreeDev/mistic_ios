//
//  LocalStroge.m
//  ECIGARFAN
//
//  Created by renchunyu on 14-5-16.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import "LocalStroge.h"
#import "ArchiveServer.h"
#import "DateTimeHelper.h"
static LocalStroge *instance;
@interface LocalStroge (){
    NSString *blueIdentify;
}
@end
@implementation LocalStroge

#pragma mark ======================================= build file with NSMutableArray
-(void) buildFileForKey:(NSString*)str witharray:(NSMutableArray*)array filePath:(NSSearchPathDirectory)folder
{
    NSString *Path = [NSSearchPathForDirectoriesInDomains(folder, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filepath=[Path stringByAppendingPathComponent:str];
    [NSKeyedArchiver archiveRootObject:array toFile:filepath];
}

- (id)init
{
    self = [super init];
    if (self) {
        _allInfo = [[NSMutableDictionary alloc] init];  //所有信息
        _dateArr = [[NSMutableArray alloc]init];        //蓝牙发来的吸烟数据
    }
    return self;
}
/*
* @brief 初始化
*/
+ (LocalStroge *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LocalStroge alloc] init];
    });
    return instance;
}
/*
 归档
 */
- (void)archiveAllInfo:(NSDictionary *)object key:(NSString *)key
{
    [[ArchiveServer defaultArchiver] archiveObject:object key:key];
}
/*
 载入本地所有数据
 */
- (void)loadCacheAllInfo
{
    blueIdentify = (NSString *)[S_USER_DEFAULTS objectForKey:BLUEIDENTIFY];//取得最后蓝牙标识，在连入蓝牙时所存储
    //组合Key进行存储
    NSString *myFile = ALLINFO;
    if (blueIdentify) {
        myFile = [NSString stringWithFormat:@"%@_%@", ALLINFO, blueIdentify];
    }

    NSDictionary *dic = [[ArchiveServer defaultArchiver] unarchiveWithKey:myFile];
    _allInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    //如果信息为空，用allinfo.plist文件中的信息进行初始化
    if (!dic) {
        //读取plist
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"allinfo" ofType:@"plist"];
        NSMutableDictionary *plistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        _allInfo = [[NSMutableDictionary alloc] initWithDictionary:plistDic];
        
        //默认属性设置
        [self defaultProperty];
    }
}
/*
 修改配置信息
 */
- (void)setInfo:(id)object forKey:(NSString *)key
{
    [_allInfo setObject:object forKey:key];
}
/*
 添加所有信息到本地
 */
- (void)addAllInfo:(NSDictionary *)object
{
    NSString *myFile = ALLINFO;
    if (blueIdentify) {
        myFile = [NSString stringWithFormat:@"%@_%@", ALLINFO, blueIdentify];
    }
    //组合Key进行存储
    if (!object) {
        [self archiveAllInfo:_allInfo key:myFile];
        return;
    }
    [self archiveAllInfo:object key:myFile];
}
/*
 删除所有信息
 */
- (void)deleteAllInfo
{
    NSString *myFile = ALLINFO;
    NSArray			*storedDevices	= [S_USER_DEFAULTS arrayForKey:U_STORED_DEVICES];
    
    for (NSString *uuid in storedDevices) {
        myFile = [NSString stringWithFormat:@"%@_%@", ALLINFO, uuid];
        [[ArchiveServer defaultArchiver] cleanArchiveWithKey:myFile];
    }
    
    [_allInfo removeAllObjects];
    
    NSMutableArray	*newDevices		= [NSMutableArray array];
    [S_USER_DEFAULTS setObject:newDevices forKey:U_STORED_DEVICES];
    [S_USER_DEFAULTS synchronize];
    
}

/*
 数据排序
 */
- (NSInteger)dataSorting
{
    //当数据缺失时，将该次数据置空
    if ([_dateArr count] != 2) {
        [_dateArr removeAllObjects];
        return -1;
    }
    //年、月、日
    NSMutableArray *allDates = [_allInfo objectForKey:F_ALL_SMOKING];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    NSDate *startDate = (NSDate *)[_dateArr objectAtIndex:0];
    NSDate *endDate = (NSDate *)[_dateArr objectAtIndex:1];
    NSString *date85 = [formatter stringFromDate:startDate];

    //创建天信息
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"dayinfo" ofType:@"plist"];
    NSMutableDictionary *dayInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    [dayInfo setObject:startDate forKey:F_TIME];
    NSInteger isStillSmoking = [[S_USER_DEFAULTS objectForKey:F_STILL_SMOKE]integerValue];
    if (isStillSmoking) {
        [dayInfo setObject:[S_USER_DEFAULTS objectForKey:F_CIGARETTES_DAY] forKey:F_CIGS_SMOKE];
    }
    else{
        [dayInfo setObject:[NSNumber numberWithInteger:0] forKey:F_CIGS_SMOKE];
    }

    //创建时刻信息
    NSMutableDictionary *scheduleDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:startDate, F_SCHEDULE_TIME, nil];
    float secondS = fabs([startDate timeIntervalSinceDate:endDate]);
    if (secondS<0.5 || secondS>30) {
        [_dateArr removeAllObjects];
        return -1;
    }
    [scheduleDic setObject:[NSNumber numberWithFloat:secondS] forKey:F_DURATION_TIME];
    [[dayInfo objectForKey:F_SCHEDULE] addObject:scheduleDic];
    [allDates addObject:dayInfo];
    
    NSInteger dateIndex = 0;
    //排序(先确定日期天，再确定时分秒)
    for (NSInteger i = [allDates count]-2; i>=0; i --) {
        NSMutableDictionary *everyDay = [allDates objectAtIndex:i];
        NSDate *tabDay = [everyDay objectForKey:F_TIME];
        NSComparisonResult result = [date85 compare:[formatter stringFromDate:tabDay] options:NSNumericSearch];
        //在同一天中的数据
        if (result == NSOrderedSame) {
            dateIndex = i;
            NSMutableArray *allSchedus = [everyDay objectForKey:F_SCHEDULE];
            [allSchedus addObject:scheduleDic];
            [allDates removeObjectAtIndex:i+1];
            for (int n = [allSchedus count]-2; n>=0; n --) {
                NSMutableDictionary *everSche = [allSchedus objectAtIndex:n];
                NSDate *tabTime = [everSche objectForKey:F_SCHEDULE_TIME];
                NSComparisonResult result2 = [startDate compare:tabTime];
                //如果该时刻存在即返回不存储
                if (result2 == NSOrderedSame) {
                    [allSchedus removeObjectAtIndex:n+1];
                    break;
                }
                //同一天的 （时分秒）时间排序
                if(result2 == NSOrderedAscending){
                    [allSchedus exchangeObjectAtIndex:n+1 withObjectAtIndex:n];
                }
            }
            break;
        }
        else if (result == NSOrderedDescending) //1
        {
            dateIndex = i+1;
            break;
        }
        else if (result == NSOrderedAscending) {//-1
            [allDates exchangeObjectAtIndex:i+1 withObjectAtIndex:i];
            dateIndex = i;
        }
    }
    //根据蓝牙传输的数据，计算那一天省的钱
    [self saveTheMoney:dateIndex];
    //清除数据
    [_dateArr removeAllObjects];
    return dateIndex;
}

- (void)saveTheMoney:(NSInteger)dateIndex
{
    if ((dateIndex<0) && (dateIndex>=[[_allInfo objectForKey:F_ALL_SMOKING]count]))
    {
        return;
    }
    //传统烟的费用
    NSInteger cigsPer = [[S_USER_DEFAULTS objectForKey:F_CIGARETTES_DAY]integerValue];  //支
    float pricePack = [[S_USER_DEFAULTS objectForKey:F_PRICE_PACK]floatValue]/20;
    NSDictionary *dic = [S_ALL_SMOKING objectAtIndex:dateIndex];
    NSArray *scheArr = [dic objectForKey:F_SCHEDULE];
    
    //电子烟的费用
    float milliliter = [scheArr count]/300.0;  //ml
    float priceMl = [[S_USER_DEFAULTS objectForKey:F_PRICE_ML]floatValue]/10;
    [[S_ALL_SMOKING objectAtIndex:dateIndex]setObject:[NSString stringWithFormat:@"%.2f", (cigsPer*pricePack-priceMl*milliliter)] forKey:F_SAVE_MONEY];

}

//默认属性设置
- (void)defaultProperty
{
    //获取软件版本号
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString* versionNum =[infoDict objectForKey:@"CFBundleVersion"];
    [S_USER_DEFAULTS setObject:versionNum forKey:F_SMOKE_VERSION];
    
    //第一次打开软件，初始化戒烟起始时间
    [S_USER_DEFAULTS setObject:PUFFS_REMIND_DEFAULT forKey:F_PUFFS_REMIND];//提醒口数 dafault 55
    [S_USER_DEFAULTS setObject:[NSDate date] forKey:F_NON_SMOKING];
    [S_USER_DEFAULTS setObject:@"300" forKey:F_BATTERY_MA];//电流ml
    [S_USER_DEFAULTS setValue:nil forKey:F_POWER];        //功率为空
    [S_USER_DEFAULTS setObject:@"Not connected" forKey:F_FIRMWARE_VERSION];//电子烟蓝牙版本
    [S_USER_DEFAULTS setObject:[NSNumber numberWithInteger:1] forKey:F_STILL_SMOKE];//仍在吸传统烟
    [S_USER_DEFAULTS setObject:[NSNumber numberWithInteger:16] forKey:F_CIGARETTES_DAY];//每天吸的传统烟数
    [S_USER_DEFAULTS setObject:[NSNumber numberWithInteger:0] forKey:F_YEARS_SMOKING];//吸烟多少年了
    [S_USER_DEFAULTS setObject:@"9.50" forKey:F_PRICE_PACK];//每包传统烟多少钱
    [S_USER_DEFAULTS setObject:@"5.00" forKey:F_PRICE_ML];//每毫升烟油多少钱
    [S_USER_DEFAULTS setObject:@"€(EUR)" forKey:F_CURRENCY];//货币符号
    [S_USER_DEFAULTS setObject:@"Ultra Light(<0.5mg/cig.)" forKey:F_NICOTINE_LEVEL];//默认尼古丁mg水平
    [S_USER_DEFAULTS setObject:[NSNumber numberWithInteger:18] forKey:F_AGE];//默认18岁
    [S_USER_DEFAULTS setObject:@"http://www.ecigarfan.com/app/ekmi_agree.html" forKey:F_TERMS_USE];//使用条款
    [S_USER_DEFAULTS setObject:@"http://www.ecigarfan.com/app/ekmi_agree.html" forKey:F_PRIVACY_POLICY];//隐私政策
    [S_USER_DEFAULTS setObject:@"http://www.ecigarfan.com/app/ekmi_agree.html" forKey:F_CUSTOMER_SUPPORT];//客户支持
    [S_USER_DEFAULTS setObject:@"https://itunes.apple.com/us/app/ecigarfan/id893547382?mt=8&uo=4" forKey:STORE_URL];//在appstore的地址
    [S_USER_DEFAULTS setObject:@"100" forKey:F_BATTERY_VALUE];//电量为100
    [S_USER_DEFAULTS setObject:@"0" forKey:F_BATTERY_SHOW];//电量显示方式 0为百分比 1为分钟
    [S_USER_DEFAULTS setObject:@"6" forKey:F_NICOTINE];//尼古丁
    [S_USER_DEFAULTS synchronize];
    
}

@end





