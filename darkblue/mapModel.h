//
//  mapModel.h
//  darkblue
//
//  Created by renchunyu on 14-7-3.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "misticModel.h"

@interface mapModel : misticModel

@property(nonatomic,strong) NSString *vapeTime; // 经销商地址
@property(nonatomic,strong) NSString *vapeLongitude; //  经度
@property(nonatomic,strong) NSString *vapeLatitude; //  纬度

- (id)loadDataAndReturn:(NSDictionary *)dictionary;
@end
