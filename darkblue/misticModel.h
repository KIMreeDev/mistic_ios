//
//  darkblueModel.h
//  darkblue
//
//  Created by renchunyu on 14-7-3.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface misticModel : NSObject<NSCoding>
- (void)loadData:(NSDictionary *)dict;
/*
 *@brief 归档
 */

- (void)encodeWithCoder:(NSCoder *)encoder;


// *@brief 解归档

- (id)initWithCoder:(NSCoder *)decoder;

/*
 *@brief 将Dictionary数据转换到模型字段
 */
@end
