//
//  mapModel.m
//  darkblue
//
//  Created by renchunyu on 14-7-3.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "mapModel.h"

@implementation mapModel
- (id)loadDataAndReturn:(NSDictionary *)dic
{

    self.vapeTime = [dic valueForKey:@"vape_time"]; //时间
    self.vapeLongitude = [dic valueForKey:@"vape_lng"];//经度
    self.vapeLatitude = [dic valueForKey:@"vape_lat"];//纬度
    return self;
    
}


@end
