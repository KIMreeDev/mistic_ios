//
//  ecigarfanModel.h
//  ECIGARFAN
//
//  Created by renchunyu on 14-7-15.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EcigarfanModel : NSObject <NSCoding>

@property (strong,nonatomic) id model;
-(EcigarfanModel *)initWithObject:(id)object;
- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;
@end
