//
//  UsersLocation.h
//  Mistic
//
//  Created by JIRUI on 14-9-11.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
//代理
@protocol UsersLocationDelegate <NSObject>
- (void)didUpdateLocation:(NSDictionary *)locationArr;
- (void)didFailUpdateLocation:(NSError *)error;
@end

@interface UsersLocation : NSObject
//单例
+ (id)sharedInstance;
- (void)startPositioning;
//位置管理器
@property (strong, nonatomic) CLLocationManager *locationManager;
//申明个人代理
@property (assign, nonatomic) id<UsersLocationDelegate> delegate;

@end
