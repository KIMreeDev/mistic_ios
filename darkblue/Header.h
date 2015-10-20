//
//  Header.h
//  Mistic
//
//  Created by renchunyu on 14-7-3.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#ifndef Mistic_Header_h
#define Mistic_Header_h


#ifdef DEBUG
#define THLog(...)  printf("\n\n--------------------\n%s Line:%d]\n[\n%s\n]", __FUNCTION__,__LINE__,[[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define THLog(...)
#endif


#import "FunctionDef.h"
#import "ColorDef.h"

//NOtification
#define NOTIFICATION_BLUE_CONNECTED @"blue_connected"
#define NOTIFICATION_STILL_SMOKING @"still_smoking_changed"
#define NOTIFICATION_SCHEDULE_ADD @"schedule_add"
#define NOTIFICATION_POWER_SHOW @"power_show"
#define NOTIFICATION_LIGHT_SHOW @"light_show"
#define NOTIFICATION_CLEAR_SAVE @"clear_save"
#define NOTIFICATION_BLUE_CLOSED @"blue_close"
#define NOTIFICATION_BLUE_OPEN @"blue_open"
#define NOTIFICATION_RESET_REMIND @"reset_remind"

//Userdefault standard
#define BLUEIDENTIFY @"blueidentify"
#define ALLINFO @"allinfo"
#define U_STORED_DEVICES @"stored_devices"
#define F_POWER @"power_values"
#define F_BATTERY_MA @"battery_ma"//电流毫安
//mySmoke
#define F_OPENED_SECOND @"open_second"   //第一次打开标识
#define F_SMOKE_VERSION @"smoke_version"    //软件版本
#define F_FIRMWARE_VERSION @"firmware_version"  //固件版本
#define F_CLEAR_OMIZER @"clearomizer"   //电阻力
//smokerProfile
#define PUFFS_REMIND_DEFAULT @"55"         //默认55口
#define F_PUFFS_REMIND @"puffs_remind" //提醒口数
#define F_SAVE_MONEY @"save_money"  //每天省的烟钱
#define F_STILL_SMOKE @"still_smoking"        //用户是否在继续吸烟
#define F_CIGARETTES_DAY @"cigarettes_day"        //每天吸多少烟
#define F_YEARS_SMOKING @"years_smoking"        //吸烟年龄
#define F_PRICE_PACK @"price_pack"        //每包单价
#define F_PRICE_ML @"price_of_ml"   //10ml烟油的售价
#define F_CURRENCY @"currency"      //货币符号
#define F_NICOTINE_LEVEL @"nicotine_level"  //尼古丁水平
#define F_AGE @"age"  //年龄
#define F_NON_SMOKING @"non_smoking" //戒烟的起始时间
//info
#define F_TERMS_USE @"terms_use" //使用条款
#define F_PRIVACY_POLICY @"privacy_policy" //隐私政策
#define F_CUSTOMER_SUPPORT @"customer_support" //客户支持
#define STORE_URL @"appstore_url"  //在appstore的地址
//puffs、cigs、
#define F_ALL_SMOKING @"all_smoking"    //记录吸烟中取得的所有数据
#define F_DURATION_TIME @"duration_time"    //持续时间
#define F_PLACE @"place"    //此刻吸烟地点
#define F_CIGS_LESS @"cigs"  //少吸多少香烟
#define F_SCHEDULE @"schedule"  //吸烟时刻键值
#define F_TIME @"time"  //今天吸烟的时间点
#define F_SCHEDULE_TIME @"schedule_time"  //今天吸烟的时间点
#define F_CIGS_SMOKE @"cigs_smoke"   //今天吸的传统纸质香烟数量
//control panel
#define F_BATTERY_VALUE @"battery_value"    //电量
#define F_BATTERY_SHOW @"battery_show"  //电池电量显示方式
#define F_NICOTINE @"nicotine"   //尼古丁
//where
#define F_VAPE_LAT @"vape_lat"  //经度
#define F_VAPE_LNG @"vape_lng"  //纬度
#define F_VAPE_TIME @"vape_time"    //时间

#endif
