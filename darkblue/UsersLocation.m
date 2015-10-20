//
//  UsersLocation.m
//  Mistic
//
//  Created by JIRUI on 14-9-11.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "UsersLocation.h"

@implementation UsersLocation

+ (id)sharedInstance
{

    static UsersLocation *instance	= nil;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken , ^{
        instance = [[UsersLocation alloc]init];
    });
	return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // 实例化一个位置管理
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = (id)self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 1000.0f;
        NSString * ver = [[UIDevice currentDevice] systemVersion];
        if ([ver floatValue] >= 8.0f) {
            [self.locationManager requestAlwaysAuthorization];
        }
	}
    return self;
}

- (void)startPositioning
{
    // 判断的手机的定位功能是否开启
    if ([CLLocationManager locationServicesEnabled]) {
        // 开启位置更新需要与服务器进行轮询所以会比较耗电，在不需要时用stopUpdatingLocation方法关闭;
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - CLLocationManagerDelegate
//升级ios8后，需要此方法才能进行定位
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            }
            break;
        default:
            break;
    } 
}

// 地理位置发生改变时触发 
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if ([_delegate respondsToSelector:@selector(didUpdateLocation:)]) {
        NSMutableDictionary *locationDic  =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude],F_VAPE_LNG ,
                                            [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude],F_VAPE_LAT , nil];
        [_delegate didUpdateLocation:locationDic];
    }
    // 停止位置更新
    [manager stopUpdatingLocation];
}

// 定位失误时触发
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(didFailUpdateLocation:)]) {
        [_delegate didFailUpdateLocation:error];
    }
}

@end
